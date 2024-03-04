## Dependencies

- python3
- python3-venv
- imagemagick
- luarocks
- libevent-dev
- bison
- wget
- stow


## Add support for image preview in neovim
```sh
luarocks --local install magick
```

## Image support in terminal for ubuntu 22.04
See https://software.opensuse.org/download.html?project=home%3Ajustkidding&package=ueberzugpp
```sh
echo 'deb http://download.opensuse.org/repositories/home:/justkidding/xUbuntu_22.04/ /' | sudo tee /etc/apt/sources.list.d/home:justkidding.list
curl -fsSL https://download.opensuse.org/repositories/home:justkidding/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_justkidding.gpg > /dev/null
sudo apt update
sudo apt install ueberzugpp
```

## Install rust
```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### Rust programs
```sh
cargo install --locked yazi-fm && cargo install --locked bob-nvim && cargo install --locked starship && cargo install --locked zoxide
```

## Install latest neovim using Bob
```sh
bob install latest
```

## Install kitty (in ~/.local/kitty.app)
``` sh
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
```

symlink programs to ~/.local/bin which should ben in PATH:

```sh
ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
```

Copy a bunch of stuff to integrate kitty to DE (refer to https://sw.kovidgoyal.net/kitty/binary/)
```sh
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
```

## Install tmux
```sh
mkdir ~/compiled_programs/
wget -P ~/compiled_programs https://github.com/tmux/tmux/releases/download/3.4/tmux-3.4.tar.gz
cd ~/compiled_programs/ && tar xvf tmux-3.4.tar.gz && rm tmux-3.4.tar.gz
cd tmux-3.4 && ./configure
make release=1 -j8
sudo make release=1 install
```


