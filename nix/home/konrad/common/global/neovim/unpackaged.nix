{ lib, vimUtils, neovimUtils, fetchFromGitHub, ... }:
{
  mini-base16 = vimUtils.buildVimPluginFrom2Nix {
    pname = "mini.base16";
    version = "2023-02-09";
    src = fetchFromGitHub {
      owner = "echasnovski";
      repo = "mini.base16";
      rev = "f5382c0c2a4907754cdf2aefb1af790101187c7f";
      sha256 = "sha256-aLfmOnyNT54kJ/dORWkbtV5tGz9zeptFweqDR0+K3fQ=";
    };
    meta.homepage = "https://github.com/echasnovski/mini.base16";
  };

  nvim-luaref = vimUtils.buildVimPluginFrom2Nix {
    pname = "nvim-luaref";
    version = "2022-02-17";
    src = fetchFromGitHub {
      owner = "milisims";
      repo = "nvim-luaref";
      rev = "9cd3ed50d5752ffd56d88dd9e395ddd3dc2c7127";
      sha256 = "sha256-nmsKg1Ah67fhGzevTFMlncwLX9gN0JkR7Woi0T5On34=";
    };
    meta.homepage = "https://github.com/milisims/nvim-luaref";
  };
}
