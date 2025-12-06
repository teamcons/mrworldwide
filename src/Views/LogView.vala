/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldwide.LogView : Gtk.Box {

    private string placeholder = _("Requests and server responses will show up here\n\n");
    private Gtk.TextView textview;
    private Gtk.Button clear_button;

    construct {
        orientation = VERTICAL;
        spacing = 0;

        textview = new Gtk.TextView () {
            editable = false,
            cursor_visible = false,
            wrap_mode = Gtk.WrapMode.WORD_CHAR,
            vexpand = true,
            hexpand = true,
            top_margin = 12,
            left_margin = 12,
            right_margin = 12,
            bottom_margin = 12
        };
        textview.add_css_class (Granite.STYLE_CLASS_TERMINAL);

        textview.buffer.text = placeholder;

        var scroll_box = new Gtk.ScrolledWindow () {
            child = textview,
            hscrollbar_policy = Gtk.PolicyType.NEVER
        };
        append (scroll_box);

        var box = new Gtk.ActionBar ();
        box.add_css_class (Granite.STYLE_CLASS_FLAT);

        var clear_button_label = new Gtk.Label (_("Clear"));
        var clear_button_box = new Gtk.Box (HORIZONTAL, 0);
        clear_button_box.append (new Gtk.Image.from_icon_name ("edit-clear-all-symbolic"));
        clear_button_box.append (clear_button_label);

        clear_button = new Gtk.Button () {
            child = clear_button_box,
            tooltip_text = _("Clear all messages"),
            sensitive = false
        };
        clear_button.add_css_class (Granite.STYLE_CLASS_FLAT);
        clear_button_label.mnemonic_widget = clear_button;


        box.pack_start (clear_button);
        var handle = new Gtk.WindowHandle () {
            child = box
        };

        append (handle);

        clear_button.clicked.connect (on_clear);
        Application.backend.logger.set_printer (display_routine);
    }

    private void display_routine (Soup.Logger _1, Soup.LoggerLogLevel _2, char dir, string text) {
        clear_button.sensitive = true;

        // Lets avoid people posting their API key with their logs when reporting issues
        if ("Authorization:" in text) {
            text = "Authorization: DeepL-Auth-Key [REDACTED]";
        }

        var newline = ("%c %s\n").printf (dir, text);
        stdout.printf (newline);
        textview.buffer.text += newline;
    }

    private void on_clear () {
        textview.buffer.text = placeholder;
        clear_button.sensitive = false;
    }
}