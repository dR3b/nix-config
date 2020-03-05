{
  nixpkgs.overlays = [
    (
      self: super: {
        nouveau-gr-fix = {
          name = "nouveau-gr-fix";
          patch = (
            builtins.fetchurl {
              url =
                "https://github.com/karolherbst/linux/commit/0a4d0a9f2ab29b4765ee819753fbbcbc2aa7da97.patch";
              sha256 = "1k4lf1cnydckjn2fqdqiizba3rzjg27xa97xjaif4ss5m7mh4ckn";
            }
          );
        };
        nouveau-runpm-fix = {
          name = "nouveau-runpm-fix";
          patch = (
            builtins.fetchurl {
              url =
                "https://github.com/karolherbst/linux/commit/1e6cef9e6c4d17f6d893dae3cd7d442d8574b4b5.patch";
              sha256 = "103myhwmi55f7vaxk9yqrl4diql6z32am5mzd6kvk89j9m02h528";
            }
          );
        };
        xfs-2038-fix = {
          name = "xfs-2038-fix";
          patch = (
            builtins.fetchurl {
              url = "https://lkml.org/lkml/diff/2019/12/26/349/1";
              sha256 = "1jzxncv97w3ns60nk91b9b0a11bp1axng370qhv4fs7ik01yfsa4";
            }
          );
        };
      }
    )
  ];
}
