{ ... }:
{
  # shared sops config
  sops = {
    # This will add secrets.yml to the nix store
    # You can avoid this by adding a string to the full path instead, i.e.
    #sops.defaultSopsFile = ./../../secrets/secrets.yaml;
    #defaultSopsFile = ./secrets/secrets.yaml
    # This will automatically import SSH keys as age keys
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    # This is the actual specification of the secrets.
    # secrets.example-key = { };
    # secrets."myservice/my_subdir/my_secret" = { };
  };
}
