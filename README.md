[![Actions Status](https://github.com/konradmalik/dotfiles/actions/workflows/linux.yml/badge.svg)](https://github.com/konradmalik/dotfiles/actions)
[![Actions Status](https://github.com/konradmalik/dotfiles/actions/workflows/darwin.yml/badge.svg)](https://github.com/konradmalik/dotfiles/actions)

# Dotfiles

My NixOS and Nix-Darwin configurations.

## Commands

> [!NOTE]
> in all commands flake location can be one of the following:

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
$ sudo nixos-rebuild --flake . switch
# or
$ sudo nixos-rebuild --flake . boot
```

To just build (for example for a test):

```bash
$ nix build .#nixosConfigurations.m3800.config.system.build.toplevel
```

#### Build sd-image:

```bash
$ nix build .#rpi4-2-sd-image
```

Copy it somewhere and unpack:

```bash
$ unzstd -d rpi4-2.img.zst
```

Flash directly to the card:

```bash
$ sudo dd if=rpi4-2.img of=/dev/sdX bs=4096 conv=fsync status=progress
```

> [!NOTE]
> The filesystem won't be complete, it will miss `etc` and more. NixOS will populate those dirs on first boot.
>
> So if you need to modify something on the card (like read host keys) then the steps are:
>
> - boot rpi with the newly flashed card once
> - wait a minute or two
> - poweroff rpi and mount the card on your PC
> - filesystem will be complete

#### Install/reinstall/rebuild NixOS from ISO

In NixOS ISO:

Clone this repo

```bash
$ git clone https://github.com/konradmalik/dotfiles
```

Enter shell

```bash
$ nix-shell
```

Use disko to format and mount:

```bash
$ sudo disko --mode destroy,format,mount ./hosts/m3800/disko.nix
```

Generate hardware configuration:

```bash
$ nixos-generate-config --no-filesystems --root /mnt
```

Generate/add sops keys (if required for the configuration). Do this later only if no critical services rely on them (like user passwords).
Host ones will be picked up automatically. Add user ones to `/home/USER/.config/sops.keys.txt`.
For details refer to [sops-nix](#sops-nix) section.

Finally, use hardware-configuration and disko to install nixos:

```bash
$ sudo nixos-install --flake .#m3800 --root /mnt
```

#### Fix something on NixOS from ISO

In NixOS ISO:

Clone this repo

```bash
$ git clone https://github.com/konradmalik/dotfiles
```

Enter shell

```bash
$ nix-shell
```

Use disko to mount:

```bash
$ sudo disko --mode mount ./hosts/m3800/disko.nix
```

Enter your system

```bash
$ cd /mnt
$ nixos-enter
```

### nix-darwin:

Then build and enable config locally:

```bash
$ sudo darwin-rebuild switch --flake .
```

To just build (for example for a test):

```bash
$ nix build .#darwinConfigurations.mbp13.config.system.build.toplevel
# or shortened by nix-darwin
$ nix build .#darwinConfigurations.mbp13.system
```

#### Linux builder

It is useful to have a Linux builder on a macOS machine to build linux-specific stuff.

NixOS has a great support for this. We need to:

- set up a remote builder
- configure nix.buildMachines to use it

We can have either a truly remote machine (local PC, cloud VM etc. etc.) or a 'local remote builder' which is just a qemu virtual machine with
NixOS inside. This 'local remote builder' is very handy to have either way, very easy to deploy and very lightweight
(it mounts your existing /nix/store for example for absolutely minimal disk usage).

`nix-darwin` support a Linux builder as an option:

```nix
nix.linux-builder.enable = true;
```

#### Docker on Darwin

Use `darwin-docker` module.

### Linux (non-NixOS; home-manager):

Build and enable config locally:

```bash
$ home-manager switch --flake .
```

To just build (for example for a test):

```bash
$ nix build .#homeConfigurations.konrad@generic.activationPackage
```

### sops-nix

#### system-wide (Linux only)

Strategy with keys:

- none of the keys block new machines. If they're missing, they'll just fail to decrypt on runtime.
- `age` derived from host ssh key for host-wide secrets
- `age` derived from personal ssh key for personal secrets
- one global `age` key per person that is kept secret and not directly on any machine. Serves as a backup to decrypt in case of 'tragedy'

##### Host keys

To get age key for the machine, use:

```bash
$ /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
```

Add this key to `.sops.yaml` and propagate re-encryption to all secrets:

```bash
$ for file in $(grep -lr "^sops:$"); do sops updatekeys -y $file; done
```

##### User keys

Create `age` directory for sops:

```bash
$ mkdir -p "$XDG_CONFIG_HOME/sops/age" \
$ && touch "$XDG_CONFIG_HOME/sops/age/keys.txt" \
$ && chmod 700 "$XDG_CONFIG_HOME/sops/age" \
$ && chmod 600 "$XDG_CONFIG_HOME/sops/age/keys.txt"
```

Create `age` key from your personal ssh key:

> Why do this when decryption keys are also derived from host ssh keys?
>
> 1. Redundancy, 2. Personal (user-specific) secrets, 3. Keys generated here can also be used in the home-manager module below

```bash
$ ssh-to-age -private-key -i ~/.ssh/personal > "$XDG_CONFIG_HOME/sops/age/keys.txt"
```

Add this key to `.sops.yaml` and propagate re-encryption to all secrets:

```bash
$ for file in $(grep -lr "^sops:$"); do sops updatekeys -y $file; done
```

#### home-manager

For user-specific secrets, a home-manager modules of sops-nix is used.

We similarly use `age`. The key is reused from system-wide config (the one derived from personal ssh).
See how `sops` is configured in the home-manager (it just points at the `keys.txt` file).

### Credits

[Misterio77](https://github.com/Misterio77/nix-config) - big inspiration for hyprland and nix files structure.
