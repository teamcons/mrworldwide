/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

public class MrWorldWide.ShowLangs : Gtk.Popover {

  public MrWorldWide.Lang[] languages;
  signal void selected (Lang selected_language);

  private Gtk.Button[] entries;

    public ShowLangs (Lang[] langs) {

        languages = langs;

    hexpand = true;
    vexpand = false;
    valign = Gtk.Align.START;
    halign = Gtk.Align.FILL;
    
    var box = new Gtk.Box (VERTICAL, 6) {
      margin_top = margin_bottom = 6,
      margin_start = 6,
      margin_end = 6
    };



    entries = new Gtk.Button[languages.length];

    for (var i = 0; i < languages.length; i++) {

      var button = new Gtk.Button ();
      entries[i] = button;

      button.clicked.connect ((selected_language) => {
        selected (languages[i]);
      });
      box.append (button);

    }

    child = box;


  }
}
