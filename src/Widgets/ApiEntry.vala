/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldWide.ApiEntry : Gtk.Box {

    private Gtk.PasswordEntry api_entry;
    private Gtk.Button api_paste;
    private const string LINK = "https://www.deepl.com/your-account/keys";

    construct {
        orientation = Gtk.Orientation.HORIZONTAL;
        spacing = 3;

        api_entry = new Gtk.PasswordEntry () {
        placeholder_text = _("Enter API key here"),
        show_peek_icon = true,
        hexpand = true,
        halign = Gtk.Align.FILL
        };

        api_paste = new Gtk.Button.from_icon_name ("edit-paste") {
            tooltip_text = _("Paste from clipboard")
        };

        append (api_entry);
        append (api_paste);

        var hint = new Gtk.Button.from_icon_name ("help-contents") {
          tooltip_text = _("You can get an API key here")
        };

        append (hint);

        hint.clicked.connect (open_webpage);
        api_paste.clicked.connect (paste_from_clipboard);
        Application.settings.bind ("key", api_entry, "text", SettingsBindFlags.DEFAULT);
    }


  private void paste_from_clipboard () {
    var clipboard = Gdk.Display.get_default ().get_clipboard ();
    clipboard.read_text_async.begin ((null), (obj, res) => {
      try {

        var pasted_text = clipboard.read_text_async.end (res);
        /* Clean up a bit this mess as the user is likely to have copied unwanted strings with it */
        string[] clutter_chars = {" ", "\n", ";"};
        foreach (var clutter in clutter_chars) {
          pasted_text = pasted_text.replace (clutter, "");
        }

        this.api_entry.text = pasted_text;

      } catch (Error e) {
        print ("Cannot access clipboard: " + e.message);
      }
    });
  }

  private void open_webpage () {
    try {
      AppInfo.launch_default_for_uri (LINK, null);
    } catch (Error e) {
      warning ("%s\n", e.message);
    }
  }

  //  private void update_usage () {
  //    api_usage.value = Application.backend.current_word_usage;
  //    api_usage.max_value = Application.backend.max_word_usage;

  //    api_usage.tooltip_text = _("%s characters translated / %s maximum characters on your plan").printf (
  //      api_usage.value.to_string (), 
  //      api_usage.max_value.to_string ());
  //  }
}
