/* eslint no-plusplus: ["error", { "allowForLoopAfterthoughts": true }] */
// Bitrate-driven HEVC encode. Replaces the "is the codec modern?" gate: a file is
// re-encoded when its codec is old OR its video bitrate is above a per-resolution cap,
// so 4K remuxes get compressed instead of passed through.
//
// NOTE: Tdarr splits classic presets on every ',' - so '<io>' is used as the
// input/output separator because filters and params below contain commas.

const MODERN = ['hevc', 'av1', 'vp9'];

// Per resolution class: target average, peak, and the bitrate (kbps) above which we re-encode
const CLASSES = {
  uhd: { avg: 16000, max: 20000, trigger: 24000 },
  fhd: { avg: 6000, max: 9000, trigger: 10000 },
  hd: { avg: 3000, max: 5000, trigger: 6000 },
  sd: { avg: 1500, max: 2500, trigger: 3500 },
};

// Audio codecs worth converting to EAC3 (lossless / DTS family)
const CONVERT_AUDIO = ['dts', 'truehd', 'mlp', 'flac', 'alac'];

// Codecs every GPU node can hardware-decode (10-bit H.264 is not hardware decodable on either).
// mpeg2video is deliberately absent: the AMD iGPU on k3s-worker-03 has no MPEG-2 decode, and
// forcing -hwaccel vaapi there aborts with "Failed setup for format vaapi". MPEG-2 is decoded
// in software and uploaded with hwupload instead, which works on every node.
const HW_DECODE = ['h264', 'hevc', 'vp9', 'av1'];

// Subtitle codecs Matroska can store. Anything else (arib_caption, dvb_teletext, eia_608, ...)
// is dropped: copying it makes the mkv muxer fail.
const MKV_SUBS = [
  'subrip', 'srt', 'ass', 'ssa', 'webvtt', 'text', 'mov_text',
  'hdmv_pgs_subtitle', 'dvd_subtitle', 'dvb_subtitle',
];

// Broadcast-capture containers: their ADTS/LATM AAC cannot be stream-copied into Matroska
// (ffmpeg: "Error parsing AAC extradata"), so AAC audio is re-encoded when coming from these.
const BROADCAST_CONTAINERS = ['ts', 'm2ts', 'mts'];

function details() {
  return {
    id: 'Custom_EfficientEncode',
    Stage: 'Pre-processing',
    Name: 'Efficient HEVC encode (bitrate-driven, HDR-safe)',
    Type: 'Video',
    Operation: 'Transcode',
    Description:
      'Re-encodes to HEVC when the codec is old or the video bitrate exceeds a per-resolution cap. '
      + 'Keeps resolution and HDR10, converts lossless/DTS audio to EAC3, copies subtitles.',
    Version: '1.0',
    Tags: 'pre-processing,ffmpeg,h265,hevc,vaapi,nvenc,hdr',
    Inputs: [
      {
        name: 'encoder',
        type: 'string',
        defaultValue: 'vaapi',
        inputUI: { type: 'dropdown', options: ['vaapi', 'nvenc', 'cpu'] },
        tooltip: 'Encoder to use: vaapi (Intel Arc), nvenc (NVIDIA) or cpu (libx265)',
      },
    ],
  };
}

// Classify by the larger of width and scaled height: widescreen / scope films are letterboxed
// (e.g. 3840x1608 is still 4K, 1920x800 is still 1080p), so height alone under-classifies them
function resClass(width, height) {
  const w = Math.max(width || 0, Math.round((height || 0) * 16 / 9));
  if (w >= 3000) return 'uhd';
  if (w >= 1700) return 'fhd';
  if (w >= 1100) return 'hd';
  return 'sd';
}

function audioKbps(stream) {
  const br = parseInt(stream.bit_rate, 10);
  if (br > 0) return br / 1000;
  const lossless = CONVERT_AUDIO.includes(stream.codec_name);
  return lossless ? 4500 : 640; // rough estimate when the container has no per-stream rate
}

function plugin(file, librarySettings, inputs, otherArguments) {
  const lib = require('../methods/lib')();
  inputs = lib.loadDefaultValues(inputs, details);
  const response = {
    processFile: false,
    preset: '',
    container: '.mkv',
    handBrakeMode: false,
    FFmpegMode: true,
    reQueueAfter: true,
    infoLog: '',
  };

  if (file.fileMedium !== 'video') {
    response.infoLog += '☒File is not a video\n';
    return response;
  }

  const streams = file.ffProbeData.streams || [];
  const video = streams.find((s) => s.codec_type === 'video' && !(s.disposition && s.disposition.attached_pic));
  if (!video) {
    response.infoLog += '☒No video stream found\n';
    return response;
  }
  const audio = streams.filter((s) => s.codec_type === 'audio');
  const subs = streams.filter((s) => s.codec_type === 'subtitle');

  const height = video.height || 0;
  const cls = CLASSES[resClass(video.width, height)];
  const pixFmt = video.pix_fmt || '';
  const tenBit = /10|12/.test(pixFmt);
  const hdr = ['smpte2084', 'arib-std-b67'].includes(video.color_transfer);
  const out10 = tenBit || hdr;

  // Video bitrate: stream value, else mediaInfo, else overall bitrate minus estimated audio
  let videoKbps = parseInt(video.bit_rate, 10) / 1000;
  if (!(videoKbps > 0) && file.mediaInfo && file.mediaInfo.track) {
    const t = file.mediaInfo.track.find((x) => x['@type'] === 'Video');
    if (t && parseInt(t.BitRate, 10) > 0) videoKbps = parseInt(t.BitRate, 10) / 1000;
  }
  if (!(videoKbps > 0)) {
    const overall = parseInt(file.bit_rate, 10) / 1000
      || (file.file_size * 1024 * 8) / (parseFloat(file.meta && file.meta.Duration) || file.duration || 1);
    videoKbps = Math.max(overall - audio.reduce((a, s) => a + audioKbps(s), 0), 0);
  }
  videoKbps = Math.round(videoKbps);

  const oldCodec = !MODERN.includes(video.codec_name);
  const tooBig = videoKbps > cls.trigger;

  response.infoLog += `📊 ${video.width}x${height} ${video.codec_name} ${pixFmt}${hdr ? ' HDR' : ''}, video ~${videoKbps} kbps (cap ${cls.trigger})\n`;

  if (!oldCodec && !tooBig) {
    response.infoLog += '☑Already efficient - no re-encode needed\n';
    return response;
  }

  // Never target more than 75% of the source rate (avoids upsizing already-small files)
  const avg = Math.max(Math.min(cls.avg, Math.round(videoKbps * 0.75)) || cls.avg, 500);
  const peak = Math.min(cls.max, Math.round(avg * 1.3));
  const buf = peak * 2;
  response.infoLog += `🎯 Target ${avg} kbps avg / ${peak} peak (${oldCodec ? 'old codec' : 'bitrate over cap'})\n`;

  const enc = inputs.encoder;
  const hwDecode = HW_DECODE.includes(video.codec_name) && !(video.codec_name === 'h264' && tenBit);

  // Color tags so HDR10 survives the re-encode (mastering display / MaxCLL are carried as side data).
  // Only pass values the hardware encoders accept: odd source tags (bt470bg, gbr, ...) make
  // hevc_vaapi abort with "Unable to parse option value", so those are left untagged instead.
  const OK_PRIMARIES = ['bt709', 'bt2020'];
  const OK_TRC = ['bt709', 'smpte2084', 'arib-std-b67'];
  const OK_SPACE = ['bt709', 'bt2020nc'];
  let color = '';
  if (OK_PRIMARIES.includes(video.color_primaries)) color += ` -color_primaries ${video.color_primaries}`;
  if (OK_TRC.includes(video.color_transfer)) color += ` -color_trc ${video.color_transfer}`;
  if (OK_SPACE.includes(video.color_space)) color += ` -colorspace ${video.color_space}`;

  const rate = `-b:v ${avg}k -maxrate ${peak}k -bufsize ${buf}k`;
  let inArgs = '';
  let vArgs = '';

  if (enc === 'nvenc') {
    inArgs = hwDecode ? '-hwaccel cuda' : '';
    vArgs = `-c:v hevc_nvenc -preset p5 -tune hq -rc vbr ${rate} -profile:v ${out10 ? 'main10' : 'main'} -pix_fmt ${out10 ? 'p010le' : 'yuv420p'}`;
  } else if (enc === 'vaapi') {
    const fmt = out10 ? 'p010' : 'nv12';
    if (hwDecode) {
      // Hardware decode, but frames are downloaded to system memory and re-uploaded rather than kept
      // on the GPU (-hwaccel_output_format vaapi + scale_vaapi). When the hardware decoder gives up
      // on a frame mid-stream, ffmpeg falls back to software decode and reconfigures the filter
      // graph; scale_vaapi then cannot take the software frames ("Impossible to convert between the
      // formats supported by the filter 'Parsed_scale_vaapi_0'..."), failing the job minutes in.
      // -reinit_filter 0: some sources change colour metadata a few frames in, which makes ffmpeg
      // rebuild the filter graph, and a graph containing hwupload cannot be rebuilt ("Impossible to
      // convert between the formats supported by the filter 'Parsed_hwupload_1'...").
      inArgs = '-init_hw_device vaapi=va:/dev/dri/renderD128 -hwaccel vaapi -hwaccel_device va -filter_hw_device va -reinit_filter 0';
      vArgs = `-vf format=${fmt},hwupload`;
    } else {
      inArgs = '-init_hw_device vaapi=va:/dev/dri/renderD128 -filter_hw_device va -reinit_filter 0';
      vArgs = `-vf format=${fmt},hwupload`;
    }
    vArgs += ` -c:v hevc_vaapi -profile:v ${out10 ? 'main10' : 'main'} -rc_mode VBR ${rate} -sei +hdr`;
  } else {
    vArgs = `-c:v libx265 -preset medium ${rate} -pix_fmt ${out10 ? 'yuv420p10le' : 'yuv420p'} -x265-params log-level=error`;
  }

  // Audio: copy lossy, convert lossless/DTS to EAC3 5.1 (stereo stays stereo)
  let aArgs = '-c:a copy';
  audio.forEach((s, i) => {
    if (CONVERT_AUDIO.includes(s.codec_name) || (s.codec_name || '').startsWith('pcm_')) {
      const ch = s.channels > 2 ? 6 : s.channels || 2;
      aArgs += ` -c:a:${i} eac3 -b:a:${i} ${ch > 2 ? 640 : 256}k -ac:a:${i} ${ch}`;
      response.infoLog += `🔊 Audio ${i}: ${s.codec_name} -> EAC3 ${ch}ch\n`;
    } else if (BROADCAST_CONTAINERS.includes(file.container) && /^aac/.test(s.codec_name || '')) {
      const ch = s.channels > 2 ? 6 : s.channels || 2;
      aArgs += ` -c:a:${i} aac -b:a:${i} ${ch > 2 ? 384 : 192}k -ac:a:${i} ${ch}`;
      response.infoLog += `🔊 Audio ${i}: ${s.codec_name} (${file.container}) -> AAC ${ch}ch (cannot copy into mkv)\n`;
    }
  });

  // Subtitles: copy the ones Matroska can store and map them explicitly; mov_text (mp4) cannot
  // be stored in mkv so it is converted to srt, and unsupported formats are dropped
  let sArgs = '-c:s copy';
  let subMaps = '';
  let outSub = 0;
  subs.forEach((s, i) => {
    if (!MKV_SUBS.includes(s.codec_name)) {
      response.infoLog += `☒Dropping subtitle ${i}: ${s.codec_name} is not storable in mkv\n`;
      return;
    }
    subMaps += ` -map 0:s:${i}`;
    if (s.codec_name === 'mov_text') sArgs += ` -c:s:${outSub} srt`;
    outSub += 1;
  });

  // -map 0:V skips attached cover-art "video" streams
  const maps = `-map 0:V:0 -map 0:a?${subMaps} -map 0:t? -map_metadata 0 -map_chapters 0`;
  const output = `${maps} ${vArgs}${color} ${aArgs} ${sArgs} -max_muxing_queue_size 9999`;
  response.preset = `${inArgs}<io>${output}`;
  response.processFile = true;
  response.infoLog += `✔ Encoding to HEVC with ${enc}\n`;
  return response;
}

module.exports.details = details;
module.exports.plugin = plugin;
