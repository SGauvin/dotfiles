# fish_vi_key_bindings
set fish_greeting
# if status is-interactive
#     # Commands to run in interactive sessions can go here
# end

function fish_user_key_bindings
    for mode in insert default visual
        bind -M $mode \cf forward-char
    end
end

fish_user_key_bindings

set -gx EDITOR nvim

fish_add_path --path ~/.local/share/bob/nvim-bin
fish_add_path --path ~/.local/clang+llvm-18.1.6-aarch64-linux-gnu/bin/
fish_add_path --path /home/simon/.local/share/pnpm

# Zoxide
zoxide init --cmd cd fish | source

function ya
    set tmp (mktemp -t "yazi-cwd.XXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        cd "$cwd"
    end
    rm -f -- "$tmp"
end

starship init fish | source
