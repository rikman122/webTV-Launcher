#!/bin/bash

PROFILE_NAME="webtv"
PROFILE_DIR="$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox/$PROFILE_NAME"
UA='Mozilla/5.0 (PS4; Leanback Shell) Gecko/20100101 Firefox/65.0 LeanbackShell/01.00.01.75 Sony PS4/ (PS4, , no, CH)'
CURL_OPTS="--retry 3 --retry-delay 5 --fail --connect-timeout 10 --max-time 60"

sudo apt update
sudo apt install -y wget

if ! command -v firefox >/dev/null 2>&1; then
  # Firefox not installed, proceed with installation
  echo "Installing Firefox from Official Mozilla Repo"
  sudo install -d -m 0755 /etc/apt/keyrings
  wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
  echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
  echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
  ' | sudo tee /etc/apt/preferences.d/mozilla
  sudo apt update && sudo apt install firefox
else
  echo "Firefox is already installed."
fi

sudo apt install -y playerctl python3 python3-flask

# Check if the profile already exists
if [ -d "$PROFILE_DIR" ]; then
  echo "Profile already exists at $PROFILE_DIR. Removing old installation..."
  rm -rf "$PROFILE_DIR"
fi

# Create the profile
echo "Creating new profile \"$PROFILE_NAME\""
mkdir -p "$PROFILE_DIR"
firefox --no-remote -CreateProfile "$PROFILE_NAME $PROFILE_DIR" >/dev/null 2>&1
mkdir -p "$PROFILE_DIR/extensions"

echo

# Download and install the extensions
UBLOCK_XPI_URL="https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
echo "Downloading uBlock Origin from $UBLOCK_XPI_URL"
curl $CURL_OPTS -L "$UBLOCK_XPI_URL" \
     -o "$PROFILE_DIR/extensions/uBlock0@raymondhill.net.xpi"

echo

SPONSORBLOCKER_XPI_URL="https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi"
echo "Downloading SponsorBlocker from $SPONSORBLOCKER_XPI_URL"
curl $CURL_OPTS -L "$SPONSORBLOCKER_XPI_URL" \
     -o "$PROFILE_DIR/extensions/sponsorBlocker@ajay.app.xpi"

echo

# Create user.js with necessary preferences
cat > "$PROFILE_DIR/user.js" <<EOF
user_pref("general.useragent.override", "$UA");
user_pref("media.eme.enabled", true);
user_pref("media.gmp-widevinecdm.enabled", true);
user_pref("media.gmp-widevinecdm.autoupdate", true);
user_pref("extensions.autoDisableScopes", 0);
user_pref("extensions.enabledScopes", 15);
user_pref("browser.startup.homepage", "http://localhost:8000");
user_pref("browser.startup.page", 1); # 1 = homepage, 3 = restore previous session
user_pref("media.autoplay.default", 0); # 0 = Allow all autoplay
EOF


# Check if the webtv directory already exists
if [ -d "$HOME/webtv" ]; then
  read -rp "WebTV directory already exists. Do you want to remove it and clone again? [y/N]: " REMOVE_WEBTV_REPLY
  if [[ $REMOVE_WEBTV_REPLY =~ ^[Yy]$ ]]; then
    echo "Removing old installation..."
    rm -rf "$HOME/webtv"
    cd $HOME
    git clone https://github.com/rikman122/webtv.git
  else
    echo "Keeping existing webtv directory. Skipping clone."
  fi
else
  cd $HOME
  git clone https://github.com/rikman122/webtv.git
fi

# Prompt to add webtv to autostart
read -rp "Do you want to add WebTV to autostart? [y/N]: " AUTOSTART_REPLY
if [[ $AUTOSTART_REPLY =~ ^[Yy]$ ]]; then
  AUTOSTART_DIR="$HOME/.config/autostart"
  mkdir -p "$AUTOSTART_DIR"
  cat > "$AUTOSTART_DIR/webtv.desktop" <<EOF
[Desktop Entry]
Exec=$HOME/webtv/start.sh
Icon=dialog-scripts
Name=WebTV Launcher
Path=
Type=Application
X-KDE-AutostartScript=true
EOF
  echo "WebTV has been added to autostart."
else
  echo "WebTV was not added to autostart."
fi