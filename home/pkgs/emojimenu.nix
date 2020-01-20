{ pkgs, ... }:
let
  emoji_json = pkgs.fetchurl {
    name = "emojis.json";
    url =
      "https://raw.githubusercontent.com/github/gemoji/fd84af55cff8cfdf56ef9635bbd5fef5c8179672/db/emoji.json";
    sha256 = "1ccaz1pxfraf8f7zb4z4p3siknvlkhpr13xp50rs3spbn8shm0sa";
  };
  emojis = pkgs.runCommand "emojis.txt" { nativeBuildInputs = [ pkgs.jq ]; } ''
    cat ${emoji_json} | jq -r '.[] | "\(.emoji) \t   \(.description)"' | sed -e 's,\\t,\t,g' > $out
  '';
  alacritty = "${pkgs.alacritty}/bin/alacritty";
  fzf = "${pkgs.fzf}/bin/fzf";
  notify-send = "${pkgs.libnotify}/bin/notify-send";
in {
  nixpkgs.overlays = [
    (self: super: {
      emojimenu = super.writeScriptBin "emojimenu" ''
        #!${super.stdenv.shell}
        emojimenu_path="$(readlink -f "$0")"
        emojimenu_fifo="/tmp/emojimenu_fifo"
        emojimenu_lock="/tmp/emojimenu_lock"

        function emojimenu_lock() {
          if [[ -f "$emojimenu_lock" ]]; then
            ${notify-send} "✖️ emojimenu already running"
            exit 1
          else
            touch "$emojimenu_lock"
          fi
        }

        function emojimenu_unlock() {
          if [[ -f "$emojimenu_lock" ]]; then
            rm -f "$emojimenu_lock"
          fi
        }

        function emojimenu_window() {
          emoji="$(${fzf} < ${emojis} | cut -f 1 | tr -d '\n')"
          echo "$emoji" > "$emojimenu_fifo"
        }

        function emojimenu_backend() {
          emojimenu_lock
          export EMOJIMENU_BEHAVE_AS_WINDOW=1
          ${alacritty} -d 80 20 -t emojimenu -e "$emojimenu_path"

          emoji="$(cat "$emojimenu_fifo")"
          rm -f "$emojimenu_fifo"
          if [ "$emoji" == "" ]; then
            emojimenu_unlock
            exit 1
          fi

          echo "$emoji" | wl-copy -n
          emojimenu_unlock
        }

        if [[ -v EMOJIMENU_BEHAVE_AS_WINDOW ]]; then
          emojimenu_window
        else
          emojimenu_backend
        fi
      '';
    })
  ];
}