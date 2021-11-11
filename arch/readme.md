# Vagrant (virtualbox)

Just use the Vagrantfile

# VMWare

- install arch using archinstaller (pacman -S archinstaller) from ISO.
- you may need to fix systemd entries if not using the default kernel
- enable ssh
- use scp to copy files from the host (dotfiles)
- run `run.sh` but with variable_host set to local
- guest stuff: `https://wiki.archlinux.org/title/VMware/Install_Arch_Linux_as_a_guest#Xorg_configuration`
    - open-vm-tools work ok (install gtkmm3 for clipboard support!)

