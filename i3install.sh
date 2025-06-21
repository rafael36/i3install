#!/bin/bash

# Habilitar o repositório multilib, se ainda não estiver habilitado
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
  echo "Habilitando o repositório multilib..."
  sudo sed -i '/#\[multilib\]/,/#Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf
  sudo pacman -Sy
else
  echo "Repositório multilib já habilitado."
fi

sudo pacman -S --noconfirm git wget

# ---------- Instalação de pacotes ----------

pacotes=(
  # Navegadores e utilitários básicos
  "firefox" "chromium" "git" "go" "jq" "ark" "qbittorrent" "noto-fonts-extra" "noto-fonts" "noto-fonts-cjk" "noto-fonts-emoji" "ttf-dejavu" "ttf-liberation" "ttf-jetbrains-mono-nerd" "nano" "btop" "psensor"

  # Ambiente gráfico X11 e drivers
  "xorg-server" "xorg-xinit" "xorg-apps" "xf86-video-amdgpu" "xf86-video-ati" "xf86-input-libinput"

  # Som e multimídia
  "pulsemixer" "pavucontrol" "vlc" "mpv" "lib32-libpulse" "vulkan-radeon" "amdvlk" "lib32-amdvlk"

  # Ferramentas úteis
  "docker" "python3" "python-pip" "fuse2" "scrot" "btop" "nemo"

  # Wine e utilitários para rodar apps Windows
  "wine-staging" "winetricks" "wine-mono" "wine-gecko" "lib32-alsa-plugins" "alsa-utils"

  # Gerenciador de janelas e utilitários gráficos
  "i3" "i3status" "i3lock" "dmenu" "picom" "alacritty" "cliphist" "tigervnc"

  # Gerenciador de arquivos
  "nemo" 

  # Outros
  "zerotier-one" "steam"
)




for pacote in "${pacotes[@]}"; do
  echo "Instalando $pacote..."
  sudo pacman -S --noconfirm "$pacote"
done

echo "Todos os pacotes foram instalados!"

# ---------- Extração e movimentação dos arquivos de configuração ----------
wget https://github.com/rafael36/i3install/raw/refs/heads/main/configpasta.tar.gz
tar -xvf configpasta.tar.gz

mkdir -p \
  /home/rafael/.config/alacritty \

tar -xf MyBreeze-Dark-GTK.tar
mv alacritty.yml /home/rafael/.config/alacritty
mv alacritty.toml /home/rafael/.config/alacritty

# ---------- Ambiente virtual Python ----------
python -m venv /home/rafael/venv
echo "source /home/rafael/venv/bin/activate" >>/home/rafael/.bashrc
sed -i "1s|^|VIRTUAL_ENV_DISABLE_PROMPT=1\n|" /home/rafael/venv/bin/activate
/home/rafael/venv/bin/pip install yt-dlp selenium bs4

# ---------- Montagem automática do HD ----------
sudo mkdir -p /mnt/hd2
sudo chmod 777 /mnt/hd2
sudo mount /dev/sdb1 /mnt/hd2

# Garantir entrada no fstab
if ! grep -q "UUID=f8e32812-2c81-45fb-81a2-20287ac6fd08" /etc/fstab; then
  echo "UUID=f8e32812-2c81-45fb-81a2-20287ac6fd08  /mnt/hd2  ext4  defaults,noatime  0  2" | sudo tee -a /etc/fstab
fi

# ---------- AstroVim ----------
git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
rm -rf ~/.config/nvim/.git
nvim

sudo bash <<'EOF'
# ---------- Docker ----------
mkdir -p /etc/docker
mv daemon.json /etc/docker
usermod -aG docker rafael

# ---------- Systemctl ----------
ln -sf /usr/lib/systemd/system/zerotier-one.service /etc/systemd/system/multi-user.target.wants/zerotier-one.service
ln -sf /usr/lib/systemd/system/docker.service /etc/systemd/system/multi-user.target.wants/docker.service
EOF

# ---------- LazyVim ----------
git clone https://github.com/LazyVim/starter ~/.config/nvim

# ---------- Instalação de pacotes do AUR ----------
mkdir -p /home/rafael/aur-builds
cd /home/rafael/aur-builds

repos_aur=(
  "yay"
)

for repo in "${repos_aur[@]}"; do
  git clone https://aur.archlinux.org/$repo.git
  cd $repo && makepkg -si --noconfirm && cd ..
done

rm -rf /home/rafael/aur-builds

yay -S --noconfirm google-chrome brave-bin parsec-bin sunshine 

echo "Instalação concluída!"

