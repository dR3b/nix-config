{ pkgs, ... }: {
  boot = {
    consoleLogLevel = 1;
    kernelParams = [
      "quiet"
      "systemd.show_status=auto"
      "udev.log_priority=3"
      "i915.fastboot=1"
      "vga=current"
    ];
  };
}