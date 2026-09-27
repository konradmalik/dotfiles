{
  imports = [
    ./linux-builder.nix
  ];

  homebrew = {
    brews = [
      "colima"
    ];
  };
}
