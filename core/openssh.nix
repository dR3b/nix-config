{ lib, ... }: {
  programs.mosh.enable = true;

  services.openssh = {
    enable = true;
    challengeResponseAuthentication = false;
    permitRootLogin = lib.mkDefault "no";
    extraConfig = ''
      # Specifies whether to remove an existing Unix-domain socket file for local or remote port forwarding before creating a new one
      StreamLocalBindUnlink yes
    '';
  };

  services.sshguard.enable = true;
}
