#!/bin/bash
#
# Connect a build server to Thunderstorm1708/pong-rom-ci as its self-hosted
# runner (labels: self-hosted, pong-builder), so the ROM builds and server
# tasks pushed to that repository run on this machine.
#
# usage: bash ci-runner.sh <registration-token>
#   (set RUNNER_DIR=/some/dir to choose where the runner is installed)
#   The token comes from GitHub: pong-rom-ci -> Settings -> Actions ->
#   Runners -> New self-hosted runner (the --token value). It is valid for
#   one hour and is only used once, to register.
#
set -e

TOKEN="$1"
REPO_URL=https://github.com/Thunderstorm1708/pong-rom-ci
DIR="${RUNNER_DIR:-$HOME/actions-runner}"

if [ -z "$TOKEN" ]; then
    echo "usage: bash ci-runner.sh <registration-token>"
    exit 1
fi

case "$(uname -m)" in
    x86_64) ARCH=x64 ;;
    aarch64) ARCH=arm64 ;;
    *) echo "unsupported CPU: $(uname -m)"; exit 1 ;;
esac

for tool in curl tar git; do
    command -v "$tool" >/dev/null || { echo "'$tool' is needed: install it first"; exit 1; }
done

# The runner refuses to start unless every directory above it is readable.
# Shared servers often lock /home, so fall back to /tmp/runner-$USER.
readable_path() {
    d="$1"
    while [ "$d" != "/" ]; do
        d=$(dirname "$d")
        ls "$d" >/dev/null 2>&1 || return 1
    done
}
if [ -z "$RUNNER_DIR" ] && ! readable_path "$DIR"; then
    DIR="/tmp/runner-$(id -un)"
    echo "$HOME is inside a locked directory; installing the runner in $DIR instead."
fi

mkdir -p "$DIR"
cd "$DIR"

if [ ! -x ./config.sh ]; then
    VER=$(curl -fsSL https://api.github.com/repos/actions/runner/releases/latest | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p')
    [ -n "$VER" ] || { echo "could not find the latest runner version"; exit 1; }
    echo "Downloading GitHub Actions runner $VER ($ARCH)..."
    curl -fsSLo runner.tar.gz "https://github.com/actions/runner/releases/download/v$VER/actions-runner-linux-$ARCH-$VER.tar.gz"
    tar xzf runner.tar.gz
    rm -f runner.tar.gz
fi

# Register (replaces an old runner with the same name)
./config.sh --unattended --replace \
    --url "$REPO_URL" \
    --token "$TOKEN" \
    --name "$(hostname)" \
    --labels pong-builder \
    --work _work

# Keep it running after the SSH session ends
pkill -f "$DIR/bin/Runner.Listener" 2>/dev/null || true
setsid nohup ./run.sh > "$DIR/runner.log" 2>&1 < /dev/null &
sleep 5

if grep -q "Listening for Jobs" "$DIR/runner.log"; then
    echo ""
    echo "✅ Connected: this server now runs the jobs of pong-rom-ci."
else
    echo "Started; check $DIR/runner.log if it does not show up as Idle on GitHub."
fi
echo "To start it again after a reboot: cd $DIR && setsid nohup ./run.sh > runner.log 2>&1 &"
