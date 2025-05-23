#!/bin/bash

# === Configuration ===
MODEL_NAME=${1:-"my-model.onnx"}
LABELS_NAME=${2:-"labels.txt"}

SRC_MODEL_DIR="./source-models"
MODEL_PATH="$SRC_MODEL_DIR/$MODEL_NAME"
LABELS_PATH="$SRC_MODEL_DIR/$LABELS_NAME"

OTA_DIR="ota-package"
ARCHIVE_NAME="model-ota.tar.gz"

# === Create workspace ===
rm -rf "$OTA_DIR"
mkdir -p "$OTA_DIR/models"

# === Copy files ===
if [[ ! -f "$MODEL_PATH" ]]; then
  echo "[ERROR] Model file not found: $MODEL_PATH"
  exit 1
fi

cp "$MODEL_PATH" "$OTA_DIR/models/"
echo "$MODEL_NAME" > "$OTA_DIR/models/current-model.txt"

if [[ -f "$LABELS_PATH" ]]; then
  cp "$LABELS_PATH" "$OTA_DIR/models/"
else
  echo "[INFO] No labels.txt provided. Proceeding without it."
fi

# === Create install.sh ===
cat << 'EOF' > "$OTA_DIR/install.sh"
#!/bin/bash
SNAP_COMMON=${SNAP_COMMON:-/var/snap/iotconnect/common}
MODEL_SRC=$(pwd)/models
MODEL_DST="$SNAP_COMMON/models"

echo "[INSTALL] SNAP_COMMON is $SNAP_COMMON"
echo "[INSTALL] Moving models to $MODEL_DST"

mkdir -p "$MODEL_DST"

if [ -d "$MODEL_SRC" ]; then
  cp -v "$MODEL_SRC"/*.onnx "$MODEL_DST" 2>/dev/null
  cp -v "$MODEL_SRC"/labels.txt "$MODEL_DST" 2>/dev/null
  cp -v "$MODEL_SRC"/current-model.txt "$MODEL_DST" 2>/dev/null
else
  echo "[INSTALL] ERROR: models/ folder not found in OTA package"
  exit 1
fi

echo "[INSTALL] Model OTA complete."
EOF

chmod +x "$OTA_DIR/install.sh"

# === Package ===
tar -czvf "$ARCHIVE_NAME" -C "$OTA_DIR" .

echo ""
echo "[DONE] OTA archive created: $ARCHIVE_NAME"
echo "       Contains:"
tar -tzf "$ARCHIVE_NAME"
