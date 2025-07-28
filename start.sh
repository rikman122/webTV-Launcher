#!/bin/bash

# Activate python environment if needed (uncomment and edit the next line if you use venv)
# source "$HOME/webtv/venv/bin/activate"

cd "$HOME/webtv"
export DISPLAY=:0
export XAUTHORITY="$HOME/.Xauthority"

# Stop the running webtv Flask app
pkill -f "$HOME/webtv/app.py"

# Start the Flask app in the background
/usr/bin/python3 "$HOME/webtv/app.py" &
firefox --kiosk -P webtv http://localhost:8000
