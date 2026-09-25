[![Actions Status](https://github.com/konradmalik/dotfiles/actions/workflows/linux.yml/badge.svg)](https://github.com/konradmalik/dotfiles/actions)
[![Actions Status](https://github.com/konradmalik/dotfiles/actions/workflows/darwin.yml/badge.svg)](https://github.com/konradmalik/dotfiles/actions)

# Dotfiles

My NixOS and Nix-Darwin configurations.

## Layout

- `hosts` - system-level (NixOS/nix-darwin) configuration, one dir per machine plus `common`
- `home` - home-manager configuration, per user
- `pkgs` - own packages and overlays (`fonts`, `scripts`, `special`)
- `files` - static assets (wallpapers, grafana dashboards)
- `templates` - flake templates
- `router` - home network and MikroTik router config, see [router/readme.md](./router/readme.md)

### Naming

Inside `hosts/common` and `home/*/common`:

- modules - something that's imported on-demand and does not support explicitly enabling
- options - something that's always imported but requires explicit enable. It's also configurable via some abstraction.
- systems - prepared modules for specific systems like nixos, darwin etc.
- profiles - prepared modules for a specific use-case like desktop, server, laptop, etc.
- hardware - hardware-specific modules shared by more than one host
- users - per-user system-level config

### Hosts

| Host        | Kind       | Notes                              |
| ----------- | ---------- | ---------------------------------- |
| `framework` | NixOS      | desktop, Ryzen AI Max+ 395         |
| `x1c6`      | NixOS      | laptop, ThinkPad X1 Carbon 6th gen |
| `rpi4-1`    | NixOS      | server, aarch64                    |
| `rpi4-2`    | NixOS      | server, aarch64                    |
| `m4`        | nix-darwin | macOS                              |

Plus `konrad@generic` - a standalone home-manager config for non-NixOS Linux.

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
$ nix build .#nixosConfigurations.framework.config.system.build.toplevel
```

#### Build sd-image:

```bash
$ nix build .#rpi4-2-sd-image
```

The image lands in `result/sd-image/nixos-sd-image-<version>-aarch64-linux.img.zst`.

Unpack and flash it to the card:

```bash
$ unzstd -c result/sd-image/*.img.zst | sudo dd of=/dev/sdX bs=4M conv=fsync status=progress
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
$ sudo disko --mode destroy,format,mount ./hosts/x1c6/disko.nix
```

Generate hardware configuration and put it in the host's dir:

```bash
$ sudo nixos-generate-config --no-filesystems --root /mnt
$ cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/x1c6/
```

Generate/add sops keys (if required for the configuration). Do this later only if no critical services rely on them (like user passwords).
Host ones will be picked up automatically. Add user ones to `/home/USER/.config/sops/age/keys.txt`.
For details refer to [sops-nix](#sops-nix) section.

Finally, use hardware-configuration and disko to install nixos:

```bash
$ sudo nixos-install --flake .#x1c6 --root /mnt
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
$ sudo disko --mode mount ./hosts/x1c6/disko.nix
```

Enter your system

```bash
$ cd /mnt
$ nixos-enter
```

### nix-darwin:

First clone this repo to the machine.

Then you need to install nix. `nix-darwin` manual suggests using [lix](https://lix.systems/install/) as the bootstrapper.

Next install [homebrew](https://brew.sh/).

Enter the devshell from this repo.

Finally, build and enable config locally:

```bash
$ sudo darwin-rebuild switch --flake .
```

Once that succeeds, uninstall the bootstrapper. `nix.package` owns nix from here on, but the installer
leaves itself in root's default profile, which stays on `PATH` next to the real one. Two nix
implementations sharing `~/.cache/nix` do not agree on the narHash of every git input, which surfaces
later as `mismatch in field 'narHash' of input ...` in flakes and direnv:

```bash
$ sudo nix-env --profile /nix/var/nix/profiles/default --uninstall lix
$ sudo nix-env --profile /nix/var/nix/profiles/default --delete-generations old
```

`nix-env -q --profile /nix/var/nix/profiles/default` should then list only `nss-cacert`.

To just build a darwin host (for example for a test):

```bash
$ nix build .#darwinConfigurations.m4.config.system.build.toplevel
# or shortened by nix-darwin
$ nix build .#darwinConfigurations.m4.system
```

#### Linux builder

It is useful to have a Linux builder on a macOS machine to build linux-specific stuff.

`nix-darwin` supports it as an option. It is a NixOS VM run via Apple's
Virtualization.framework (`linux-builder-vz`) and it serves both `aarch64-linux`
and `x86_64-linux` - the latter through Rosetta, which needs
`softwareupdate --install-rosetta` on the host once.

The launchd daemon is started on demand with the
`linux-builder-ctl` helper that ships with that module.

#### Docker on Darwin

Use [colima](https://github.com/abiosoft/colima). It's installed via homebrew.

### Linux (non-NixOS; home-manager):

Build and enable config locally:

```bash
$ home-manager switch --flake .
```

To just build (for example for a test):

```bash
$ nix build .#homeConfigurations.konrad@generic.activationPackage
```

## sops-nix

### system-wide (Linux only)

Strategy with keys:

- none of the keys block new machines. If they're missing, they'll just fail to decrypt on runtime.
- `age` derived from host ssh key for host-wide secrets
- `age` derived from personal ssh key for personal secrets
- one global `age` key per person that is kept secret and not directly on any machine. Serves as a backup to decrypt in case of 'tragedy'

#### Host keys

To get age key for the machine, use:

```bash
$ cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
```

Add this key to `.sops.yaml` and propagate re-encryption to all secrets:

```bash
$ for file in $(grep -lr "^sops:$"); do sops updatekeys -y $file; done
```

#### User keys

Create `age` directory for sops:

```bash
$ mkdir -p "$XDG_CONFIG_HOME/sops/age"
$ touch "$XDG_CONFIG_HOME/sops/age/keys.txt"
$ chmod 700 "$XDG_CONFIG_HOME/sops/age"
$ chmod 600 "$XDG_CONFIG_HOME/sops/age/keys.txt"
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

### home-manager

For user-specific secrets, a home-manager modules of sops-nix is used.

We similarly use `age`. The key is reused from system-wide config (the one derived from personal ssh).
See how `sops` is configured in the home-manager (it just points at the `keys.txt` file).

## Hardware-backed ssh keys

Keys live in the machine's security chip: non-exportable, impossible to back up, one per
machine. `~/.ssh/personal` stays as the offline fallback.

### NixOS (TPM)

`ssh-tpm-agent` serves the sealed keys and proxies to the plain `ssh-agent`, so ordinary
key files keep working alongside them.

```bash
$ ssh-tpm-keygen --supported            # what this tpm can do
$ ssh-tpm-keygen -C konrad@$(hostname)  # add -f ~/.ssh/name to choose the name
```

That writes `~/.ssh/id_ecdsa.tpm` and its `.pub`. The agent loads every sealed key it
finds in `~/.ssh` on start, so any number of them can coexist:

```bash
$ systemctl --user restart ssh-tpm-agent.service
$ ssh-add -l
```

The `.tpm` blob is the key, encrypted to a hierarchy seed that never leaves the chip.
There is no per-key state inside the tpm, so removing a key is removing its files - while
clearing the tpm regenerates that seed and destroys every key at once:

```bash
$ rm ~/.ssh/id_ecdsa.tpm ~/.ssh/id_ecdsa.pub
$ systemctl --user restart ssh-tpm-agent.service
```

### nix-darwin (Secure Enclave)

Requires macOS Tahoe. Apple's middleware is already wired up in the ssh config and in
`SSH_SK_PROVIDER`, so `ssh`, `ssh-add` and `ssh-keygen` find it on their own.

Create the identity - `-l` is the label, `-t bio` asks for Touch ID on every use while
`-t none` never asks:

```bash
$ sc_auth create-ctk-identity -l ssh -k p-256-ne -t bio
```

Then download the key handle. `-K` writes one file pair per identity into the current
directory, named after the label, and they can be renamed afterwards:

```bash
$ cd ~/.ssh
$ SSH_ASKPASS_REQUIRE=force SSH_ASKPASS=true ssh-keygen -w /usr/lib/ssh-keychain.dylib -K
$ ssh-keygen -lf id_ecdsa_sk_rk_ssh.pub
```

List and remove identities:

```bash
$ sc_auth list-ctk-identities
$ sc_auth delete-ctk-identity -h <hash>
```

### Making ssh use them

`ssh-egress` sets `IdentitiesOnly`, so only listed keys are offered. Point `hardwareKeys`
at the public key (linux) or the handle file (darwin); `~/.ssh/personal` is appended as the
fallback. ssh warns on every connection while the file is missing, so generate the key
around the same time as the rebuild.

```nix
konrad.programs.ssh-egress.hardwareKeys = [
  "${config.home.homeDirectory}/.ssh/id_ecdsa.pub"
];
```

### Normal keys

```bash
$ ssh -i ~/.ssh/somekey user@host                # ad-hoc, works despite IdentitiesOnly
$ ssh-add ~/.ssh/somekey                         # linux, proxied to the plain agent
$ ssh-add --apple-use-keychain ~/.ssh/somekey    # darwin, passphrase into the keychain
$ ssh-add --apple-load-keychain                  # darwin, after a reboot
```

Per host, add a block to `ssh-egress` or a drop-in to the already-included `config.d`:

```bash
$ cat >> ~/.ssh/config.d/somehost <<'EOF'
Host somehost
  IdentitiesOnly yes
  IdentityFile ~/.ssh/somekey
EOF
```

## Credits

[Misterio77](https://github.com/Misterio77/nix-config) - big inspiration for hyprland and nix files structure.
