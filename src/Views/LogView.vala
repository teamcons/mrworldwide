/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldwide.LogView : Gtk.Box {

    private Gtk.TextView textview;

    construct {
        orientation = VERTICAL;
        spacing = 0;

        textview = new Gtk.TextView () {
            editable = false,
            wrap_mode = Gtk.WrapMode.WORD,
            vexpand = true,
            hexpand = true
        };
        textview.add_css_class (Granite.STYLE_CLASS_TERMINAL);

        textview.buffer.text = _("Requests and server responses will show up here\n\n");

        var scroll_box = new Gtk.ScrolledWindow () {
            child = textview,
            margin_top = 6,
            margin_bottom = 6,
            margin_start = 6,
            margin_end = 6
        };

        append (scroll_box);

        // optional, stderr (vice stdout)
        Application.backend.logger.set_printer (display_routine);
    }

    private void display_routine (Soup.Logger _1, Soup.LoggerLogLevel _2, char dir, string text) {
        var newline = ("%c %s\n").printf (dir, text);
        stdout.printf (newline);
        textview.buffer.text += newline;
    }
}