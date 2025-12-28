#!/usr/bin/env nix-shell
#!nix-shell -i bash -p grub2 roboto imagemagick nix

set -euo pipefail

TARGET_WIDTH=1920
TARGET_HEIGHT=1200
ROBOTO_PATH=$(nix eval --raw nixpkgs#roboto.outPath)/share/fonts/truetype
ROBOTO_REGULAR_PATH="$ROBOTO_PATH/Roboto-Regular.ttf"
ROBOTO_BOLD_PATH="$ROBOTO_PATH/Roboto-Bold.ttf"

# Render the background from grub-background.png to grub-theme/background.png.
# It has a 16:10 aspect ratio for 1920x1200 screens.
# It has a rounded rectangle in the center which has a background blur effect amd is slightly darkened.
# It also has a "Choose operating system" text at the top.

# Create a temporary directory
TEMP_DIR=$(mktemp -d)

echo "Generating background..."

# Resize the original image to the target resolution
echo "  Resizing image to ${TARGET_WIDTH}x${TARGET_HEIGHT}..."
magick grub-background.png -resize ${TARGET_WIDTH}x${TARGET_HEIGHT}\! "$TEMP_DIR/resized.png"

# Create a blurred version of the resized image that's slightly darkened
echo "  Creating blurred image..."
magick "$TEMP_DIR/resized.png" -blur 0x$((TARGET_WIDTH*2/100)) -modulate 100,80 "$TEMP_DIR/blurred.png"

# Create a rounded rectangle mask in the temporary directory that spans from
# (30%, 20%) with width 30% and height 70% of the image dimensions
# The corners should have a radius of 2% of the width
echo "  Creating mask..."
magick -size ${TARGET_WIDTH}x${TARGET_HEIGHT} xc:black -fill white -draw "roundrectangle $((TARGET_WIDTH*30/100)),$((TARGET_HEIGHT*20/100)) $((TARGET_WIDTH*70/100)),$((TARGET_HEIGHT*90/100)) $((TARGET_WIDTH*2/100)),$((TARGET_WIDTH*2/100))" "$TEMP_DIR/mask.png"

# Composite the blurred image and the resized image using the mask
magick composite -compose CopyOpacity "$TEMP_DIR/mask.png" "$TEMP_DIR/blurred.png" "$TEMP_DIR/blurred_masked.png"
magick composite -compose Over "$TEMP_DIR/blurred_masked.png" "$TEMP_DIR/resized.png" "$TEMP_DIR/rounded.png"

# Finally, annotate the image with the text at the top center and nixos-logo.png at the bottom left, small size
echo "  Annotating image..."
magick "$TEMP_DIR/rounded.png" \
  \( nixos-logo.png -resize $((TARGET_HEIGHT*20/100))x \) -gravity SouthWest -geometry +$((TARGET_HEIGHT*1/100))+$((TARGET_HEIGHT*1/100)) -composite \
  -font "$ROBOTO_BOLD_PATH" -pointsize $((TARGET_HEIGHT*4/100)) -fill white -gravity North -annotate +0+$((TARGET_HEIGHT*15/100)) "Choose operating system" \
  -font "$ROBOTO_REGULAR_PATH" -pointsize $((TARGET_HEIGHT*2/100)) -fill "#ffffff88" -gravity North -annotate +0+$((TARGET_HEIGHT*90/100+12)) "navigate with arrow keys\n[enter] select · [e] edit command line · [c] terminal" \
  "grub-theme/background.png"

echo "Generated grub-theme/background.png"

# Generate nine 9-slice images (nw, n, ne, w, c, e, sw, s, se) for the terminal background of black
generate_9slice_bg() {
  local fill_color="$1"
  local corner_size="$2"
  local name_prefix="$3"
  local bg_width=$((corner_size*3))
  local bg_height=$((corner_size*3))
  
  magick -size ${bg_width}x${bg_height} xc:transparent -fill "$fill_color" -draw "roundrectangle 0,0 $((bg_width-1)),$((bg_height-1)) $corner_size,$corner_size" "$TEMP_DIR/rect.png"
  
  magick "$TEMP_DIR/rect.png" -crop ${corner_size}x${corner_size}+0+0 +repage \
    -alpha set -strip -colorspace sRGB \
    -define png:color-type=6 -define png:bit-depth=8 \
    -define png:exclude-chunks=iCCP,gAMA,cHRM,sRGB \
    "grub-theme/${name_prefix}_nw.png"
  magick "$TEMP_DIR/rect.png" -crop ${corner_size}x${corner_size}+${corner_size}+0 +repage \
    -alpha set -strip -colorspace sRGB \
    -define png:color-type=6 -define png:bit-depth=8 \
    -define png:exclude-chunks=iCCP,gAMA,cHRM,sRGB \
    "grub-theme/${name_prefix}_n.png"
  magick "$TEMP_DIR/rect.png" -crop ${corner_size}x${corner_size}+$((corner_size*2))+0 +repage \
    -alpha set -strip -colorspace sRGB \
    -define png:color-type=6 -define png:bit-depth=8 \
    -define png:exclude-chunks=iCCP,gAMA,cHRM,sRGB \
    "grub-theme/${name_prefix}_ne.png"
  magick "$TEMP_DIR/rect.png" -crop ${corner_size}x${corner_size}+0+${corner_size} +repage \
    -alpha set -strip -colorspace sRGB \
    -define png:color-type=6 -define png:bit-depth=8 \
    -define png:exclude-chunks=iCCP,gAMA,cHRM,sRGB \
    "grub-theme/${name_prefix}_w.png"
  magick "$TEMP_DIR/rect.png" -crop ${corner_size}x${corner_size}+${corner_size}+${corner_size} +repage \
    -alpha set -strip -colorspace sRGB \
    -define png:color-type=6 -define png:bit-depth=8 \
    -define png:exclude-chunks=iCCP,gAMA,cHRM,sRGB \
    "grub-theme/${name_prefix}_c.png"
  magick "$TEMP_DIR/rect.png" -crop ${corner_size}x${corner_size}+$((corner_size*2))+${corner_size} +repage \
    -alpha set -strip -colorspace sRGB \
    -define png:color-type=6 -define png:bit-depth=8 \
    -define png:exclude-chunks=iCCP,gAMA,cHRM,sRGB \
    "grub-theme/${name_prefix}_e.png"
  magick "$TEMP_DIR/rect.png" -crop ${corner_size}x${corner_size}+0+$((corner_size*2)) +repage \
    -alpha set -strip -colorspace sRGB \
    -define png:color-type=6 -define png:bit-depth=8 \
    -define png:exclude-chunks=iCCP,gAMA,cHRM,sRGB \
    "grub-theme/${name_prefix}_sw.png"
  magick "$TEMP_DIR/rect.png" -crop ${corner_size}x${corner_size}+${corner_size}+$((corner_size*2)) +repage \
    -alpha set -strip -colorspace sRGB \
    -define png:color-type=6 -define png:bit-depth=8 \
    -define png:exclude-chunks=iCCP,gAMA,cHRM,sRGB \
    "grub-theme/${name_prefix}_s.png"
  magick "$TEMP_DIR/rect.png" -crop ${corner_size}x${corner_size}+$((corner_size*2))+$((corner_size*2)) +repage \
    -alpha set -strip -colorspace sRGB \
    -define png:color-type=6 -define png:bit-depth=8 \
    -define png:exclude-chunks=iCCP,gAMA,cHRM,sRGB \
    "grub-theme/${name_prefix}_se.png"
}

echo "Generating terminal background..."
generate_9slice_bg "black" 30 "terminal_bg"

echo "Generating selection box background..."
generate_9slice_bg "#02283b" 24 "select"

echo "Generating transparent selection box background..."
generate_9slice_bg "#00000000" 24 "select_transparent"

# Clean up the temporary directory
rm -rf "$TEMP_DIR"

echo "Generating fonts..."

grub-mkfont -o grub-theme/Roboto-24.pf2 -s 24 "$ROBOTO_REGULAR_PATH"