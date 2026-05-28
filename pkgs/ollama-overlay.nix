# Overlay to bump ollama to 0.17.4 (required for Qwen 3.5 support)
# Remove this overlay once nixos-unstable includes ollama >= 0.17.4
final: prev: let
  ollamaOverride = ollamaPkg:
    ollamaPkg.overrideAttrs (oldAttrs: {
      version = "0.17.4";
      src = prev.fetchFromGitHub {
        owner = "ollama";
        repo = "ollama";
        tag = "v0.17.4";
        hash = "sha256-9yJ8Jbgrgiz/Pr6Se398DLkk1U2Lf5DDUi+tpEIjAaI=";
      };
      vendorHash = "sha256-Lc1Ktdqtv2VhJQssk8K1UOimeEjVNvDWePE9WkamCos=";
      proxyVendor = true;
      postPatch = ''
        substituteInPlace version/version.go \
          --replace-fail 0.0.0 '0.17.4'
        rm -r app
      '';
    });
in {
  ollama = ollamaOverride prev.ollama;
  ollama-cuda = ollamaOverride prev.ollama-cuda;
  ollama-rocm = ollamaOverride prev.ollama-rocm;
  ollama-vulkan = ollamaOverride prev.ollama-vulkan;
}
