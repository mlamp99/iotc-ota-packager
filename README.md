# IoTConnect OTA Packager

This tool packages an ONNX model and label files into a `.tar.gz` OTA archive for use with IoTConnect device OTA updates.

## 📁 Usage

1. Place your `.onnx` model and optional `labels.txt` inside the `source-models/` directory.

2. Run the packager:

```bash
chmod +x build-ota-package.sh
./build-ota-package.sh your-model.onnx labels.txt
```

3. It will create:

```
model-ota.tar.gz
```

This archive includes:
- `models/your-model.onnx`
- `models/labels.txt` (if provided)
- `models/current-model.txt` (automatically generated)
- `install.sh` (to move files during OTA)

4. Upload `model-ota.tar.gz` to an OTA-accessible location and push an OTA job from IoTConnect.

## ✅ Compatible With

This script is designed for Snap-based devices using the Avnet IoTConnect Lite SDK with OTA handlers.
