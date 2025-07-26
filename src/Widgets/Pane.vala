/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldWide.Pane : Gtk.Box {


    public MrWorldWide.DDModel model;
    public Gtk.DropDown dropdown;
    public MrWorldWide.Lang selected;

    public Gtk.TextView textview;
    public Gtk.ActionBar actionbar;


    public signal void changed (string code);

    public Pane (Lang[] langs) {

        orientation = Gtk.Orientation.VERTICAL;
        spacing = 6;


		model = new MrWorldWide.DDModel ();

        foreach (var language in langs) {
            model.model_append (language);
        }
		dropdown = new Gtk.DropDown (null, null);
		dropdown.model = model.model;
		dropdown.factory = model.factory;
		dropdown.notify["selected-item"].connect(on_selected_language);

        
        append (dropdown);

        textview = new Gtk.TextView () {
            hexpand = true,
            vexpand = true,
            valign = Gtk.Align.FILL,
            halign = Gtk.Align.FILL,
            margin_top = 6,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12,
        };

        textview.set_wrap_mode (Gtk.WrapMode.WORD_CHAR);
        append (textview);

        actionbar = new Gtk.ActionBar () {
            hexpand = true,
            vexpand = false,
            valign = Gtk.Align.END
        };

        var handle = new Gtk.WindowHandle () {
            child = actionbar
        };

        append (handle);

    }

    public void on_selected_language () {
        selected = dropdown.get_selected_item() as Lang;
		changed (selected.code);
        print("S selected %s:%s\n", selected.code, selected.name);
    }

    public void set_selected_language (string code) {
        var position = model.model_where_code (code);
        dropdown.set_selected (position);
    }

}
