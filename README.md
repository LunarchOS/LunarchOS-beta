# 🌙 Lunarch OS

A tiny hobby operating system written entirely in x86 Assembly.  
It boots in real BIOS (or via emulator like QEMU), supports simple shell commands, and runs from a floppy image.

---

## 💻 Features

- Bootable 16-bit real mode OS
- Command-line shell
- Built-in commands:
  - `help` — list available commands
  - `about` — short description
  - `cls` — clear screen
  - `quit` — shutdown the system
- Clean boot splash with ASCII art

---

## 🛠 Requirements

- [NASM](https://www.nasm.us/) — assembler
- [QEMU](https://www.qemu.org/) — for testing (or any other emulator)
- Unix-like shell (`bash`, `zsh`, etc.)

---

## 🚀 How to Build and Run

### 1. Assemble the OS

```bash
nasm -f bin bootloader.asm -o os.bin

### 2. Create a bootable floppy image (2 sectors = 1024 bytes)

```bash
dd if=os.bin of=os.img bs=512 count=2

### 3. Boot with QEMU

```bash
qemu-system-i386 -fda os.img
