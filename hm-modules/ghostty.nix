{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    clearDefaultKeybinds = true;
    settings = {
      gtk-titlebar-hide-when-maximized = true;
      mouse-hide-while-typing = true;
      theme = "Dark+";
      window-height = 35;
      window-width = 120;
      window-padding-balance = true;
      window-padding-color = "extend";
      keybind = [
        # Scrolling
        "shift+page_down=scroll_page_down"
        "shift+page_up=scroll_page_up"
        "shift+end=scroll_to_bottom"
        "shift+home=scroll_to_top"

        "ctrl+shift+v=paste_from_clipboard"
        "ctrl+shift+c=copy_to_clipboard"

        # Tab/window creation and deletion
        "ctrl+shift+t=new_tab"
        "ctrl+shift+w=close_tab"
        "ctrl+shift+n=new_window"
        "ctrl+shift+q=close_window"

        # Split resizing (ctrl + shift + <direction>)
        "ctrl+shift+up=resize_split:up,20"
        "ctrl+shift+down=resize_split:down,20"
        "ctrl+shift+right=resize_split:right,20"
        "ctrl+shift+left=resize_split:left,20"

        # General movements and splits (ctrl+g trigger)
        "ctrl+g>n=next_tab"
        "ctrl+g>p=previous_tab"
        "ctrl+g>v=new_split:right"
        "ctrl+g>s=new_split:down"
        "ctrl+g>h=goto_split:left"
        "ctrl+g>j=goto_split:down"
        "ctrl+g>k=goto_split:up"
        "ctrl+g>l=goto_split:right"
        "ctrl+g>q=close_surface"

        # Indexed tab switching
        "alt+1=goto_tab:1"
        "alt+2=goto_tab:2"
        "alt+3=goto_tab:3"
        "alt+4=goto_tab:4"
        "alt+5=goto_tab:5"
        "alt+6=goto_tab:6"
        "alt+7=goto_tab:7"
        "alt+8=goto_tab:8"
        "alt+9=goto_tab:9"
      ];
    };
  };
}

