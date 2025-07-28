/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

public class MrWorldWide.OptionsMenu : Gtk.Popover {

  construct {

    width_request = 240;

    var box = new Gtk.Box (VERTICAL, 0) {
      margin_top = 6,
      margin_bottom = 6,
      margin_start = 6,
      margin_end = 6
    };

    var context_entry = new Gtk.Entry ();
    context_entry.placeholder_text = _("Enter context here");
    box.append (context_entry);

    child = box;

    Application.settings.bind (
      "context", 
      context_entry, 
      "text", 
      SettingsBindFlags.DEFAULT
    );
  }
}
