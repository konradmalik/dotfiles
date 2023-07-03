{ pkgs, lib, ... }:
{
  # just the config file, if earthly is needed in a particular version
  # then it's installed in per-project shells
  # NOTE: earthly does not support XDG :( see: https://github.com/earthly/earthly/issues/2210
  home.file.".earthly/config.yml".text = ''
    global:
      cache_size_mb: 40000
      disable_analytics: true
      conversion_parallelism: 5
    git:
        repositories.gitlab.cerebredev.com:
            auth: ssh
            user: git
  '';
}
