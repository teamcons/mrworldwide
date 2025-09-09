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
    public Gtk.Label count;
    public MrWorldWide.Lang[] langs;

    public signal void language_changed (string code = "");

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
            left_margin = 12,
            right_margin = 12
        };

        textview.set_wrap_mode (Gtk.WrapMode.WORD_CHAR);


        var scrolled = new Gtk.ScrolledWindow () {
            child = textview
        };

        append (scrolled);

        actionbar = new Gtk.ActionBar () {
            hexpand = true,
            vexpand = false,
            valign = Gtk.Align.END
        };
        actionbar.add_css_class (Granite.STYLE_CLASS_FLAT);
        actionbar.height_request = 32;


/*          count = new Gtk.Label ("") {
            sensitive = false
        };
        actionbar.pack_start (count);  */

        var handle = new Gtk.WindowHandle () {
            child = actionbar
        };

        append (handle);

        /***************** CONNECTS *****************/
        //on_buffer_changed ();
        //textview.buffer.changed.connect (on_buffer_changed);

    }

    public void on_selected_language () {
        selected = dropdown.get_selected_item() as Lang;
		language_changed (selected.code);
        print ("\nS selected %s:%s", selected.code, selected.name);
    }

    public void set_selected_language (string code) {
        var position = model.model_where_code (code);
        dropdown.set_selected (position);
    }

    public string get_selected_language () {
        selected = dropdown.get_selected_item() as Lang;
        return selected.code;
    }

    public void on_buffer_changed () {
        var len = textview.buffer.text.length.to_string ();
        count.label = len;
        ///TRANSLATORS: %s is replaced by a number
        count.tooltip_text = _("Counted %s characters").printf (len);
    }

    public void set_text (string text) {
        this.textview.buffer.text = text;
    }

    public string get_text () {
        return this.textview.buffer.text;
    }

    public void clear () {
        this.textview.buffer.text = "";
    }
}