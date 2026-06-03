{
  services.tlp = {
    enable = true;
    pd.enable = true;

    settings = {
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
    };
  };
}
