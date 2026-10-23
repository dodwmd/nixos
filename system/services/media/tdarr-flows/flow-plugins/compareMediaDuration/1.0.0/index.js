"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.plugin = exports.details = void 0;

// Like Community compareFileDurationRatio, but compares the real length of the main video stream
// instead of the container duration. The container duration is the longest stream, and subtitle
// tracks routinely run past the end of the video, so a correct re-encode looked "too short". Audio
// is not compared: the flow deliberately removes unwanted-language audio tracks, and the removed
// one can be the longest. Stream duration tags can also be stale, so the length is measured from
// the last packets. Audio is only used when a file has no video stream.

var childProcess = require('child_process');
var path = require('path');

var details = function () { return ({
  name: 'Compare Media Duration',
  description: 'Compare working file video duration to the original, ignoring audio, subtitle and data streams.',
  style: {
    borderColor: 'orange',
  },
  tags: '',
  isStartPlugin: false,
  pType: '',
  requiresVersion: '2.11.01',
  sidebarPosition: -1,
  icon: 'faQuestion',
  inputs: [
    {
      label: 'Greater Than',
      name: 'greaterThan',
      type: 'number',
      defaultValue: '99.5',
      inputUI: {
        type: 'text',
      },
      tooltip: 'Lower bound: new video duration must be at least this % of the original.',
    },
    {
      label: 'Less Than',
      name: 'lessThan',
      type: 'number',
      defaultValue: '100.5',
      inputUI: {
        type: 'text',
      },
      tooltip: 'Upper bound: new video duration must be at most this % of the original.',
    },
  ],
  outputs: [
    {
      number: 1,
      tooltip: 'Working file duration % is within range',
    },
    {
      number: 2,
      tooltip: 'Working file duration % is smaller than lower bound',
    },
    {
      number: 3,
      tooltip: 'Working file duration % is larger than upper bound',
    },
  ],
}); };
exports.details = details;

// Seconds from the first to the end of the last packet of the first video stream (first audio
// stream if there is no video)
var measure = function (ffprobe, file, fallback) {
  var run = function (extra) {
    return childProcess.execFileSync(ffprobe, ['-v', 'error', '-of', 'json'].concat(extra, [file]),
      { encoding: 'utf8', maxBuffer: 64 * 1024 * 1024, timeout: 120000 });
  };
  var head = JSON.parse(run(['-show_entries', 'format=duration']));
  var total = Number(head.format && head.format.duration) || 0;
  var best = 0;
  ['v:0', 'a:0'].forEach(function (sel) {
    if (best > 0) return;
    var first = JSON.parse(run(['-select_streams', sel, '-show_entries', 'packet=pts_time,duration_time',
      '-read_intervals', '%+#1']));
    var start = first.packets && first.packets[0] ? Number(first.packets[0].pts_time) : NaN;
    if (!(start >= 0)) return;
    var from = Math.max(total - 30, 0);
    var tail = JSON.parse(run(['-select_streams', sel, '-show_entries', 'packet=pts_time,duration_time',
      '-read_intervals', from + '%']));
    var end = NaN;
    (tail.packets || []).forEach(function (p) {
      var e = Number(p.pts_time) + (Number(p.duration_time) || 0);
      if (!(end >= e)) end = e;
    });
    if (end - start > 0) best = end - start;
  });
  return best > 0 ? best : fallback;
};

var plugin = function (args) {
  var lib = require('../../../../../methods/lib')();
  args.inputs = lib.loadDefaultValues(args.inputs, details);

  var formatDuration = function (obj) {
    try { return Number(obj.ffProbeData.format.duration) || 0; } catch (err) { return 0; }
  };
  var ffprobe = 'ffprobe';
  if (args.ffmpegPath) ffprobe = path.join(path.dirname(args.ffmpegPath), 'ffprobe');

  var measured = function (obj, label) {
    var file = obj._id;
    var fallback = formatDuration(obj);
    try {
      return measure(ffprobe, file, fallback);
    } catch (err) {
      args.jobLog('Could not measure ' + label + ' video duration (' + String(err.message).split('\n')[0]
        + '), using container duration ' + fallback);
      return fallback;
    }
  };

  var newDuration = measured(args.inputFileObj, 'new file');
  var origDuration = measured(args.originalLibraryFile, 'original file');
  args.jobLog('newFileDuration (video): ' + newDuration);
  args.jobLog('origFileDuration (video): ' + origDuration);

  var greaterThan = Number(args.inputs.greaterThan);
  var lessThan = Number(args.inputs.lessThan);
  var ratio = (newDuration / origDuration) * 100;
  var text = 'New file has video duration ' + newDuration.toFixed(3) + ' which is ' + ratio
    + '% of original duration: ' + origDuration.toFixed(3);

  var outputNumber = 1;
  if (!(origDuration > 0) || !(newDuration > 0)) {
    args.jobLog('Duration unavailable for one of the files. ' + text);
    outputNumber = 2;
  } else if (ratio > lessThan) {
    args.jobLog('New file duration not within limits. ' + text + '. upperBound is ' + lessThan + '%');
    outputNumber = 3;
  } else if (ratio < greaterThan) {
    args.jobLog('New file duration not within limits. ' + text + '. lowerBound is ' + greaterThan + '%');
    outputNumber = 2;
  } else {
    args.jobLog(text);
  }

  return {
    outputFileObj: args.inputFileObj,
    outputNumber: outputNumber,
    variables: args.variables,
  };
};
exports.plugin = plugin;
