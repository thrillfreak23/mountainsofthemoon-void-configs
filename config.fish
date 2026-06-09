if status is-interactive
# Commands to run in interactive sessions can go here

source ~/.alias

fish_vi_cursor
fish_vi_key_bindings
source /usr/share/fzf/key-bindings.fish; fzf_key_bindings

zoxide init fish | source

set fish_greeting
# set -gx TERM kitty
set -gx BROWSER brave-browser
set -gx EDITOR nvim
set -gx GTK_THEME "Adwaita:dark pavucontrol"
set -gx DURAS_DIR "~/Documents/Duras-Notes"


# abbr -a e 'devour emacsclient -c'

set -gx LIBVA_DRIVER_NAME i965

# Add this to you config.fish or equivalent.
# Fish don't support recursive calls so use f function
function f
    fff $argv
    set -q XDG_CACHE_HOME; or set XDG_CACHE_HOME $HOME/.cache
    cd (cat $XDG_CACHE_HOME/fff/.fff_d)
end


end
