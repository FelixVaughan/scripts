#!/bin/bash

check_dependency() {
    local dep=$1
    local package=${2:-$dep}  # Use first arg as package name if second not provided
    
    if ! which "$dep" >/dev/null 2>&1; then
        echo "Error: $dep is not installed. Please install it first."
        echo "On Ubuntu/Debian: sudo apt install $package"
        echo "On Arch: sudo pacman -S $package"
        echo "On Fedora: sudo dnf install $package"
        exit 1
    fi
}

# Check required dependencies
check_dependency playerctl
check_dependency sxhkd

# Create sxhkd config directory and file if they don't exist
mkdir -p "$HOME/.config/sxhkd" && touch "$HOME/.config/sxhkd/sxhkdrc"

# Set spotify control command
SPOTIFY_CTL="playerctl -p spotify"

# Function to add keybinding if it doesn't exist
add_keybinding() {
    local key=$1
    local command=$2
    
    # Check if binding already exists in sxhkdrc
    if ! grep -Fq "super + shift + $key" "$HOME/.config/sxhkd/sxhkdrc"; then
        echo -e "\nsuper + shift + $key\n    $command" >> "$HOME/.config/sxhkd/sxhkdrc"
    fi
}

# Define commands and their corresponding keys
declare -A commands=(
    ["i"]="$SPOTIFY_CTL position 10-"
    ["p"]="$SPOTIFY_CTL position 10+"
    ["o"]="$SPOTIFY_CTL play-pause"
    ["j"]="$SPOTIFY_CTL previous"
    ["l"]="$SPOTIFY_CTL next"
    ["k"]="$SPOTIFY_CTL loop Track"
    ["comma"]="$SPOTIFY_CTL volume 0.1-"
    ["period"]="$SPOTIFY_CTL volume 0.1+"
)

# Add each keybinding
for key in "${!commands[@]}"; do
    add_keybinding "$key" "${commands[$key]}"
done

# Reload sxhkd
if pgrep -x "sxhkd" > /dev/null; then
    pkill -USR1 -x sxhkd
    echo "Spotify controls have been set up and sxhkd reloaded!"
else
    echo "Warning: sxhkd is not running. Starting..."
    nohup sxhkd &> /dev/null &
fi

    