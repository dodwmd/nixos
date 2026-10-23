# Tdarr flow and plugin sources

Source of truth for the Tdarr "Efficient Encode v4" flow and the plugins it uses.
Tdarr runs on nexus (`tdarr.nix`); its server config lives in `/tank/config/tdarr/server`
and is shared with the other nodes (exodus, k3s-worker-03) over NFS, so deploying to nexus is
enough. These files are NOT deployed by Nix. Copy them by hand as below.

Imported from `homelab/k3s/apps/tdarr/scripts/` and synced with what is live on nexus.

## Layout

| Path | Deploys to (on nexus, under `/tank/config/tdarr/server/Tdarr/Plugins/`) |
|---|---|
| `plugins/Custom_EfficientEncode.js` | `Local/Custom_EfficientEncode.js` |
| `flow-plugins/checkIsGPUWorker/1.0.0/index.js` | `FlowPlugins/LocalFlowPlugins/tools/checkIsGPUWorker/1.0.0/index.js` |
| `flow-plugins/checkIsNvidiaNode/2.0.0/index.js` | `FlowPlugins/LocalFlowPlugins/tools/checkIsNvidiaNode/2.0.0/index.js` |
| `flow-plugins/compareMediaDuration/1.0.0/index.js` | `FlowPlugins/LocalFlowPlugins/tools/compareMediaDuration/1.0.0/index.js` |
| `flows/efficient-encode-v4.json` | import via the Tdarr UI (Flows > Import) |

Flow plugin directory versions must match the `version` in the flow JSON, and
`sourceRepo: "Local"` plugins live under `LocalFlowPlugins`.

## Deploy

```bash
cd system/services/media/tdarr-flows
P=/tank/config/tdarr/server/Tdarr/Plugins

scp plugins/Custom_EfficientEncode.js nexus:/tmp/
ssh nexus "sudo cp $P/Local/Custom_EfficientEncode.js /tank/config/tdarr/Custom_EfficientEncode.js.bak-\$(date +%Y%m%d) && \
  sudo cp /tmp/Custom_EfficientEncode.js $P/Local/ && sudo chown media:media $P/Local/Custom_EfficientEncode.js"
```

Flow plugins: copy each `index.js` to its path above the same way, then sync to the nodes (Tdarr UI
Settings > Plugins > Sync, or `curl -X POST http://localhost:8265/api/v2/sync-plugins -H 'content-type: application/json' -d '{"data":{}}'`
on nexus). Do this before a flow references a new plugin, or nodes will not have it. The flow can be
read with `POST /api/v2/cruddb {"data":{"collection":"FlowsJSONDB","mode":"getAll"}}` and written with
`{"data":{"collection":"FlowsJSONDB","mode":"update","docID":"efficientEnc4","obj":<flow json>}}`.

## Flow: `efficientEnc4`

Input > GPU worker? (no: CPU encode) > NVIDIA node? (yes: NVENC, no: VAAPI) > image removal >
audio clean > subtitle clean > reorder streams > size check (keep original when out of range) >
duration check (`compareMediaDuration`, fail on mismatch) > replace original.

## Hardware notes

- nexus: Intel Arc (`renderD128`, i915/iHD) decodes MPEG-2, H.264, HEVC, VP9, AV1; AMD iGPU on `renderD129`.
- k3s-worker-03: AMD Ryzen iGPU (radeonsi). Decodes H.264, HEVC, VP9, AV1 only, no MPEG-2 or VC-1.
  The plugin therefore decodes MPEG-2 in software and uploads with `hwupload`.
- exodus: NVIDIA RTX 4080 (NVENC).

## Duration check

`compareMediaDuration` measures the real length of the main video stream of both files from the
last packets (`ffprobe`), instead of the container duration. The container duration is the longest
stream, and subtitle tracks often run past the video, so correct encodes were rejected (Mr. Deeds,
Hotel Transylvania, ...). Audio is deliberately not compared: the clean-audio step removes
unwanted-language tracks and the removed one can be the longest (Scary Movie's Spanish track ran 144s
past the video). Bounds stay 99.5 to 100.5 percent. Audio is only used when a file has no video.

## Known issues

- MPEG-2 is not yet routed to nexus's Intel GPU; it relies on the plugin's software-decode path.
- `The Wrong Paris (2025).mkv` is a broken source: its video track ends at 15:37 while the audio
  runs 102 minutes.
