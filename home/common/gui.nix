# Base configuration for GUI users
{
  ...
}:
{
  # MARK: GUI applications
  programs.ghostty = {
    enable = true;
    settings = {
      window-theme = "ghostty";
      window-decoration = "client";
      font-size = 10;
      link-previews = "true";
      background-opacity = 0.8;
      background-blur = true;
      gtk-toolbar-style = "flat";
      gtk-wide-tabs = false;
      window-show-tab-bar = "always";
      gtk-titlebar-style = "tabs";
      theme = "TokyoNight Night";
      macos-titlebar-style = "tabs";
    };
  };
}
