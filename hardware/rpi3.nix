{ pkgs, ... }: {
  imports = [
    ./aarch64-build-box.nix
    ./bluetooth.nix
  ];

  boot = {
    loader = {
      generic-extlinux-compatible.enable = true;
      grub.enable = false;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "cma=32M" ];
  };

  console.keyMap = "us";

  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  hardware.enableAllFirmware = true;

  nix = {
    buildCores = 2;
    maxJobs = 2;
  };

  nixpkgs.system = "aarch64-linux";

  services.fstrim.enable = true;

  swapDevices = [
    {
      device = "/swap";
      size = 1024;
    }
  ];
}
