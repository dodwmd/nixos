{pkgs, ...}: let
  versions = import ./_versions.nix;

  spring-byar = pkgs.stdenv.mkDerivation {
    pname = "spring-byar";
    version = versions.spring-byar.version;

    src = pkgs.fetchurl {
      url = versions.spring-byar.url;
      sha256 = versions.spring-byar.sha256;
    };

    nativeBuildInputs = [
      pkgs.p7zip
      pkgs.autoPatchelfHook
    ];

    buildInputs = [
      pkgs.xorg.libXcursor
      pkgs.SDL2.dev
      pkgs.libpng
      pkgs.libjpeg
      pkgs.libtiff
      pkgs.curl.dev
      pkgs.p7zip
      pkgs.openal
      pkgs.libogg.dev
      pkgs.libvorbis.dev
      pkgs.libunwind.dev
      pkgs.freetype.dev
      pkgs.glew.dev
      pkgs.minizip
      pkgs.fontconfig.dev
      pkgs.jsoncpp.dev
      pkgs.vulkan-headers
      pkgs.vulkan-loader
    ];

    unpackPhase = ''
      7z x "$src"
    '';

    installPhase = ''
      mkdir -p $out
      cp -aLv . $out/bin
    '';
  };

  pr-downloader-bar = pkgs.stdenv.mkDerivation {
    pname = "pr-downloader-bar";
    version = versions.pr-downloader-bar.version;
    src = pkgs.fetchFromGitHub {
      owner = "beyond-all-reason";
      repo = "pr-downloader";
      rev = versions.pr-downloader-bar.rev;
      sha256 = versions.pr-downloader-bar.sha256;
      fetchSubmodules = true;
    };
    buildInputs = [
      pkgs.gcc
      pkgs.cmake
      pkgs.curl
      pkgs.pkg-config
      pkgs.jsoncpp
      pkgs.boost
      pkgs.minizip
    ];
    postInstall = ''
      mkdir $out/bin
      mv $out/pr-downloader $out/bin
    '';
  };

  spring-launcher-byar = let
    chobby-byar-src = pkgs.fetchFromGitHub {
      owner = "beyond-all-reason";
      repo = "BYAR-Chobby";
      rev = versions.chobby-byar.rev;
      sha256 = versions.chobby-byar.sha256;
    };
    spring-launcher-byar-src = pkgs.fetchFromGitHub {
      owner = "beyond-all-reason";
      repo = "spring-launcher";
      rev = versions.spring-launcher-byar.rev;
      sha256 = versions.spring-launcher-byar.sha256;
    };
    version = "${versions.chobby-byar.version}-launcher-${versions.spring-launcher-byar.version}";
    src =
      pkgs.runCommand "byar-launcher-src-${version}"
      {
        buildInputs = [pkgs.nodejs pkgs.jq pkgs.nodePackages.npm];
      } ''
        cp -r ${chobby-byar-src} BYAR-Chobby
        cp -r ${spring-launcher-byar-src} launcher
        chmod -R +w *

        pushd launcher
        echo "Patching files..."
        patch -p1 < ${./01-disable-updates.patch}
        popd

        echo "Applying chobby ${versions.chobby-byar.version} to launcher ${versions.spring-launcher-byar.version}..."
        cp -r BYAR-Chobby/dist_cfg/* launcher/src/
        for dir in bin files build; do
          mkdir -p launcher/$dir
          if [ -d launcher/src/$dir/ ]; then
            mv launcher/src/$dir/* launcher/$dir/
            rm -rf launcher/src/$dir
          fi
        done

        GITHUB_REPOSITORY=beyond-all-reason/BYAR-Chobby
        PACKAGE_VERSION=${version}
        pushd BYAR-Chobby
        echo "Creating package.json for launcher..."
        node build/make_package_json.js ../launcher/package.json dist_cfg/config.json $GITHUB_REPOSITORY $PACKAGE_VERSION
        popd

        echo "Removing electron as dependency..."
        cat launcher/package.json \
          | jq 'del(.devDependencies.electron)' \
          > temp
        mv temp launcher/package.json
        cat launcher/package-lock.json \
          | jq 'del(.packages."".devDependencies.electron)' \
          | jq 'del(.packages."node_modules/electron")' \
          > temp
        mv temp launcher/package-lock.json

        mv launcher $out
      '';
    nodeModules = pkgs.buildNpmPackage {
      inherit src version;
      pname = "spring-launcher-byar-node-modules";
      npmDepsHash = versions.spring-launcher-byar.npmDepsHash;
      npmFlags = ["--legacy-peer-deps"];
      dontNpmBuild = true;
      installPhase = ''
        mv node_modules $out
      '';
    };
  in
    pkgs.stdenv.mkDerivation {
      pname = "spring-launcher-byar";
      inherit version src;

      phases = ["buildPhase"];
      buildPhase = ''
        mkdir -p "$out/lib"
        cp -aLv "$src" "$out/lib/dist"
        chmod -R +w "$out"
        cp -r "${nodeModules}" "$out/lib/dist/node_modules"

        # rm will validate that the original file exist
        rm "$out/lib/dist/bin/butler/linux/butler"
        ln -s "${pkgs.butler}/bin/butler" "$out/lib/dist/bin/butler/linux/butler"

        rm "$out/lib/dist/bin/pr-downloader"
        ln -s "${pr-downloader-bar}/bin/pr-downloader" "$out/lib/dist/bin/pr-downloader"

        ln -s "${pkgs.p7zip}/bin/7z" "$out/lib/dist/bin/7z"

        rm "$out/lib/dist/src/path_7za.js"
        cat << EOF > "$out/lib/dist/src/path_7za.js"
        'use strict';
        module.exports = "$out/lib/dist/bin/7z";
        EOF
      '';
    };

  electron = pkgs.electron;

  byar-steam-run = (pkgs.steam.override {
    extraPkgs = p:
      with p; [
        SDL2
        glew
        libGLU
        libtiff
        libunwind
        minizip
        jsoncpp
      ];
  }).run;

  byar = pkgs.writeShellApplication {
    name = "byar";
    runtimeInputs = [byar-steam-run pkgs.findutils];
    text = ''
      # Fix read-only files copied from Nix store on previous runs
      CACHE_DIR="$HOME/.cache/beyond-all-reason"
      mkdir -p "$CACHE_DIR"
      find "$CACHE_DIR" -maxdepth 1 -type f ! -perm -u+w -exec chmod u+w {} +

      # Force NVIDIA GLX driver (otherwise libglvnd dispatches to Mesa/llvmpipe via XWayland)
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __GLX_VENDOR_LIBRARY_NAME=nvidia

      declare -a args=( )
      if [ -n "''${WAYLAND_DISPLAY:-}" ]; then
        export SDL_VIDEODRIVER=wayland
        args+=(
          --enable-features="UseOzonePlatform,WaylandWindowDecorations"
        )
      fi
      exec steam-run ${electron}/bin/electron \
          "''${args[@]}" \
          ${spring-launcher-byar}/lib/dist \
            --write-path="$HOME/.cache/beyond-all-reason/"
    '';
  };
in {
  users.users.dodwmd.packages = [byar];
}
