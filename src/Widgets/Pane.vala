/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldWide.Pane : Gtk.Box {

    public Gtk.TextView textview;
    public Gtk.MenuButton menu;
    public MrWorldWide.ShowLangs dropdown;
    public MrWorldWide.Lang[] languages;

    public Pane (Lang[] langs) {

        languages = langs;


        orientation = Gtk.Orientation.VERTICAL;
        spacing = 6;

        dropdown = new MrWorldWide.ShowLangs (languages);

        menu = new Gtk.MenuButton () {
            hexpand = true,
            popover = dropdown
        };


        //dropdown.selected = Application.settings.get_enum (lang_source).to_string ();
        
        
        append (dropdown);

        textview = new Gtk.TextView () {
            hexpand = true,
            vexpand = true,
            valign = Gtk.Align.START,
            halign = Gtk.Align.FILL
        };
        textview.set_wrap_mode (Gtk.WrapMode.WORD_CHAR);

        append (textview);
    }
}
