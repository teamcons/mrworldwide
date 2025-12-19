/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldwide.Pane : Gtk.Box {

    public MrWorldwide.DDModel model {get; construct;}

    public Gtk.Revealer dropdown_revealer;
    public Gtk.DropDown dropdown;
    public MrWorldwide.Lang selected;
    public Gtk.TextView textview;
    public Gtk.ScrolledWindow scrolledwindow;
    public Gtk.ActionBar actionbar;
    private Gtk.Label count;

    public Gtk.Stack stack;
    public Gtk.Box main_view;

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

    public Pane (DDModel model) {
        Object (model: model);
    }

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        spacing = 0;

        var expression = new Gtk.PropertyExpression (typeof(MrWorldwide.Lang), null, "both");

		dropdown = new Gtk.DropDown (model.model, expression) {
            factory = model.factory,
            enable_search = true,
            search_match_mode= Gtk.StringFilterMatchMode.SUBSTRING
        };
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

        scrolledwindow = new Gtk.ScrolledWindow () {
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

        main_view = new Gtk.Box (VERTICAL, 0);
        
        main_view.append (scrolledwindow);
        main_view.append (handle);



        stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.CROSSFADE
        };
        stack.height_request = 130;
        stack.add_child (main_view);


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
        selected = dropdown.get_selected_item () as Lang;
		language_changed (selected.code);
        print ("\nS selected %s:%s", selected.code, selected.name);
    }

    private void set_selected_language (string code) {
        print ("got " + code + "\n");
        var position = model.model_where_code (code);
        dropdown.set_selected (position);
    }

    private string get_selected_language () {
        selected = dropdown.get_selected_item () as Lang;
                print ("is selected " + selected.code + selected.name + "\n");
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
}
