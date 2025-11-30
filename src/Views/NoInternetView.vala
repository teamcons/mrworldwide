/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldwide.NoInternetView : Gtk.Box {

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

        if ( Environment.get_variable ("XDG_CURRENT_DESKTOP") == "Pantheon") {
            var link = Granite.SettingsUri.PERMISSIONS;
            var linkname = _("Check if Mr Worldwide is allowed to access the internet");
            var hint = new Gtk.LinkButton.with_label (link, linkname);
            append (hint);
        }

        button_retry.clicked.connect (Application.backend.check_usage);
    }
}