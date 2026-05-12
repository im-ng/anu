### Anu (​அனு)

A drop-in replacement top bar for individual use inspired by waybar. It swiftly transforms a freshly installed Debian into a developer-ready system with curated apps, extensions, and shortcuts.

The default Ubuntu/Debian setup is modified by this one-stop script to emulate the `hyprland` + `waybar` combos under `GNOME + Wayland`.

_Think anu is like personalized `omarchy`, but limited._

### Features

- **Resilient** — if one package fails, the script moves on. Nothing blocks the rest.
- **Tracked** — every install attempt is logged. Successes, failures, and skips are all recorded.
- **Smart uninstall** — only removes what was actually installed. Won't touch pre-existing packages.
- **Dry-run** — preview everything before committing with `--dry-run`.
- **Idempotent** — safe to re-run. Won't duplicate `.bashrc` entries.
- **Clean-as-you-go** — temp files are removed per step; failed steps leave artifacts for debugging.

#### How does it look?

![preview](./resources/image1.png)

#### Getting started

```
git clone https://github.com/im-ng/anu.git
cd anu
chmod +x install.sh uninstall.sh

./install.sh              # full install
./install.sh --dry-run    # preview only
./install.sh --help       # show options
```

#### Clean up

```
./uninstall.sh              # remove what anu installed
./uninstall.sh --dry-run    # preview only
```

### Quick test with QEMU

Spin up a throwaway Debian VM with the repo shared via virtiofs — no copying or ISO builds needed.

```
# 1. Grab a Debian GNOME cloud image (one-time)
wget -nc https://cdimage.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2

# 2. Resize so GNOME has room to breathe
qemu-img resize debian-12-genericcloud-amd64.qcow2 20G

# 3. Start the virtiofs daemon pointing at your anu checkout
virtiofsd --socket-path=/tmp/vfs.sock --shared-dir=. --cache=auto &

# 4. Boot the VM
qemu-system-x86_64 -enable-kvm -m 4G -smp 4 \
  -drive file=debian-12-genericcloud-amd64.qcow2 \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -device virtio-net,netdev=net0 \
  -chardev socket,id=char0,path=/tmp/vfs.sock \
  -device vhost-user-fs-pci,queue-size=1024,chardev=char0,tag=anu \
  -object memory-backend-memfd,id=mem,size=4G,share=on \
  -numa node,memdev=mem \
  -nographic

# Inside the VM:
sudo mount -t virtiofs anu /mnt
cd /mnt
./install.sh --dry-run    # preview
./install.sh              # go
```

Tear down after testing:

```
sudo poweroff                  # inside the VM
kill %1                        # stop virtiofsd
rm -f /tmp/vfs.sock
```

To start fresh for another run, delete and re-download the qcow2.

> The cloud image boots to a serial console — attach a display manager or run `--dry-run` there to validate script logic without a desktop.

### Keyboard shortcuts

Shortcuts inspired from hyprland.

| Keymap            | Action                       |
| ----------------- | ---------------------------- |
| Super + D         | Launch ulauncher             |
| Super + Enter     | Launch terminal              |
| Super + Q         | Kill active window           |
| Super + F         | Full / Restore window size   |
| Super + L         | Lockscreen                   |
| Super + Shift + L | Logout                       |
| Super + H         | Hide                         |
| Super + Shift + H | Hide / Restore active window |

#### Audio

| Keymap                    | Action          |
| ------------------------- | --------------- |
| Ctrl + Super + Down Arrow | Reduce Volume   |
| Ctrl + Super + Up Arrow   | Increase Volume |

#### Settings

| Keymap            | Action          |
| ----------------- | --------------- |
| Super + S         | Topbar Settings |
| Super + Shift + S | Settings        |

#### Workspaces

| Keymap                           | Action                          |
| -------------------------------- | ------------------------------- |
| Super + 1                        | First workspace                 |
| Super + 2                        | Second workspace                |
| Super + 3                        | Third workspace                 |
| Super + 4                        | Fourth workspace                |
| Super + 5                        | Fifth workspace                 |
| Super + 0                        | Last workspace                  |
| Super + Shift + Left/Right Arrow | Move across workspaces          |
| Super + Mouse scroll             | Move across workspaces          |
| Super + Shift + workspace-number | Move active window to workspace |

#### Window

| Keymap                                                | Action |
| --------------------------------------------------- | ---------- 
| Super + Left Arrow | Resize half and move left |
| Super + Right Arrow | Resize half and move right |
| Super + Down Arrow | Resize full |

#### Terminal

| Keymap                                                | Action |
| --------------------------------------------------- | ---------- 
| Super + Enter | Launch Terminal |

### Tracking

All install results are written to `~/.config/anu/`:

| File | Purpose |
|------|---------|
| `anu.log` | Timestamped log of every step with status |
| `status`  | Machine-readable per-item state (`ok`/`fail`/`skip`) |

Uninstall reads `status` to know exactly what to remove — and what to leave alone.

### Extensions & Apps

- Openbar: an opinionated topbar custimizable gnome extensions
- AppIndicator: Tray icons support to the Shell
- Vitals: An handy extension to preview system resource usages
- Tiling Shell: Extend Gnome Shell with advanced tiling window management. 
- Ulauncher: Application launcher for Linux 

### License

[MIT License](https://opensource.org/license/MIT)