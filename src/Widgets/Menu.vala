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

    //NOTE: Gtk.PasswordEntry ? No ability to paste, but securener
    // TODO: Secondary button is a paste button

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

    var api_paste = new Gtk.Button.from_icon_name ("edit-paste-symbolic") {
    tooltip_text = _("Paste Deepl API")
    };

    api_field.append (api_entry);
    api_field.append (api_paste);

    box.append (api_field);

    var link = "";
    var linkname = _("API Key");

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

    //box.append (hint);
    //box.append (hint_label);

    child = box;


    Application.settings.bind (
      "key",
      api_entry,
      "text",
      SettingsBindFlags.DEFAULT
    );

    }
}
