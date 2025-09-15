/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldWide.NoInternetView : Gtk.Box {

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        halign = Gtk.Align.FILL;
        valign = Gtk.Align.FILL;

        hexpand = true;
        vexpand = true;

        var image = new Gtk.Image.from_icon_name ("network-offline-symbolic");
        append (image);

        var title = new Granite.Placeholder (_("No Internet Connection")) {
            description = _("Please check your internet connection and try again."),
        };
        append (title);

        var button_retry = new Gtk.Button.with_label (_("Retry")) {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        append (button_retry);

        button_retry.clicked.connect (Application.backend.check_usage);



         var switch_reveal_console = new Granite.SwitchModelButton (_("Show Console"));
        append (switch_reveal_console);



        var console = new Gtk.TextView () {
            editable = false
        }
        console.add_css_class (Granite.STYLE_CLASS_TERMINAL);

        var scroll_console = new Gtk.ScrolledWindow {
            child = console
        }

        var revealer_console = Gtk.Revealer () {
            child = scroll_console
        };
        append (revealer_console);


        switch_reveal_console.bind_property ("active", revealer_console, "reveal-child", SYNC_CREATE);
    }
}