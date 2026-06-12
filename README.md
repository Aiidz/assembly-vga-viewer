# Assembly VGA Image Viewer

Two x86 assembly programs that load and display VGA Mode 13h images (320x200, 256 colors) from raw pixel files on DOS.

Built for COSC 65A.

## What's in here

- `teamimg1.asm` — loads and displays `dash2.raw`
- `teamimg2.asm` — loads and displays `dismissal.raw`
- `tasm.exe` / `tlink.exe` — Turbo Assembler and linker
- `DPMI16BI.OVL` / `DPMI32VM.OVL` / `RTM.EXE` — DPMI runtime files

## How to build

```bat
tasm teamimg1.asm
tlink teamimg1.obj
```

Same for `teamimg2`.

## How to run

Put the `.raw` file in the same folder as the `.exe` and run it in DOSBox. Press any key to go back to text mode.

## Notes

- VGA memory lives at segment `0A000h` — the programs read pixel data straight into it
- Custom palettes are loaded via VGA DAC ports `03C8h` and `03C9h`
- Everything runs on DOS interrupts (`int 21h` for file I/O, `int 10h` for video)
