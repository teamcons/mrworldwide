/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

public class MrWorldWide.Menu : Gtk.Popover {

  public Gtk.PasswordEntry api_entry;


  construct {

    var box = new Gtk.Box (VERTICAL, 6) {
      margin_top = margin_bottom = 6,
      margin_start = 6,
      margin_end = 6
    };

    var api_field = new Gtk.Box (HORIZONTAL, 0) {
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

    var link = "https://www.deepl.com/your-account/keys";
    var linkname = _("Deepl API Keys");

    var hint = new Gtk.LinkButton.with_label (
                                              link,
                                              linkname
      );

    var hint_label = new Granite.HeaderLabel (_("You can get an API key on Deepl Website")) {
                mnemonic_widget = hint,
                halign = Gtk.Align.START,
                hexpand = true,
                valign = Gtk.Align.START,
                margin_top = 0
    };

    box.append (hint);
    //box.append (hint_label);

    child = box;


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
}
