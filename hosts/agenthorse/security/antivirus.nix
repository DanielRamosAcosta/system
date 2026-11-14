{
  services.clamav = {
    daemon = {
      enable = true;
      settings = {
        OnAccessIncludePath = "/home/dani";
        OnAccessExcludeUname = "clamav";
        OnAccessPrevention = false;
      };
    };
    updater.enable = true;
    clamonacc.enable = true;
  };
}
