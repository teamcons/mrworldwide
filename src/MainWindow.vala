/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: {{YEAR}} {{DEVELOPER_NAME}} <{{DEVELOPER_EMAIL}}>
*/

public class MainWindow : Gtk.ApplicationWindow {
    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            default_height: 300,
            default_width: 300,
            icon_name: ".thumbtack",
            title: _("My App Name")
        );
    }

    static construct {
		weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
		default_theme.add_resource_path ("com/github/elfenware/thumbtack/");
	}

    construct {
        // Set default elementary thme
        var gtk_settings = Gtk.Settings.get_default ();
        gtk_settings.gtk_icon_theme_name = "elementary";
        if (!(gtk_settings.gtk_theme_name.has_prefix ("io.elementary.stylesheet"))) {
            gtk_settings.gtk_theme_name = "io.elementary.stylesheet.blueberry";
        }


        // We need to hide the title area for the split headerbar
        var everything = new Gtk.Box (HORIZONTAL, 6) ;

        var diceentry = new Gtk.Entry () {
            tooltip_text = "1d6 2d4"
        };
        everything.append (diceentry);

        var header = new Gtk.HeaderBar () ;
        header.show_title_buttons = true;
        header.title_widget = everything;

        set_titlebar (header);



        var null_title = new Gtk.Grid () {
            visible = false
        };
        child = (null_title);


    }
}