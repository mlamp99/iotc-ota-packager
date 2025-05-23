#!/bin/bash

# === Configuration ===
SRC_MODEL_DIR="./source-models"
OTA_DIR="ota-package"
ARCHIVE_NAME="model-ota.tar.gz"

# === Locate files ===
MODEL_PATH=$(find "$SRC_MODEL_DIR" -maxdepth 1 -name "*.onnx" | head -n 1)
LABELS_PATH=$(find "$SRC_MODEL_DIR" -maxdepth 1 -name "labels.txt" | head -n 1)

if [[ -z "$MODEL_PATH" ]]; then
  echo "[ERROR] No .onnx model file found in $SRC_MODEL_DIR"
  exit 1
fi

MODEL_NAME=$(basename "$MODEL_PATH")

# === Create workspace ===
rm -rf "$OTA_DIR"
mkdir -p "$OTA_DIR/models"

# === Copy files ===
cp "$MODEL_PATH" "$OTA_DIR/models/"
echo "$MODEL_NAME" > "$OTA_DIR/models/current-model.txt"

if [[ -n "$LABELS_PATH" && -f "$LABELS_PATH" ]]; then
  cp "$LABELS_PATH" "$OTA_DIR/models/"
else
  echo "[INFO] No labels.txt found. Proceeding without it."
fi

# === Create install.sh ===
cat << 'EOF' > "$OTA_DIR/install.sh"
#!/bin/bash

SNAP_COMMON=${SNAP_COMMON:-/var/snap/iotconnect/common}
SCRIPT_DIR=$(dirname "$(realpath "$0")")
MODEL_SRC="$SCRIPT_DIR/models"
MODEL_DST="$SNAP_COMMON/models"

echo "[INSTALL] SNAP_COMMON is $SNAP_COMMON"
echo "[INSTALL] Moving models to $MODEL_DST"
echo "[INSTALL] Source model path is $MODEL_SRC"

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
