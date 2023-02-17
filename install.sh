#!/usr/bin/env bash

set -u

CURRENT_DIR=$(pwd)

source "$CURRENT_DIR/utils/helpers.sh"

# ANSII ESCAPE CODE COLOURS
greenColour='\033[0;32m'
redColour='\033[0;31m'
blueColour='\033[0;34m'
yellowColour='\033[1;33m'
purpleColour='\033[0;35m'
cyanColour='\033[0;36m'
grayColour='\033[0;37m'

endColour='\033[0m'

# Auto detect the package manager for the target OS
package_manager=$(whichPackageManager)
system_architecture=$(uname -m)

# Common folders to work
target_home_config_dir="$HOME/.config"
config_backup_folder=$target_home_config_dir/backup/${USER}.config

echo -e "${yellowColour}The package manager for the entire installation will be${endColour} ${cyanColour}$package_manager${endColour}"

function backupTargetConfigurationFolder() {
    if [ -d "$target_home_config_dir" ]; then
        echo -e "${greenColour}Detected existing .config folder${endColour}, ${yellowColour}creating backup on${endColour} ${cyanColour}$config_backup_folder"
        
        mkdir -p "$config_backup_folder" && cp -r "$target_home_config_dir" "$config_backup_folder"
    fi
}

function setupHotkeys() {
    #  REMEMBER TO UNCOMMENT THIS ON THE LINUX TARGET SYSTEM
    #$package_manager sxhkdrc
    backupTargetConfigurationFolder

    echo -e "${grayColour}Copying sxhkd configuration files in order to setup hotkeys...${endColour}"

    cp -r "$CURRENT_DIR/config/sxhkd" "$target_home_config_dir"

    echo -e "${greenColour} Hotkeys installed and configured with${endColour} ${cyanColour}[ sxhkd ]${endColour}"
}

function setupCustomTerminalFont() {
    echo -e "${grayColour}Downloading HackNerdFont from${endColour} ${blueColour}https://github.com/ryanoasis/nerd-fonts${endColour}"
   
    local fonts_dir="$HOME/.fonts"
    mkdir -p "$fonts_dir"
    curl -sLo Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hack.zip && unzip -oq Hack.zip -d "$fonts_dir" && rm Hack.zip

    echo -e "${greenColour} Fonts installed and configured in${endColour} ${cyanColour}[ $fonts_dir ]${endColour}"
}

function setupAndConfigureKitty() {
    echo -e "${grayColour}Installing and configuring kitty GPU based terminal...${endColour}"

    local kitty_dir=/opt/kitty
    local base_url=https://github.com/kovidgoyal/kitty/releases/download/v0.27.1
    local kitty_release=''

    case $system_architecture in
        arm64 | aarch64)
            kitty_release="kitty-0.27.1-arm64.txz"
        ;;
        64-bit | x86_64)
            kitty_release="kitty-0.27.1-x86_64.txz"
        ;;
        i386| i486| i586| i686)
        kitty_release="kitty-0.27.1-i686.txz"
        ;;
    esac
    
    curl -sLo kitty.txz "$base_url/$kitty_release"
    sudo mkdir -p $kitty_dir && sudo tar -xf kitty.txz -C $kitty_dir && rm kitty.txz
    sudo ln -s $kitty_dir/bin/kitty /usr/local/bin/kitty

    cp -r "$CURRENT_DIR/config/kitty" "$target_home_config_dir"

    echo -e "${greenColour} Kitty GPU based terminal installed and configured on${endColour} ${cyanColour}[ $(which kitty) ]${endColour}"
}

function setupZSH() {
    echo -e "${grayColour} Installing and configuring zsh terminal with powerlevel10k theme${endColour}"

    if [ -f "$HOME"/.zshrc ]; then
        echo -e "${greenColour}Detected existing .zshrc file${endColour}, ${yellowColour}creating backup on${endColour} ${cyanColour}$config_backup_folder"
        cp "$HOME"/.zshrc "$config_backup_folder"
    fi

    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME"/powerlevel10k 
    echo "source $HOME/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc
}

###
# START THE INSTALLATION AND CONFIGURATION PROCESS FOR THE NEW ENVIRONMENT
###
setupHotkeys
setupCustomTerminalFont
setupAndConfigureKitty
setupZSH