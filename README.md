# Chroma Studio

Local AI image editing and image-to-video on an Apple Silicon Mac, using [ComfyUI](https://github.com/comfyanonymous/ComfyUI) with two ready-made boards. Everything runs on your machine: nothing is uploaded, and ComfyUI only listens on localhost.

This repo holds the setup, boards and docs. Models and ComfyUI are downloaded by `setup.sh` and are not stored here.

> **Adult content.** The LoRAs below are NSFW. Use only images you have the right to use. Never use images of minors, or of real people without their consent.

## Requirements

- Apple Silicon Mac. Tested on an M4 Max with 64 GB of memory. Less memory will struggle with video.
- About 70 GB of disk for models, plus at least 40 GB free for video renders, which swap to disk.
- `git` and [`uv`](https://docs.astral.sh/uv/).

## Install

```sh
git clone https://github.com/bataevvlad/chroma-studio.git
cd chroma-studio
./setup.sh
```

`setup.sh` installs ComfyUI, downloads all models, checks each file's SHA-256 hash, and adds the boards. You can safely re-run it: finished files are skipped and partial downloads resume.

## Run

```sh
./run.sh
```

Open <http://127.0.0.1:8188>, click **Workflows** in the left sidebar, and pick a board.

## Using the boards

Each board has a yellow note with these steps. Change only the **green boxes**, then click the blue **Run** button at the top right.

### 1 - Edit Image (Qwen)

1. Upload your picture in **Load Image**.
2. Describe the change in **Your edit**, for example `nsfw, change the jacket to red, keep the same face and background`.
3. Click **Run**. Results save to `ComfyUI/output`.

Default run: 0.5 megapixels and 20 steps, about 8 minutes.

For stronger or better results, try 40 steps and cfg 4.0, the settings from the LoRA's model card. That takes about twice as long.

**Trigger words.** `nsfw` is the main one. The others switch on specific concepts, so add only what you need, spelled exactly as shown:

`nsfw` `nipples` `vagina` `penis` `missionary` `cowgirlout` `reversecowgirlpov` `blowjob` `cum_on_face` `creamp1e` `l1ck`

### 2 - Image to Video (Wan)

1. Upload your picture in **Load Image**.
2. Describe the motion in **Your prompt**, starting with the trigger word: `nsfwsks, she slowly turns her head and smiles, soft light`.
3. Match **Video size** to your image: 480 x 832 for portrait, 832 x 480 for landscape.
4. Set **length** in frames at 16 per second, using 4n+1 values: 33 = 2 s, 49 = 3 s, 81 = 5 s.
5. Click **Run**. Videos save to `ComfyUI/output/video`.

Default run: 480 x 832, 49 frames, about 10 minutes.

**Trigger word:** `nsfwsks`. Keep the high and low NSFW LoRA strengths equal, and leave the steps at 4, which the speed LoRAs need.

### Good to know

- Trigger words and strengths come from the model cards. They weren't tested during setup, so expect to adjust them.
- You don't need to clear anything between runs. New results replace the old preview, and every result stays in `ComfyUI/output`.
- The Total progress bar counts finished boxes, not time. It can start a second run at around 60% because unchanged boxes are reused. Watch the step counter instead.
- Close heavy apps before rendering video. Larger or longer videos use more memory and disk.

## Models

| Purpose | File | Size | Source |
|---|---|---|---|
| Video, high noise | [`wan2.2_i2v_high_noise_14B_fp8_scaled`](https://huggingface.co/Comfy-Org/Wan-2.2/blob/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors) | 14.3 GB | [Comfy-Org/Wan-2.2](https://huggingface.co/Comfy-Org/Wan-2.2) |
| Video, low noise | [`wan2.2_i2v_low_noise_14B_fp8_scaled`](https://huggingface.co/Comfy-Org/Wan-2.2/blob/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors) | 14.3 GB | [Comfy-Org/Wan-2.2](https://huggingface.co/Comfy-Org/Wan-2.2) |
| Video text encoder | [`umt5_xxl_fp8_e4m3fn_scaled`](https://huggingface.co/Comfy-Org/Wan-2.2/blob/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors) | 6.7 GB | [Comfy-Org/Wan-2.2](https://huggingface.co/Comfy-Org/Wan-2.2) |
| Video VAE | [`wan_2.1_vae`](https://huggingface.co/Comfy-Org/Wan-2.2/blob/main/split_files/vae/wan_2.1_vae.safetensors) | 0.25 GB | [Comfy-Org/Wan-2.2](https://huggingface.co/Comfy-Org/Wan-2.2) |
| Video speed LoRA, high | [`wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise`](https://huggingface.co/Comfy-Org/Wan-2.2/blob/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors) | 1.2 GB | [Comfy-Org/Wan-2.2](https://huggingface.co/Comfy-Org/Wan-2.2) |
| Video speed LoRA, low | [`wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise`](https://huggingface.co/Comfy-Org/Wan-2.2/blob/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors) | 1.2 GB | [Comfy-Org/Wan-2.2](https://huggingface.co/Comfy-Org/Wan-2.2) |
| Video NSFW LoRA | `NSFW-22-H-e8`, `NSFW-22-L-e8` | 0.6 GB each | [lopi999/Wan2.2-I2V_General-NSFW-LoRA](https://huggingface.co/lopi999/Wan2.2-I2V_General-NSFW-LoRA) |
| Image edit | [`qwen_image_edit_2511_fp8mixed`](https://huggingface.co/Comfy-Org/Qwen-Image-Edit/blob/main/split_files/diffusion_models/qwen_image_edit_2511_fp8mixed.safetensors) | 20.5 GB | [Comfy-Org/Qwen-Image-Edit](https://huggingface.co/Comfy-Org/Qwen-Image-Edit) |
| Image text encoder | [`qwen_2.5_vl_7b_fp8_scaled`](https://huggingface.co/Comfy-Org/Qwen-Image/blob/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors) | 9.4 GB | [Comfy-Org/Qwen-Image](https://huggingface.co/Comfy-Org/Qwen-Image) |
| Image VAE | [`qwen_image_vae`](https://huggingface.co/Comfy-Org/Qwen-Image/blob/main/split_files/vae/qwen_image_vae.safetensors) | 0.25 GB | [Comfy-Org/Qwen-Image](https://huggingface.co/Comfy-Org/Qwen-Image) |
| Image NSFW LoRA | `qwen-image-edit-plus-nsfw-lora` | 0.6 GB | [ScottzillaSystems/qwen-image-edit-plus-nsfw-lora](https://huggingface.co/ScottzillaSystems/qwen-image-edit-plus-nsfw-lora) |

Original models: [Wan-AI/Wan2.2-I2V-A14B](https://huggingface.co/Wan-AI/Wan2.2-I2V-A14B) and [Qwen/Qwen-Image-Edit-2511](https://huggingface.co/Qwen/Qwen-Image-Edit-2511). The files above are smaller versions that fit in 64 GB of memory.

## Memory

At 480 x 832 and 49 frames, video peaked at 54 GB of swap with default ComfyUI settings. `run.sh` adds `--reserve-vram 24 --disable-smart-memory`, which cut that peak to 30 GB, so start ComfyUI with `./run.sh` rather than directly.

## Layout

```text
setup.sh                  install everything
run.sh                    start ComfyUI
extra_model_paths.yaml    points ComfyUI at models/
workflows/                the two boards
examples/                 test images the boards open with
ComfyUI/                  created by setup.sh (not in git)
models/                   created by setup.sh (not in git)
```
