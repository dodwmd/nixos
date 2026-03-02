{
  config,
  lib,
  pkgs,
  ...
}: {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda; # Use CUDA package for RTX 4080
    environmentVariables = {
      # Optimize for RTX 4080 (16GB VRAM)
      OLLAMA_GPU_OVERHEAD = "2147483648"; # 2 GiB in bytes
      OLLAMA_MAX_LOADED_MODELS = "2";
      OLLAMA_NUM_PARALLEL = "4";
      OLLAMA_MAX_QUEUE = "512";
    };
    host = "0.0.0.0";
    port = 11434;
  };

  # Add Ollama client to system packages
  environment.systemPackages = with pkgs; [
    ollama
  ];

  # Open firewall for local access
  networking.firewall.allowedTCPPorts = [ 11434 ];
}
