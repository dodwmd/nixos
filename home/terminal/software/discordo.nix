{pkgs, ...}: let
  configFile = "discordo/config.toml";
  toTOML = (pkgs.formats.toml {}).generate;
in {
  users.users.dodwmd.packages = with pkgs; [
    discordo
  ];

  xdg.configFile."${configFile}".source = toTOML "config.toml" {
    mouse = false;
    editor = "default";
    markdown = true;
    hide_blocked_users = true;
    show_attachment_links = true;
    autocomplete_limit = 20;
    messages_limit = 50;

    timestamps = {
      enabled = true;
      format = "15:04";
    };

    notifications = {
      enabled = true;
      duration = 0;
      sound = {
        enabled = true;
        only_on_ping = true;
      };
    };

    identify = {
      status = "dnd";
      browser = "default";
      browser_version = "default";
      user_agent = "default";
    };

    keys = {
      focus_guilds_tree = "Ctrl+G";
      focus_messages_list = "Ctrl+T";
      focus_message_input = "Ctrl+P";
      toggle_guilds_tree = "Ctrl+B";
      quit = "Ctrl+C";
      logout = "Ctrl+D";

      guilds_tree = {
        select_previous = "Rune[k]";
        select_next = "Rune[j]";
        select_first = "Rune[g]";
        select_last = "Rune[G]";
        select_current = "Enter";
        yank_id = "Rune[i]";
        collapse_parent_node = "Rune[-]";
        move_to_parent_node = "Rune[p]";
      };

      messages_list = {
        select_previous = "Rune[k]";
        select_next = "Rune[j]";
        select_first = "Rune[g]";
        select_last = "Rune[G]";
        select_reply = "Rune[s]";
        reply = "Rune[r]";
        reply_mention = "Rune[R]";
        cancel = "Esc";
        delete = "Rune[d]";
        open = "Rune[o]";
        yank_content = "Rune[y]";
        yank_url = "Rune[u]";
        yank_id = "Rune[i]";
      };

      message_input = {
        send = "Enter";
        cancel = "Esc";
        tab_complete = "Tab";
        open_editor = "Ctrl+E";
        open_file_picker = "Ctrl+P";
      };

      mentions_list = {
        up = "Up";
        down = "Down";
      };
    };

    theme = {
      title = {
        alignment = "left";
        normal_style = {attributes = "dim";};
        active_style = {
          foreground = "purple";
          attributes = "bold";
        };
      };

      border = {
        enabled = true;
        padding = [0 0 1 1];
        normal_style = {attributes = "dim";};
        active_style = {
          foreground = "purple";
          attributes = "bold";
        };
        normal_set = "plain";
        active_set = "plain";
      };

      guilds_tree = {
        auto_expand_folders = false;
        graphics = true;
        graphics_color = "default";
      };

      messages_list = {
        reply_indicator = ">";
        forwarded_indicator = "<";
        mention_style = {foreground = "blue";};
        emoji_style = {foreground = "green";};
        url_style = {foreground = "blue";};
        attachment_style = {foreground = "yellow";};
      };

      mentions_list = {
        min_width = 20;
        max_height = 0;
      };
    };
  };
}
