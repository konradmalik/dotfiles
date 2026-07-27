{ inputs, ... }:
{
  imports = [
    ./linux-builder.nix

    # TODO: once https://github.com/nix-darwin/nix-darwin/pull/1691 is merged,
    # drop this import and the `darwin-container` flake input
    "${inputs.darwin-container}/modules/services/container.nix"
  ];

  # TODO disabled until https://github.com/apple/container/pull/1874 or related are merged
  # and Error: error querying keychain for registry.gitlab.cerebredev.com (cause: "queryError("query failure:
  # unhandledError(status: -25308)")") is fixed
  services.container.enable = false;

  homebrew = {
    brews = [
      "colima"
    ];
  };
}
