#!/bin/bash

# Останавливать скрипт при любой ошибке
set -e

# Цвета для красоты в терминале
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m' # Без цвета

print_msg() {
    echo -e "${GREEN}==> $1${NC}"
}

print_msg "=== Запуск установки твоей сборки Hyprland ==="

# 1. Обновление системы и базовые утилиты
print_msg "Обновление системы и установка git, base-devel..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm git base-devel wget

# 2. Установка официальных пакетов из packages.txt
if [ -f "packages.txt" ]; then
    print_msg "Установка программ из packages.txt (pacman)..."
    sudo pacman -S --needed --noconfirm - < packages.txt
else
    print_msg "Внимание: файл packages.txt не найден!"
fi

# 3. Установка AUR-помощника (yay), если он еще не установлен
if ! command -v yay &> /dev/null; then
    print_msg "Установка AUR-помощника (yay)..."
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
    cd ..
    rm -rf yay-bin
else
    print_msg "yay уже установлен."
fi

# 4. Установка AUR пакетов из aur-packages.txt
if [ -f "aur-packages.txt" ]; then
    print_msg "Установка пакетов из aur-packages.txt (AUR)..."
    yay -S --needed --noconfirm - < aur-packages.txt
else
    print_msg "Внимание: файл aur-packages.txt не найден!"
fi

# 5. Копирование конфигов, тем, иконок и курсоров
print_msg "Копирование твоих настроек, тем и курсоров..."

mkdir -p ~/.config
mkdir -p ~/.themes
mkdir -p ~/.icons
mkdir -p ~/.local/share/themes
mkdir -p ~/.local/share/icons

# Копируем конфиги (.config)
if [ -d "home/.config" ]; then
    cp -r home/.config/* ~/.config/
    print_msg "Конфиги из home/.config успешно перенесены в ~/.config/"
else
    print_msg "Папка home/.config не найдена в репозитории!"
fi

# Копируем темы
if [ -d "home/.themes" ]; then
    cp -r home/.themes/* ~/.themes/
fi
if [ -d "home/.local/share/themes" ]; then
    cp -r home/.local/share/themes/* ~/.local/share/themes/
fi

# Копируем иконки и курсоры
if [ -d "home/.icons" ]; then
    cp -r home/.icons/* ~/.icons/
    print_msg "Иконки и курсоры успешно перенесены в ~/.icons/"
fi
if [ -d "home/.local/share/icons" ]; then
    cp -r home/.local/share/icons/* ~/.local/share/icons/
fi

# 6. Включение системных служб
print_msg "Включение дисплейного менеджера (SDDM) и сети..."
sudo systemctl enable sddm.service
sudo systemctl enable NetworkManager.service

print_msg "=== УСТАНОВКА УСПЕШНО ЗАВЕРШЕНА! ==="
read -p "Хотите перезагрузить компьютер прямо сейчас? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    systemctl reboot
fi
