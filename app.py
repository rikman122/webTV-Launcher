from flask import Flask, render_template, request
import subprocess
import json
import os

app = Flask(__name__)

def load_apps():
    with open("apps.json", "r") as f:
        return json.load(f)

@app.route("/")
def index():
    apps = load_apps()
    return render_template("index.html", apps=apps)

@app.route("/launch/<app_name>", methods=["GET", "POST"])
def launch(app_name):
    apps = load_apps()
    if app_name not in apps:
        return "App not found", 404
    if app_name == "Desktop":
        subprocess.Popen(["pkill", "-f", "firefox"])
        return "OK"
    if app_name == "Shutdown":
        subprocess.Popen(["systemctl", "poweroff"])
        return "OK"
    app_meta = apps[app_name]
    if app_meta.get("type") == "native":
        command = app_meta.get("command")
        if command:
            subprocess.Popen(command.split())
        return "OK"

@app.route("/media_control", methods=["POST"])
def media_control():
    data = request.json
    command = data.get("command")
    if command not in ["playpause", "next", "prev"]:
        return "Invalid command", 400

    playerctl_map = {
        "playpause": "play-pause",
        "next": "next",
        "prev": "previous"
    }
    playerctl_cmd = playerctl_map[command]

    # Use playerctl to control Firefox media
    subprocess.Popen([
        "playerctl", "-p", "firefox", playerctl_cmd
    ])
    return "OK"

@app.route("/media_status", methods=["GET"])
def media_status():
    try:
        # Query playerctl for Firefox playback status
        result = subprocess.run([
            "playerctl", "-p", "firefox", "status"
        ], capture_output=True, text=True, timeout=2)
        status = result.stdout.strip()
        # Possible values: 'Playing', 'Paused', 'Stopped', or ''
        return {"status": status}
    except Exception as e:
        return {"status": "error", "error": str(e)}, 500

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="WebTV Launcher")
    parser.add_argument('--debug', action='store_true', help='Enable Flask debug mode')
    args = parser.parse_args()
    app.run(host="0.0.0.0", port=8000, debug=args.debug)