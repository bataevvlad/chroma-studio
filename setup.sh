#!/bin/bash
# Installs ComfyUI, downloads every model, verifies them, and adds the boards.
# Safe to re-run: verified files are skipped and partial downloads resume.
set -euo pipefail
cd "$(dirname "$0")"

COMFY_COMMIT=63e5bf594339f676b4b15e072529873e3448409e
HF=https://huggingface.co
WAN=Comfy-Org/Wan-2.2/resolve/main/split_files
QWEN=Comfy-Org/Qwen-Image/resolve/main/split_files
QWEN_EDIT=Comfy-Org/Qwen-Image-Edit/resolve/main/split_files
WAN_LORA=lopi999/Wan2.2-I2V_General-NSFW-LoRA/resolve/main
QWEN_LORA=ScottzillaSystems/qwen-image-edit-plus-nsfw-lora/resolve/main

for tool in git uv curl shasum; do
    command -v "$tool" >/dev/null || { echo "Missing required tool: $tool"; exit 1; }
done

if [ ! -d ComfyUI/.git ]; then
    git init -q ComfyUI
    git -C ComfyUI remote add origin https://github.com/comfyanonymous/ComfyUI.git
    git -C ComfyUI fetch -q --depth 1 origin "$COMFY_COMMIT"
    git -C ComfyUI checkout -q FETCH_HEAD
fi
[ -d ComfyUI/.venv ] || uv venv -q --python 3.12 ComfyUI/.venv
uv pip install -q --python ComfyUI/.venv/bin/python -r ComfyUI/requirements.txt

fetch() {
    local url=$1 dest=$2 sha=$3
    mkdir -p "models/$(dirname "$dest")"
    if [ -f "models/$dest" ] && [ "$(shasum -a 256 "models/$dest" | cut -d' ' -f1)" = "$sha" ]; then
        echo "ok    $dest"
        return
    fi
    echo "fetch $dest"
    curl -fL --progress-bar -C - --retry 10 --retry-all-errors --retry-delay 5 -o "models/$dest" "$HF/$url"
    if [ "$(shasum -a 256 "models/$dest" | cut -d' ' -f1)" != "$sha" ]; then
        echo "Hash mismatch: models/$dest. Delete it and run setup.sh again."
        exit 1
    fi
}

fetch "$WAN/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors" diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors 6122e79d55e0f235698d11d657f3b196c5273c830da00b2b013c5a048d5e6a42
fetch "$WAN/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors" diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors 5471a457b6ac404202a5fbe6c11595a3d5641fc766b00f38763f72303fffc21e
fetch "$WAN/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors c3355d30191f1f066b26d93fba017ae9809dce6c627dda5f6a66eaa651204f68
fetch "$WAN/vae/wan_2.1_vae.safetensors" vae/wan_2.1_vae.safetensors 2fc39d31359a4b0a64f55876d8ff7fa8d780956ae2cb13463b0223e15148976b
fetch "$WAN/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors" loras/wan2.2-lightx2v/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors d176c808d6fc461999b68e321efcb7501b20b8c3797523ed0df14f7d1deff11e
fetch "$WAN/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors" loras/wan2.2-lightx2v/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors 024f21de095bc8fad9809ded3e9e49a2e170dcf27075da8145ba7d60d8aab7f9
fetch "$WAN_LORA/NSFW-22-H-e8.safetensors" loras/wan2.2-i2v-nsfw-lora/NSFW-22-H-e8.safetensors 34e2144d3cd65360f97d09ccbe03e1c39a096df6c9234af5fe3899d1b63cda39
fetch "$WAN_LORA/NSFW-22-L-e8.safetensors" loras/wan2.2-i2v-nsfw-lora/NSFW-22-L-e8.safetensors d6b783742f4d5fd63a0223ae1d5bf64fc995a6b408480ac2a00528ae0d4146db
fetch "$QWEN_EDIT/diffusion_models/qwen_image_edit_2511_fp8mixed.safetensors" diffusion_models/qwen_image_edit_2511_fp8mixed.safetensors c9fdc158e46d3b61ef75f21ae866ca2fe808bf4a53643120d1c1e87c19280a4e
fetch "$QWEN/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors" text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors cb5636d852a0ea6a9075ab1bef496c0db7aef13c02350571e388aea959c5c0b4
fetch "$QWEN/vae/qwen_image_vae.safetensors" vae/qwen_image_vae.safetensors a70580f0213e67967ee9c95f05bb400e8fb08307e017a924bf3441223e023d1f
fetch "$QWEN_LORA/qwen-image-edit-plus-nsfw-lora.safetensors" loras/qwen-image-edit-plus-nsfw-lora/qwen-image-edit-plus-nsfw-lora.safetensors 16c4841028615bb82c38e79756c0abad42494d85bca0daebc2939384a74d86bb

mkdir -p ComfyUI/user/default/workflows ComfyUI/input
cp workflows/*.json ComfyUI/user/default/workflows/
cp examples/*.png ComfyUI/input/
echo "Done. Start ComfyUI with ./run.sh"
