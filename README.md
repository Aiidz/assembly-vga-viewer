# Dash2Byte - VGA Image Viewer

Two x86 assembly programs that render 64x64 pixel-art images in VGA Mode 13h (320x200, 256 colors) using grid-based rendering with 3x3 pixel scaling and a fade-in palette animation.

Built for COSC 65A Final Project by **archiTECH**.

## What's in here

- `Image1.asm` — Renders the **Dash2** image
- `Image2.asm` — Renders the **Dismissal** image
- `tasm.exe` / `tlink.exe` — Turbo Assembler and linker
- `DPMI16BI.OVL` / `RTM.EXE` — DPMI runtime files

## How to build

```bat
tasm Image1.asm
tlink Image1.obj
```

Same for `Image2`.

## How to run

Run the `.exe` in DOSBox. Press any key to return to text mode.

## How it works

- All image data (palette + pixel grid) is embedded directly in the source — no external files required
- VGA Mode 13h: 320x200 pixels, 256 colors, 1 byte per pixel
- A 2-second fade-in animation gradually brings the palette from black to full brightness
- Each pixel from the 64x64 source image is rendered as a 3x3 block (192x192 on screen)
- Custom palettes are set via VGA DAC ports `03C8h` and `03C9h`
- Image data is split into 4 chunks of 16 rows each (106 columns wide) for the rendering loop

## Notes

- Built with Turbo Assembler (TASM) — run in DOSBox
- VGA memory lives at segment `0A000h`
- Uses DOS interrupts (`int 21h`) and BIOS interrupts (`int 10h` for video, `int 1Ah` for timer)
