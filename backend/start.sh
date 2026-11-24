#!/bin/sh
# Start script for the ChatDev backend on Railway.
# Keeps every piece of state on the volume at $CHATDEV_DATA_DIR and drops root.
set -eu

DATA="${CHATDEV_DATA_DIR:-/data}"
PORT="${PORT:-6400}"

if [ -z "${API_KEY:-}" ]; then
  echo "chatdev: API_KEY is empty. Set your LLM provider key on the backend service." >&2
  exit 1
fi
export BASE_URL="${BASE_URL:-https://api.openai.com/v1}"
export MODEL_NAME="${MODEL_NAME:-gpt-4o}"

mkdir -p "$DATA/yaml_instance" "$DATA/WareHouse" "$DATA/data" "$DATA/logs" "$DATA/temp" \
         "$DATA/functions/function_calling" "$DATA/cache/uv" "$DATA/home"

# Workflows: add any shipped workflow the volume doesn't have yet; never overwrite yours.
cp -R -n /opt/chatdev-defaults/yaml_instance/. "$DATA/yaml_instance/"
# Built-in tools: refresh from the image on every start so updates apply; your own files stay.
cp -R /opt/chatdev-defaults/function_calling/. "$DATA/functions/function_calling/"

for d in yaml_instance WareHouse data logs temp; do
  rm -r "/app/$d" 2>/dev/null || true
  ln -sfn "$DATA/$d" "/app/$d"
done
rm -r /app/functions/function_calling 2>/dev/null || true
ln -sfn "$DATA/functions/function_calling" /app/functions/function_calling

if [ "$(stat -c %u "$DATA")" != "1000" ] || [ "$(stat -c %u "$DATA/yaml_instance")" != "1000" ]; then
  chown -R 1000:1000 "$DATA"
fi
chown -h 1000:1000 /app/yaml_instance /app/WareHouse /app/data /app/logs /app/temp /app/functions/function_calling

export HOME="$DATA/home" UV_CACHE_DIR="$DATA/cache/uv" TEMP_CODE_DIR="$DATA/temp"
cd /app
echo "chatdev: backend starting, data in $DATA"
exec setpriv --reuid=1000 --regid=1000 --init-groups python /usr/local/bin/chatdev-serve.py
