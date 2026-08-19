{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.homelab.llama-cpp;
in {
  options.homelab.llama-cpp = {
    enable = mkEnableOption "llama-cpp inference server";

    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Address to bind the server to";
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port for the llama-cpp HTTP server";
    };

    nfsModelPath = mkOption {
      type = types.str;
      default = "192.168.1.6:/mnt/tank/nfs/openclaw/models";
      description = "NFS source path for GGUF model files";
    };

    localModelPath = mkOption {
      type = types.str;
      default = "/var/lib/llama-cpp/models";
      description = "Local directory to sync models to";
    };

    model = mkOption {
      type = types.str;
      default = "";
      description = "Model filename to load (relative to localModelPath). If empty, loads the first .gguf file found.";
    };

    contextSize = mkOption {
      type = types.int;
      default = 8192;
      description = "Context size for the model";
    };

    threads = mkOption {
      type = types.int;
      default = 0;
      description = "Number of threads to use (0 = auto-detect)";
    };

    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra command-line flags for llama-server";
    };
  };

  config = mkIf cfg.enable {
    # NFS mount for model source
    fileSystems."/mnt/llama-models" = {
      device = cfg.nfsModelPath;
      fsType = "nfs";
      options = ["vers=3" "rsize=1048576" "wsize=1048576" "hard" "x-systemd.automount" "noauto" "ro"];
    };

    # Ensure local model directory exists
    systemd.tmpfiles.rules = [
      "d ${cfg.localModelPath} 0755 root root -"
    ];

    # Model sync service — runs before llama-cpp starts
    systemd.services.llama-cpp-model-sync = {
      description = "Sync GGUF models from NFS to local storage";
      wantedBy = ["llama-cpp.service"];
      before = ["llama-cpp.service"];
      requires = ["mnt-llama\\x2dmodels.automount"];
      after = ["mnt-llama\\x2dmodels.automount" "network-online.target"];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      # Copy missing files, remove files that no longer exist on source
      script = ''
        set -euo pipefail
        SRC="/mnt/llama-models"
        DST="${cfg.localModelPath}"

        echo "Syncing models from $SRC to $DST..."

        # Copy new/updated files
        for f in "$SRC"/*.gguf; do
          [ -e "$f" ] || continue
          name="$(${pkgs.coreutils}/bin/basename "$f")"
          if [ ! -e "$DST/$name" ] || [ "$f" -nt "$DST/$name" ]; then
            echo "Copying $name..."
            ${pkgs.coreutils}/bin/cp -f "$f" "$DST/$name"
          fi
        done

        # Remove local files that no longer exist on source
        for f in "$DST"/*.gguf; do
          [ -e "$f" ] || continue
          name="$(${pkgs.coreutils}/bin/basename "$f")"
          if [ ! -e "$SRC/$name" ]; then
            echo "Removing $name (no longer on source)..."
            ${pkgs.coreutils}/bin/rm -f "$f"
          fi
        done

        echo "Model sync complete."
      '';
    };

    # llama-cpp server
    systemd.services.llama-cpp = {
      description = "llama-cpp inference server";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target" "llama-cpp-model-sync.service"];
      requires = ["llama-cpp-model-sync.service"];

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 10;
        DynamicUser = false;
      };

      script = let
        threadFlag =
          if cfg.threads > 0
          then "--threads ${toString cfg.threads}"
          else "";
        extraFlagsStr = concatStringsSep " " cfg.extraFlags;
      in ''
        MODEL_PATH="${cfg.localModelPath}"

        # Determine which model to load
        if [ -n "${cfg.model}" ]; then
          MODEL="$MODEL_PATH/${cfg.model}"
        else
          MODEL="$(ls "$MODEL_PATH"/*.gguf 2>/dev/null | head -1)"
        fi

        if [ -z "$MODEL" ] || [ ! -f "$MODEL" ]; then
          echo "ERROR: No GGUF model found in $MODEL_PATH"
          exit 1
        fi

        echo "Loading model: $MODEL"

        exec ${pkgs.llama-cpp}/bin/llama-server \
          --host ${cfg.host} \
          --port ${toString cfg.port} \
          --model "$MODEL" \
          --ctx-size ${toString cfg.contextSize} \
          ${threadFlag} \
          ${extraFlagsStr}
      '';
    };

    # Open firewall
    networking.firewall.allowedTCPPorts = [cfg.port];

    # Add llama-cpp CLI tools to system
    environment.systemPackages = [pkgs.llama-cpp];
  };
}
