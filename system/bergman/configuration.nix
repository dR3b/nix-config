{ config, pkgs, ... }:
let
  waylandOverlayUrl =
    "https://github.com/colemickens/nixpkgs-wayland/archive/master.tar.gz";
  waylandOverlay = (import (builtins.fetchTarball waylandOverlayUrl));
in {
  imports = [ ./hardware-configuration.nix ];

  nixpkgs.overlays = [ waylandOverlay ];

  boot = rec {
    consoleLogLevel = 1;
    earlyVconsoleSetup = true;
    extraModulePackages = with kernelPackages; [ acpi_call ];
    kernelModules = [ "acpi_call" ];
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  environment.pathsToLink = [ "/share/zsh" ];

  environment.systemPackages = with pkgs; [
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    neovim
    qt5.qtwayland
    xorg.xinit
    qgnomeplatform
  ];

  # Configure aspell system wide
  environment.etc."aspell.conf".text = ''
    master en_US
    extra-dicts en-computers.rws
    add-extra-dicts en_US-science.rws
  '';

  fonts = { fonts = with pkgs; [ hack-font font-awesome ]; };

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    bumblebee = {
      enable = true;
      connectDisplay = true;
      driver = "nvidia";
      group = "video";
      pmMethod = "bbswitch";
    };
    cpu.intel.updateMicrocode = true;
    nvidia.modesetting.enable = true;
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        intel-ocl
      ];
    };
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      daemon.config = { realtime-scheduling = "yes"; };
    };
    u2f.enable = true;
  };

  i18n = {
    consoleFont = "ter-v32n";
    consoleKeyMap = "us";
    consolePackages = with pkgs; [ terminus_font ];
    defaultLocale = "en_US.UTF-8";
  };

  networking = {
    hostName = "bergman";
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      wifi.backend = "iwd";
    };
  };

  nix = {
    allowedUsers = [ "@wheel" ];
    binaryCaches = [ "https://standard.cachix.org/" ];
    binaryCachePublicKeys = [
      "standard.cachix.org-1:+HFtC20D1DDrZz4yCXthdaqb3p2zBimNk9Mb+FeergI="
    ];
    daemonIONiceLevel = 5;
    daemonNiceLevel = 10;
    gc = {
      automatic = true;
      dates = "01:00";
    };
    maxJobs = 12;
    optimise = {
      automatic = true;
      dates = [ "01:10" "12:10" ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    gphoto2.enable = true;
    light.enable = true;
    seahorse.enable = true;
    ssh = {
      askPassword = "${pkgs.gnome3.seahorse}/libexec/seahorse/ssh-askpass";
      startAgent = true;
    };
    sway = {
      enable = true;
      extraPackages = with pkgs; [
        alacritty
        grim
        libinput-gestures
        light
        mako
        slurp
        swaybg
        swaylock
        swayidle
        waybar
        wl-clipboard
        xwayland
      ];
      extraSessionCommands = ''
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_FORCE_DPI=physical
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        export _JAVA_AWT_WM_NONREPARENTING=1
        export ECORE_EVAS_ENGINE=wayland_egl
        export ELM_ENGINE=wayland_egl
        export SDL_VIDEODRIVER=wayland
        export MOZ_ENABLE_WAYLAND=1
      '';
    };
    tmux = {
      enable = true;
      aggressiveResize = true;
      clock24 = true;
      escapeTime = 0;
      historyLimit = 10000;
      keyMode = "vi";
      newSession = true;
      secureSocket = false;
      shortcut = "a";
      terminal = "tmux-256color";
    };
    vim.defaultEditor = true;
    zsh.enable = true;
  };

  time.timeZone = "America/Los_Angeles";

  security = {
    rtkit.enable = true;
    pam.services.login = {
      enableGnomeKeyring = true;
      setEnvironment = true;
    };
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };

  services = {
    acpid.enable = true;
    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
    };
    fwupd.enable = true;
    gnome3.gnome-keyring.enable = true;
    printing = {
      enable = true;
      drivers = with pkgs; [ gutenprint cups-googlecloudprint ];
    };
    resolved = {
      enable = true;
      dnssec = "false";
      llmnr = "true";
      extraConfig = ''
        DNS=1.1.1.1 8.8.8.8 1.0.0.1 8.8.4.4 2606:4700:4700::1111 2001:4860:4860::8888 2606:4700:4700::1001 2001:4860:4860::8844
        Cache=yes
        DNSStubListener=yes
        ReadEtcHosts=yes
      '';
    };
    smartd.enable = true;
    thinkfan.enable = true;
    tlp = {
      enable = true;
      extraConfig = ''
        AHCI_RUNTIME_PM_TIMEOUT=15
        CPU_BOOST_ON_AC=1
        CPU_BOOST_ON_BAT=0
        CPU_HWP_ON_AC=performance
        CPU_HWP_ON_BAT=balance_power
        CPU_MAX_PERF_ON_AC=100
        CPU_MAX_PERF_ON_BAT=50
        CPU_MIN_PERF_ON_AC=0
        CPU_MIN_PERF_ON_BAT=0
        CPU_SCALING_GOVERNOR_ON_AC=performance
        CPU_SCALING_GOVERNOR_ON_BAT=powersave
        DEVICES_TO_DISABLE_ON_BAT=""
        DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE="bluetooth"
        DEVICES_TO_DISABLE_ON_SHUTDOWN=""
        DEVICES_TO_DISABLE_ON_STARTUP="bluetooth"
        DEVICES_TO_ENABLE_ON_AC="bluetooth wifi wwan"
        DEVICES_TO_ENABLE_ON_SHUTDOWN="bluetooth wifi"
        DEVICES_TO_ENABLE_ON_STARTUP="wifi"
        DISK_APM_LEVEL_ON_AC="254 254"
        DISK_APM_LEVEL_ON_BAT="128 128"
        DISK_DEVICES="nvme0n1 nvme1n1"
        DISK_IDLE_SECS_ON_AC=0
        DISK_IDLE_SECS_ON_BAT=2
        DISK_IOSCHED="mq-deadline mq-deadline"
        ENERGY_PERF_POLICY_ON_AC=performance
        ENERGY_PERF_POLICY_ON_BAT=power
        MAX_LOST_WORK_SECS_ON_AC=15
        MAX_LOST_WORK_SECS_ON_BAT=15
        NATACPI_ENABLE=1
        NMI_WATCHDOG=0
        PCIE_ASPM_ON_AC=performance
        PCIE_ASPM_ON_BAT=powersave
        RESTORE_DEVICE_STATE_ON_STARTUP=1
        RUNTIME_PM_DRIVER_BLACKLIST="nvidia"
        RUNTIME_PM_ON_AC=auto
        RUNTIME_PM_ON_BAT=auto
        SATA_LINKPWR_ON_AC="max_performance max_performance"
        SATA_LINKPWR_ON_BAT="min_power"
        SCHED_POWERSAVE_ON_AC=0
        SCHED_POWERSAVE_ON_BAT=1
        SOUND_POWER_SAVE_CONTROLLER=Y
        SOUND_POWER_SAVE_ON_AC=0
        SOUND_POWER_SAVE_ON_BAT=1
        START_CHARGE_THRESH_BAT0=90
        STOP_CHARGE_THRESH_BAT0=100
        TLP_DEFAULT_MODE=AC
        TLP_ENABLE=1
        TLP_LOAD_MODULES=y
        TLP_PERSISTENT_DEFAULT=0
        TPACPI_ENABLE=1
        TPSMAPI_ENABLE=1
        USB_AUTOSUSPEND=1
        USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN=1
        USB_BLACKLIST_BTUSB=0
        USB_BLACKLIST_PHONE=1
        USB_BLACKLIST_PRINTER=0
        USB_BLACKLIST_WWAN=0
        USB_WHITELIST="1050:0407 056a:5193"
        WIFI_PWR_ON_AC=on
        WIFI_PWR_ON_BAT=on
        WOL_DISABLE=Y
      '';
    };
    undervolt = {
      enable = true;
      coreOffset = "-70";
      temp = "95";
    };
    upower.enable = true;
    xserver = {
      enable = true;
      exportConfiguration = true;
      autorun = false;
      libinput = {
        enable = true;
        accelSpeed = "0.7";
        naturalScrolling = true;
      };
      useGlamor = true;
      # videoDrivers = [ "intel" "modesetting" "nvidia" ];
      wacom.enable = true;
      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        extraPackages = with pkgs; [
          alacritty
          dunst
          feh
          i3lock
          light
          i3status-rust
          scrot
          xclip
          xorg.xset
          xsel
        ];
        extraSessionCommands = ''
          unset QT_QPA_PLATFORM
          unset QT_WAYLAND_FORCE_DPI
          unset QT_WAYLAND_DISABLE_WINDOWDECORATION
          unset _JAVA_AWT_WM_NONREPARENTING
          unset ECORE_EVAS_ENGINE
          unset ELM_ENGINE
          unset SDL_VIDEODRIVER
          unset MOZ_ENABLE_WAYLAND
        '';
      };
      xautolock = rec {
        enable = true;
        enableNotifier = true;
        extraOptions = [ "-lockaftersleep" "-secure" ];
        killer = "${pkgs.xorg.xset}/bin/xset dpms force off";
        killtime = 10;
        locker =
          "${pkgs.i3lock}/bin/i3lock -i ~/pictures/walls/clouds.png -e -f";
        notifier =
          ''${pkgs.libnotify}/bin/notify-send "Locking in 30 seconds"'';
        notify = 30;
        nowlocker = locker;
        time = 5;
      };
    };
  };

  sound.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09";

  users.users.bemeurer = {
    createHome = true;
    extraGroups = [ "camera" "input" "lxd" "video" "wheel" ];
    hashedPassword =
      "***REMOVED***";
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  virtualisation = {
    lxc.enable = true;
    lxd.enable = true;
  };

}