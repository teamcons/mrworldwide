/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

public class MrWorldWide.SettingsPopover : Gtk.Popover {

  private Gtk.PasswordEntry api_entry;
  private Gtk.LevelBar api_usage;

  construct {
    width_request = 340;
    //halign = Gtk.Align.END;

    var box = new Gtk.Box (VERTICAL, 12) {
      margin_top = margin_bottom = 12,
      margin_start = 12,
      margin_end = 12
    };

    box.append (new OrientationBox ());
    box.append (new Gtk.Separator (HORIZONTAL));

    var api_field = new Gtk.Box (HORIZONTAL, 6) {
    hexpand = true,
    halign = Gtk.Align.FILL
    };

    api_entry = new Gtk.PasswordEntry () {
      placeholder_text = _("Enter API key here"),
      show_peek_icon = true,
      hexpand = true,
      halign = Gtk.Align.FILL
    };

    var api_paste = new Gtk.Button.from_icon_name ("edit-paste") {
    tooltip_text = _("Paste from clipboard")
    };

    api_field.append (api_entry);
    api_field.append (api_paste);

    box.append (api_field);

    var api_usage_label = new Gtk.Label (_("API Usage")) {
      halign = Gtk.Align.START
    };
    box.append (api_usage_label);


    api_usage = new Gtk.LevelBar ();
    api_usage.min_value = 0;

    box.append (api_usage);


    var link = "https://www.deepl.com/your-account/keys";
    var linkname = _("DeepL API Keys");

    var hint = new Gtk.LinkButton.with_label (
                                              link,
                                              linkname);

    box.append (hint);

    child = box;

    Application.backend.usage_retrieved.connect (update_usage);
    Application.backend.answer_received.connect (update_usage);

    Application.settings.bind (
      "key", 
      api_entry, 
      "text", 
      SettingsBindFlags.DEFAULT
    );

    api_paste.clicked.connect (paste_from_clipboard);
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

  private void update_usage () {
    api_usage.max_value = Application.backend.max_word_usage;
    api_usage.value = Application.backend.current_word_usage;

    api_usage.tooltip_text = _("%s characters translated / %s maximum characters on your plan").printf (
      api_usage.value.to_string (), 
      api_usage.max_value.to_string ());
  }
}
