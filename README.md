# ❄️ NixOS Multi-Host Configuration

A clean, modular, and reproducible **NixOS setup** built with **flakes** and **Home Manager as a NixOS module**.

This repository demonstrates a real-world multi-machine NixOS configuration, focused on **reusability, clarity, and reproducibility** — the same ideas used in infrastructure-as-code environments.

---

## 🚀 Why this setup?

- Declarative system configuration
- One codebase, multiple machines
- Minimal duplication between hosts
- Clear separation of concerns
- Easy to extend and maintain

---

## ✨ Features

- ❄️ Flakes-first workflow
- 🖥️ Multi-host support (desktop, laptop, etc.)
- 🏠 Home Manager integrated as a NixOS module
- 🧩 Modular system design
- 🔁 Reproducible builds

---

## 🗂️ Repository Structure

    .
    ├── flake.nix
    ├── flake.lock
    ├── configuration.nix
    ├── home.nix
    ├── flakes.sh
    ├── hwgen.sh
    ├── hosts/
    │   ├── desktop/
    │   │   └── hardware-configuration.nix
    │   └── laptop/
    │       └── hardware-configuration.nix
    └── modules/
        ├── gnome.nix
        ├── dconf.nix
        ├── packages.nix
        └── theme.nix

---

## 🧠 Design Overview

- **hosts/**  
  Hardware-specific configuration per machine. Everything else is shared.

- **modules/**  
  Reusable building blocks for system features and user experience.

- **Home Manager**  
  Integrated directly as a NixOS module — no separate installation.

This layout scales naturally as new machines or features are added.

---

## 🧪 Installation (NixOS Minimal)

This setup is designed to be applied on top of a **minimal NixOS installation**.

### 1️⃣ Generate hardware configuration

Each machine has its own hardware configuration that must be generated on that specific machine. The existing configs in `hosts/` are for the original author's machines — **you must generate your own**.

Run on the target machine:

    ./hwgen.sh <host>

Example:

    ./hwgen.sh thinkpad

This will detect the current machine's hardware, generate `hardware-configuration.nix`, and automatically stage it with git so the flake can track it.

---

### 2️⃣ Enable flakes for the user

Enable the required experimental features (`nix-command` and `flakes`):

    ./flakes.sh

Apply the change by restarting your shell:

    exec $SHELL

---

### 3️⃣ Apply the system configuration

Rebuild and switch to the new configuration:

    sudo nixos-rebuild switch --flake .#<host> --impure

Example:

    sudo nixos-rebuild switch --flake .#desktop --impure

> `--impure` is required so the flake can read `$SUDO_USER` to automatically detect the username of the user running the command.

After this step, the system is fully managed by flakes.

---

## ⚡ Quick Start (TL;DR)

    ./hwgen.sh desktop
    ./flakes.sh
    exec $SHELL
    sudo nixos-rebuild switch --flake .#desktop --impure

---

## 📌 Notes

- Hardware-specific state is isolated per host
- Shared logic lives in clean, reusable modules
- Suitable for personal setups or as a foundation for larger NixOS deployments

---

## 📄 License

Use it, learn from it, break it, improve it.
That’s the whole point 🙂
