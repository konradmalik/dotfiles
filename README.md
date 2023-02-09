[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

# Dotfiles

Nix ftw.

## installation

## commands

Note: in all commands flake location can be one of the following:

```bash
# github repo
github:konradmalik/dotfiles#<target>
# local current dir
.#<target>
# absolute local git repo
git+file://$HOME/Code/github.com/konradmalik/dotfiles#<target>
```

I'll use the local version for brevity.

### NixOS:

#### Build and enable config locally:

```bash
$ sudo nixos-rebuild --flake .#$(hostname -s) switch
```

To just build (for example for a test):

```bash
$ nix build .#nixosConfigurations.$(hostname -s).config.system.build.toplevel
```

#### Build and enable config on remote:

> **Note:** this will fail because of [this bug](https://github.com/NixOS/nixpkgs/issues/118655).
> Workaround is to use root ssh access, but I don't want to do that

```bash
$ TARGET=rpi4-1 nixos-rebuild --flake .#$TARGET --target-host $TARGET --build-host $TARGET --use-remote-sudo boot
```

Instead, this will work for now. I may create a wrapper for that:

```bash

$ TARGET=rpi4-1 ssh $TARGET -- sudo nixos-rebuild --flake github:konradmalik/dotfiles#$TARGET boot
```

#### Build sd-image:

```bash
$ nix build .#nixosConfigurations.rpi4-2.config.system.build.sdImage
```

Copy it somewhere and unpack:

```bash
$ unzstd -d rpi4-2.img.zst
```

Flash directly to the card:

```bash
$ sudo dd if=rpi4-2.img of=/dev/sdX bs=4096 conv=fsync status=progress
```

The filesystem won't be complete, it will miss `etc` and more. NixOS will populate those dirs on first boot.

So if you need to modify something on the card (like read host keys or add `wpa_supplicant.conf`) then the steps are:

- boot rpi with the newly flashed card once
- wait a minute or two
- poweroff rpi and mount the card on your PC
- filesystem will be complete

In our case, WiFi (`wpa_supplicant.conf`) is symlinked from `sops`, but you may still need to add appropriate host key to `.sops.yaml`.

#### Build minimal ISO with ssh access for root:

Useful for installing any nixos-config through ssh.

```bash
$ nix build .#nixosConfigurations.installerIso.config.system.build.isoImage
```

Flash iso to a pendrive

```bash
$ sudo dd if=installer.iso of=/dev/sdX bs=4096 conv=fsync status=progress
```

Boot, find the ip and ssh connect as root.

Consider using nmap for discovery:

```bash
$ sudo nmap -p 22 --open -sV 192.168.178.0/24
```

Format, partition the drive etc.

Then you can install the system from flake directly:

```bash
$ sudo nixos-install --flake github:konradmalik/dotfiles#m3800 --root /mnt --no-bootloader
```

Tip: `nixos-enter` is also very handy if you have a working system but need to fix something, eg. change your password.

Tip2: I use `--no-bootloader` because I don't want grub (either way it will fail if there is systemd already defined I think,
it will say something like '/boot/efi is not at the root'). My flake has already all the needed hardware and booloader configs for the machines I use.
In order to install on a new machine, just generate hardware-configuration.nix on that machine and add a new entry in this flake.

### nix-darwin:

Disable gatekeeper or however it's called:

```bash
$ sudo spctl --master-disable
```

Go to Settings -> Security and Privacy and allow apps from "Anywhere".

Then install nix following the official guidelines and installer.

Then build and enable config locally:

```bash
$ darwin-rebuild switch --flake .#$(hostname -s)
```

To just build (for example for a test):

```bash
$ nix build .#darwinConfigurations.$(hostname -s).config.system.build.toplevel
# or shortened by nix-darwin
$ nix build .#darwinConfigurations.$(hostname -s).system
```

### linux (non-NixOS; home-manager):

Build and enable config locally:

```bash
$ home-manager switch --flake .#$(whoami)@$(hostname -s)
```

To just build (for example for a test):

```bash
$ nix build .#homeConfigurations.$(whoami)@$(hostname -s).activationPackage
```

### sops-nix

#### system-wide (linux only)

We use `age`, it's way easier and more straightforward than `gpg`.

Strategy with keys:

- `age` derived from host ssh key for host-wide secrets
- `age` derived from personal ssh key for personal secrets
- one global `age` key per person that is keps secret and not directly on any machine. Serves as a backup to decrypt in case of 'tragedy'

Create `age` dir for sops:

```bash
$ mkdir -p "$XDG_CONFIG_HOME/sops/age" \
$ && touch "$XDG_CONFIG_HOME/sops/age/keys.txt" \
$ && chmod 700 "$XDG_CONFIG_HOME/sops/age" \
$ && chmod 600 "$XDG_CONFIG_HOME/sops/age/keys.txt"
```

Create `age` key from your personal ssh key:

> why do this when decryption keys are also derived from host ssh keys?
>
> 1. Redundancy, 2. Personal (user-specific) secrets, 3. Keys generated here can also be used in the home-manager module below

```bash
$ ssh-to-age -private-key -i ~/.ssh/personal > "$XDG_CONFIG_HOME/sops/age/keys.txt"
```

Add this key to `.sops.yaml` and propagate reencryption to all secrets:

```bash
# adjust this command, glob may not work!
$ sops updatekeys secrets/*.yaml
```

#### home-manager

For user-specific secrets, a home-manager modules of sops-nix is used.

We similarly use `age`. The keys are reused from system-wide config (those derived from personal ssh), but we need to place the secret ones in
separate files and point at them in the sops config, so:

```bash
$ mkdir -p "$XDG_CONFIG_HOME/sops/age" \
$ && touch "$XDG_CONFIG_HOME/sops/age/personal.txt" \
$ && chmod 700 "$XDG_CONFIG_HOME/sops/age" \
$ && chmod 600 "$XDG_CONFIG_HOME/sops/age/personal.txt"
```

Then copy the appropriate key from `keys.txt` and we're done here.

### Credits

[Misterio77](https://github.com/Misterio77/nix-config) - big inspiration for hyprland and nix files structure.
