/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldWide.Pane : Gtk.Box {

    public MrWorldWide.DDModel model;
    public Gtk.Revealer dropdown_revealer;
    public Gtk.DropDown dropdown;
    public MrWorldWide.Lang selected;
    public Gtk.TextView textview;
    public Gtk.ActionBar actionbar;
    private Gtk.Label count;

    public Gtk.Stack stack;
    public Granite.Placeholder placeholder;
    public Gtk.Box ready_box;

    private Gtk.Overlay overlay;
    private Granite.Toast toast;

    public string text {
        owned get { return textview.buffer.text;}
        set { textview.buffer.text = value;}
    }

    public string language {
        owned get { return get_selected_language ();}
        set { set_selected_language (value);}
    }

    public bool show_ui {
        get { return actionbar.revealed;}
        set { dropdown_revealer.reveal_child = actionbar.revealed = value;}
    }

    public signal void language_changed (string code = "");

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        spacing = 0;

        model = new MrWorldWide.DDModel ();
		dropdown = new Gtk.DropDown (null, null);
		dropdown.model = model.model;
		dropdown.factory = model.factory;
		dropdown.notify["selected-item"].connect(on_selected_language);

        dropdown_revealer = new Gtk.Revealer () {
            child = dropdown,
            reveal_child = true,
            transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN
        };

        textview = new Gtk.TextView () {
            hexpand = true,
            vexpand = true,
            valign = Gtk.Align.FILL,
            halign = Gtk.Align.FILL,
            left_margin = 12,
            right_margin = 12,
            top_margin = 6,
            bottom_margin = 6
        };
        textview.set_wrap_mode (Gtk.WrapMode.WORD_CHAR);

        var scrolled = new Gtk.ScrolledWindow () {
            child = textview
        };


        actionbar = new Gtk.ActionBar () {
            hexpand = true,
            vexpand = false,
            valign = Gtk.Align.END,
            height_request = 32,
            revealed = true
        };
        actionbar.add_css_class (Granite.STYLE_CLASS_FLAT);

        /*          count = new Gtk.Label ("") {
            sensitive = false
        };
        actionbar.pack_start (count);  */

        var handle = new Gtk.WindowHandle () {
            child = actionbar
        };

        ready_box = new Gtk.Box (VERTICAL, 0);
        
        ready_box.append (scrolled);
        ready_box.append (handle);

        placeholder = new Granite.Placeholder (_("Ready!"));
        //placeholder.icon = new ThemedIcon ("insert-text-symbolic");
        placeholder.description = _("Add in some text to get a translation");

        var placeholder_handle = new Gtk.WindowHandle () {
            child = placeholder
        };

        stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.CROSSFADE
        };
        stack.height_request = 130;
        stack.add_named (ready_box, "readybox");
        stack.add_named (placeholder_handle, "placeholder");

        overlay = new Gtk.Overlay ();
        toast = new Granite.Toast ("") {
            valign = Gtk.Align.START
        };

        append (dropdown_revealer);
        append (stack);

        //append (scrolled);
        //append (handle);

        /***************** CONNECTS *****************/
        //on_buffer_changed ();
        //textview.buffer.changed.connect (on_buffer_changed);
    }

    public void on_selected_language () {
        selected = dropdown.get_selected_item() as Lang;
		language_changed (selected.code);
        print ("\nS selected %s:%s", selected.code, selected.name);
    }

    private void set_selected_language (string code) {
        var position = model.model_where_code (code);
        dropdown.set_selected (position);
    }

    private string get_selected_language () {
        selected = dropdown.get_selected_item() as Lang;
        return selected.code;
    }

/*      private void on_buffer_changed () {
        var len = textview.buffer.text.length.to_string ();
        count.label = len;
        ///TRANSLATORS: %s is replaced by a number
        count.tooltip_text = _("Counted %s characters").printf (len);
    }  */

    public void clear () {
        this.textview.buffer.text = "";
    }

    public void load_model (Lang[] langs) {
                foreach (var language in langs) {
            model.model_append (language);
        }

    }
}