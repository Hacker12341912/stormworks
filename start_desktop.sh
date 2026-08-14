#!/usr/bin/env bash
set -euo pipefail
# Robust startup script: stop related processes, ensure user runtime,
# start user PulseAudio + virtual sink, start VNC, websockify (noVNC),
# and a low-latency ffmpeg Opus audio stream that monitors the virtual sink.

RUNTIME_DIR=/run/user/$(id -u)
export XDG_RUNTIME_DIR="$RUNTIME_DIR"

# Ensure runtime dir exists and is writable by this user
sudo mkdir -p "$RUNTIME_DIR" || true
sudo chown $(id -u):$(id -g) "$RUNTIME_DIR" || true
chmod 700 "$RUNTIME_DIR" || true

# Kill any existing related processes (safe to run repeatedly)
pkill -f "Xtigervnc|vncserver|websockify|ffmpeg|pulseaudio|xrdp|xvnc" || true
sleep 1

# Start a user PulseAudio instance (stop any stray instance first)
if command -v pulseaudio >/dev/null 2>&1; then
  pkill -f pulseaudio || true
  sleep 1
  env XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" pulseaudio --start 2>/tmp/pulseaudio_start.log || true
fi

# Create or reuse a null sink named codespace_sink and set it default
if command -v pactl >/dev/null 2>&1; then
  # load module only if sink doesn't already exist
  if ! env XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" pactl list short sinks | grep -q codespace_sink; then
    env XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" pactl load-module module-null-sink sink_name=codespace_sink sink_properties=device.description="Codespace_Virtual_Sink" || true
  fi
  env XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" pactl set-default-sink codespace_sink || true
fi

# Start (or restart) VNC server on :1
if command -v vncserver >/dev/null 2>&1; then
  vncserver -kill :1 >/dev/null 2>&1 || true
  sleep 1
  vncserver :1 -geometry 1280x720 -depth 24 >/tmp/vncserver.log 2>&1 || true
else
  echo "vncserver not found" >&2
fi
sleep 1

# Start websockify (noVNC webroot)
WEBDIR=/usr/share/novnc
WS_PORT=6082
if command -v websockify >/dev/null 2>&1; then
  pkill -f "websockify --web=$WEBDIR $WS_PORT" || true
  nohup websockify --web="$WEBDIR" $WS_PORT localhost:5901 >/tmp/websockify.log 2>&1 &
else
  echo "websockify not found" >&2
fi
sleep 1

# Start xrdp server for RDP remote desktop access
if command -v xrdp >/dev/null 2>&1; then
  sudo service xrdp restart 2>/tmp/xrdp.log || sudo systemctl restart xrdp 2>/tmp/xrdp.log || true
  echo "xrdp started on port 3389" 
else
  echo "xrdp not found" >&2
fi
sleep 1

# Launch Microsoft Edge in the VNC environment (optional, background process)
if command -v microsoft-edge-stable >/dev/null 2>&1; then
  export DISPLAY=:1
  nohup microsoft-edge-stable --no-sandbox --disable-gpu 2>/tmp/edge.log &
  echo "Microsoft Edge launched in background"
else
  echo "Microsoft Edge not found" >&2
fi
sleep 1

# Start ffmpeg streaming Opus from the virtual sink monitor.
# Wait for the monitor source to appear (retry a few times)
FF_PORT=9002
MONITOR_NAME="codespace_sink.monitor"
if command -v ffmpeg >/dev/null 2>&1; then
  env XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" pkill -f "ffmpeg.*$FF_PORT" || true
  # wait for monitor source
  found=0
  for i in $(seq 1 10); do
    if command -v pactl >/dev/null 2>&1 && env XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" pactl list short sources | grep -q "$MONITOR_NAME"; then
      found=1
      break
    fi
    sleep 1
  done
  if [ "$found" -eq 1 ]; then
    nohup env XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" ffmpeg -hide_banner -loglevel warning -fflags nobuffer -flags low_delay -probesize 32 -analyzeduration 0 -f pulse -i "$MONITOR_NAME" -c:a libopus -b:a 64000 -ar 48000 -ac 2 -f ogg -content_type audio/ogg -listen 1 "http://0.0.0.0:$FF_PORT" >/tmp/ffmpeg_opus.log 2>&1 &
  else
    # fallback: try default Pulse input but warn
    echo "Warning: monitor $MONITOR_NAME not found; starting ffmpeg on default input" >&2
    nohup env XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" ffmpeg -hide_banner -loglevel warning -fflags nobuffer -flags low_delay -probesize 32 -analyzeduration 0 -f pulse -i default -c:a libopus -b:a 64000 -ar 48000 -ac 2 -f ogg -content_type audio/ogg -listen 1 "http://0.0.0.0:$FF_PORT" >/tmp/ffmpeg_opus.log 2>&1 &
  fi
else
  echo "ffmpeg not found" >&2
fi

echo "Startup complete. Web: http://localhost:$WS_PORT  Audio: http://0.0.0.0:$FF_PORT  RDP: localhost:3389"
echo "Logs: /tmp/websockify.log /tmp/ffmpeg_opus.log /tmp/pulseaudio_start.log /tmp/vncserver.log /tmp/xrdp.log /tmp/edge.log"
