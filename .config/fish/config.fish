fish_vi_key_bindings
set fish_greeting
if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -gx EDITOR nvim

fish_add_path --path ~/.local/share/bob/nvim-bin

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
