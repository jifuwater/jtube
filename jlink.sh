#!/bin/bash

# ANSI Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No color (reset)

# Title
echo -e "${CYAN}=============================="
echo -e "   YouTube Video Player"
echo -e "==============================${NC}"

# Ask for YouTube link
echo -e "${YELLOW}Enter the YouTube link:${NC}"
read -p "> " url

# Show available formats
echo -e "${GREEN}Fetching available formats...${NC}"
yt-dlp --list-formats "$url"

# Ask user for the desired format
echo -e "${YELLOW}Enter the desired format (e.g. 270+233):${NC}"
read -p "> " format

# Play the video with MPV
echo -e "${GREEN}Starting playback with MPV...${NC}"
mpv --ytdl-format="$format" "$url"

