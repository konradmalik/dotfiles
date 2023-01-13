# Dotfiles

Nix ftw.

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
$ sudo nixos-rebuild --flake .#$(hostname) switch
```

To just build (for example for a test):

```bash
$ nix build .#nixosConfigurations.$(hostname).config.system.build.toplevel
```

#### Build and enable config on remote:

```bash
# TODO not tested
# home-manager may be problematic: https://discourse.nixos.org/t/home-manager-flake-not-respecting-build-host-during-nixos-rebuild/16787
$ HOSTNAME=m3800 nixos-rebuild --flake .#$HOSTNAME --target-host $HOSTNAME --build-host $HOSTNAME --use-remote-sudo switch
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

So the steps are:

- boot rpi with the newly flashed card once
- wait a minute or two
- poweroff rpi and mount the card on your PC
- filesystem will be complete

WiFi (`wpa_supplicant.conf`) is symlinked from `sops`, but you may still need to add appropriate host key to `.sops.yaml`.

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

Format, partition the drive etc.

Then you can install the system from flake directly:

```bash
$ sudo nixos-install --flake github:konradmalik/dotfiles#m3800 --root /mnt
```

Tip: `nixos-enter` is also very handy if you have a working system but need to fix something, eg. change your password.

### nix-darwin:

Disable gatekeeper or however it's called:

```bash
$ sudo spctl --master-disable
```

Go to Settings -> Security and Privacy and allow apps from "Anywhere".

Then install nix following the official guidelines and installer.

Then build and enable config locally:

```bash
$ darwin-rebuild switch --flake .#$(hostname)
```

To just build (for example for a test):

```bash
$ nix build .#darwinConfigurations.$(hostname).config.system.build.toplevel
# or shortened by nix-darwin
$ nix build .#darwinConfigurations.$(hostname).system
```

### linux (non-NixOS; home-manager):

Build and enable config locally:

```bash
$ home-manager switch --flake .#$(whoami)@$(hostname)
```

To just build (for example for a test):

```bash
$ nix build .#homeConfigurations.$(whoami)@$(hostname).activationPackage
```

### sops-nix

We use `age`, it's way easier and more straightforward than `gpg`.

Create `age` dir for sops:

```bash
$ mkdir -p "$XDG_CONFIG_HOME/sops/age" \
$ && touch "$XDG_CONFIG_HOME/sops/age/keys.txt" \
$ && chmod 700 "$XDG_CONFIG_HOME/sops/age" \
$ && chmod 600 "$XDG_CONFIG_HOME/sops/age/keys.txt"
```

Create `age` key from your personal ssh key:

```bash
$ ssh-to-age -private-key -i ~/.ssh/personal > "$XDG_CONFIG_HOME/sops/age/keys.txt"
```

Add this key to `.sops.yaml` and propagate reencryption to all secrets:

```bash
# adjust this command, glob may not work
$ sops updatekeys secrets/*.yaml
```
