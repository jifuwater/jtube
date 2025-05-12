#!/bin/bash

# ANSI Colors
RED=$'\033[1;31m'
GREEN=$'\033[1;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[1;34m'
CYAN=$'\033[1;36m'
NC=$'\033[0m' # Reset

# Nerd Font Icons
ICON_TV=$'\uf16a '        
ICON_PACKAGE=$'\uf410'   
ICON_TUNE=$'\ueb4c'      
ICON_PLAY=$'\uf144'      
ICON_ERROR=$'\uf057'     

CHANNELS_FILE="channels.txt"

if [[ ! -f "$CHANNELS_FILE" ]]; then
  echo -e "${RED}${ICON_ERROR} [ERROR]${NC} File '${CHANNELS_FILE}' not found."
  echo -e "       Please create a file with one channel handle per line."
  exit 1
fi

echo -e "\n${BLUE}${ICON_TV} Latest videos from channels:${NC}\n"

video_display=()
video_values=()
total=$(grep -v -E '^\s*#|^\s*$' "$CHANNELS_FILE" | wc -l)
current=1

while IFS= read -r channel || [[ -n "$channel" ]]; do
  [[ -z "$channel" || "$channel" =~ ^# ]] && continue

  echo -ne "${CYAN}[$current/$total]${NC} Fetching from ${GREEN}${channel}${NC}...\r"

  url="https://www.youtube.com/${channel}/videos"

  output=$(yt-dlp --quiet --no-warnings --flat-playlist --playlist-end 2 \
            --print "%(id)s|%(title)s" "$url")

  if [[ -n "$output" ]]; then
    while IFS='|' read -r video_id title; do
      display="${GREEN}${channel}${NC} → ${YELLOW}${title}${NC}"
      video_display+=("$display")
      video_values+=("${channel}|${video_id}")
    done <<< "$output"
  else
    echo -e "${YELLOW}${channel}${NC} → ${RED}${ICON_ERROR} Error fetching videos.${NC}"
  fi

  ((current++))
done < "$CHANNELS_FILE"

echo -e "\n${CYAN}Choose a video to watch:${NC}"
select video in "${video_display[@]}"; do
  if [[ -n "$video" ]]; then
    index=$((REPLY - 1))
    selected="${video_values[$index]}"
    
    channel=$(echo "$selected" | cut -d'|' -f1)
    video_id=$(echo "$selected" | cut -d'|' -f2)
    video_url="https://www.youtube.com/watch?v=$video_id"

    echo -e "\n${BLUE}${ICON_PACKAGE} Available formats for the video:${NC}"
    yt-dlp --list-formats "$video_url"

    echo -ne "\n${CYAN}${ICON_TUNE} Enter desired format (e.g. 270+233): ${NC}"
    read format

    echo -e "\n${GREEN}${ICON_PLAY} Playing:${NC} ${channel} → ${BLUE}$video_url${NC}\n"
    mpv --ytdl-format="$format" "$video_url"
    break
  else
    echo -e "${RED}${ICON_ERROR} [ERROR]${NC} Invalid option. Please try again."
  fi
done

