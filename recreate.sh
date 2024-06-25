#!/bin/bash

# ANSI renk kodları
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Önceden sudo komutunun şifre sormaması için gerekli ayarların yapılmış olması gerekir

# Sistemi güncelle
echo -e "${YELLOW}Sistem güncelleniyor...${NC}"
sudo apt update -y
sudo apt upgrade -y

# Gerekli dosyaların varlığını kontrol et
echo -e "${YELLOW}Gerekli dosyaların varlığı kontrol ediliyor...${NC}"
if [ ! -f repoList.txt ]; then
  echo -e "${RED}repoList.txt dosyası bulunamadı. Lütfen dosyanın mevcut olduğundan emin olun.${NC}"
  exit 1
fi

if [ ! -f packageList.txt ]; then
  echo -e "${RED}packageList.txt dosyası bulunamadı. Lütfen dosyanın mevcut olduğundan emin olun.${NC}"
  exit 1
fi

# Yeni depoları ekle
echo -e "${YELLOW}Yeni depolar ekleniyor...${NC}"
while read -r line; do
  sudo add-apt-repository -y "$line"
done < repoList.txt

# i3 Window Manager deposunu ekle
echo -e "${YELLOW}i3 Window Manager deposu ekleniyor...${NC}"
/usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2024.03.04_all.deb keyring.deb SHA256:f9bb4340b5ce0ded29b7e014ee9ce788006e9bbfe31e96c09b2118ab91fca734
sudo apt install -y ./keyring.deb
echo "deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list

# vscode deposunu ekle
echo -e "${YELLOW}VS Code deposu ekleniyor...${NC}"
sudo apt-get install -y wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg
sudo apt install -y apt-transport-https

# Paket listesini güncelle ve gerekli paketleri yükle
echo -e "${YELLOW}Paket listesi güncelleniyor ve gerekli paketler yükleniyor...${NC}"
sudo apt update -y
sudo apt upgrade -y

# Paket listesini import et ve paketleri yükle
echo -e "${YELLOW}Paket listesi import ediliyor ve paketler yükleniyor...${NC}"
sudo dpkg --set-selections < packageList.txt
sudo apt-get -u dselect-upgrade -y

# .config klasörünü kopyala
echo -e "${YELLOW}.config klasörü kopyalanıyor...${NC}"
if [ -d ".config" ]; then
  cp -r .config/* ~/.config/
  echo -e "${GREEN}.config klasörü başarıyla kopyalandı!${NC}"
else
  echo -e "${RED}.config klasörü bulunamadı. Lütfen dosyanın mevcut olduğundan emin olun.${NC}"
fi

# .zshrc dosyasını kopyala
echo -e "${YELLOW}.zshrc dosyası kopyalanıyor...${NC}"
if [ -f ".zshrc" ]; then
  cp .zshrc ~/
  echo -e "${GREEN}.zshrc dosyası başarıyla kopyalandı!${NC}"
else
  echo -e "${RED}.zshrc dosyası bulunamadı. Lütfen dosyanın mevcut olduğundan emin olun.${NC}"
fi

# preCompiled klasöründeki çalıştırılabilir dosyaları ~/bin/ klasörüne kopyala
echo -e "${YELLOW}preCompiled klasöründeki çalıştırılabilir dosyalar ~/bin/ klasörüne kopyalanıyor...${NC}"
if [ -d "preCompiled" ]; then
  mkdir -p ~/bin
  cp preCompiled/* ~/bin/
  chmod +x ~/bin/*
  echo -e "${GREEN}preCompiled klasöründeki dosyalar başarıyla kopyalandı!${NC}"
else
  echo -e "${RED}preCompiled klasörü bulunamadı. Lütfen dosyanın mevcut olduğundan emin olun.${NC}"
fi

# Temizleme işlemleri
echo -e "${YELLOW}Temizleme işlemleri yapılıyor...${NC}"
sudo apt autoremove -y
sudo apt clean

echo -e "${GREEN}Depolar eklendi ve paketler başarıyla yüklendi!${NC}"
