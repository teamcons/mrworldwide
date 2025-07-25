/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: {{YEAR}} {{DEVELOPER_NAME}} <{{DEVELOPER_EMAIL}}>
*/

public class MrWorldWide.Window : Gtk.ApplicationWindow {
    public Window (Gtk.Application application) {
        Object (
            application: application,
            default_height: 300,
            default_width: 300,
            icon_name: "io.github.teamcons.mrworldwide",
            title: _("My App Name")
        );
    }

    static construct {
		weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
		default_theme.add_resource_path ("io/github/teamcons/mrworldwide/");
	}

    construct {


        // Set default elementary thme
        var gtk_settings = Gtk.Settings.get_default ();
        gtk_settings.gtk_icon_theme_name = "elementary";
        if (!(gtk_settings.gtk_theme_name.has_prefix ("io.elementary.stylesheet"))) {
            gtk_settings.gtk_theme_name = "io.elementary.stylesheet.blueberry";
        }

        var start_header = new Gtk.HeaderBar () {
            show_title_buttons = false,
            title_widget = new Gtk.Label ("")
        };
        start_header.add_css_class (Granite.STYLE_CLASS_FLAT);
        start_header.pack_start (new Gtk.WindowControls (Gtk.PackType.START));

        var start_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        start_box.append (start_header);

        var end_header = new Gtk.HeaderBar () {
            show_title_buttons = false
        };
        end_header.add_css_class (Granite.STYLE_CLASS_FLAT);
        end_header.pack_end (new Gtk.WindowControls (Gtk.PackType.END));

        var end_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        end_box.add_css_class (Granite.STYLE_CLASS_VIEW);
        end_box.append (end_header);

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            position = 275,
            start_child = start_box,
            end_child = end_box,
            resize_start_child = false,
            shrink_end_child = false,
            shrink_start_child = false
        };

        // We need to hide the title area for the split headerbar
        var null_title = new Gtk.Grid () {
            visible = false
        };
        set_titlebar (null_title);

        child = paned;

        // Set default elementary thme
        var gtk_settings = Gtk.Settings.get_default ();
        gtk_settings.gtk_icon_theme_name = "elementary";
        if (!(gtk_settings.gtk_theme_name.has_prefix ("io.elementary.stylesheet"))) {
            gtk_settings.gtk_theme_name = "io.elementary.stylesheet.blueberry";
        }
    }
}