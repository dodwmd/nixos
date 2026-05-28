{
  flags = [
    # Use XWayland (native Wayland breaks with NVIDIA EGL/glamor disabled)
    "--ozone-platform=x11"
    # GPU settings
    "--ignore-gpu-blocklist"
    "--enable-gpu-rasterization"
    "--enable-zero-copy"
    "--disable-gpu-driver-bug-workarounds"
    "--enable-features=CanvasOopRasterization,OverlayScrollbar,ParallelDownloading"
    # Performance
    "--enable-oop-rasterization"
    "--enable-accelerated-2d-canvas"
    "--enable-gpu-compositing"
    # Smooth browsing
    "--enable-media-router"
    "--enable-smooth-scrolling"
    # UnGoogled features
    "--disable-search-engine-collection"
    "--extension-mime-request-handling=always-prompt-for-install"
    "--fingerprinting-canvas-image-data-noise"
    "--fingerprinting-canvas-measuretext-noise"
    "--fingerprinting-client-rects-noise"
    "--popups-to-tabs"
    "--force-punycode-hostnames"
    "--show-avatar-button=incognito-and-guest"
    # Miscellaneous
    "--no-default-browser-check"
    "--no-pings"
  ];

}
