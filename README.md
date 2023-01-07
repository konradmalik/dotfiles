# Dotfiles

Nix ftw.

## commands

### NixOS:

#### Build and enable config locally:

```bash
$ sudo nixos-rebuild --flake "git+file://$HOME/Code/github.com/konradmalik/dotfiles#$(hostname)" switch
```

#### Builde and enable config on remote:

```bash
# TODO not tested
# home-manager may be problematic: https://discourse.nixos.org/t/home-manager-flake-not-respecting-build-host-during-nixos-rebuild/16787
$ HOSTNAME=m3800 nixos-rebuild --flake "git+file://$HOME/Code/github.com/konradmalik/dotfiles#$HOSTNAME" --target-host $HOSTNAME --build-host $HOSTNAME --use-remote-sudo switch
```

#### Build sd-image:

```bash
$ nix build .#nixosConfigurations.rpi4-2SdCard.config.system.build.sdImage
```

Copy it somewhere and unpack:

```bash
$ unzstd -d rpi4-2.img.zst
```

Flash directly to the card:

```bash
$ sudo dd if=rpi4-2.img of=/dev/sdX bs=4096 conv=fsync status=progress
```

Remember to use `dotfiles-private` and symlink `wpa_supplicant.conf`, but you can do it only after running rpi with the card inside at least once.
Otherwise, the filesystem won't be complete, it will miss `etc` and more. NixOS will populate those dirs on first boot.

So steps are:

- boot rpi with the newly flashed card once
- wait a minute or two
- poweroff rpi and mount the card on your PC
- copy `wpa_supplicant`
- boot rpi with the card again and it will work

#### Build minimal ISO with ssh access for root:

Useful for installing any nixos-config through ssh.

```bash
$ nix build .#nixosConfigurations.installerIso.config.system.build.isoImage
```

### nix-darwin:

Disable gatekeeper or however it's called:

```bash
$ sudo spctl --master-disable
```

Go to Settings -> Security and Privacy and allow apps from "Anywhere".

Then install nix following the official guidelines and installer.

Then build and enable config locally:

```bash
$ darwin-rebuild switch --flake "git+file://$HOME/Code/github.com/konradmalik/dotfiles#$(hostname)"
```

### linux (non-NixOS; home-manager):

Build and enable config locally:

```bash
$ home-manager switch --flake "git+file://$HOME/Code/github.com/konradmalik/dotfiles#$(whoami)@$(hostname)"
```

## presets and modules

- `modules` in `/nix/modules` are proper, enable-able modules which can be always imported and enabled/configured as needed. I'm slowly migrating my stuff here.
- `presets` are ready to use templates `nixos.nix`, `darwin.nix` etc.
- `modules` (not in `/nix/modules`) are optional layers on top of presets, eg. `desktop-apps.nix`. Those are enabled as soon as they are imported.

An exemplary usage is:
`m3800.nix` defines a home-manager config for a m3800 machine.
First it imports `presets/nixos.nix` because it's a NixOS machine.
Then, it imports additional module `gui.nix` which adds personal GUI-related apps and configs
Finally, `m3800.nix` itself defines some machine specific configs like home directory, alacritty font size etc.
