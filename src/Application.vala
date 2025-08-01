/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: {{YEAR}} {{DEVELOPER_NAME}} <{{DEVELOPER_EMAIL}}>
*/

public class MrWorldWide.Application : Gtk.Application {
    public Window main_window;

    public static Settings settings;
    public static DeepL backend;

    public Application () {
        Object (
            application_id: "io.github.teamcons.mrworldwide",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    static construct {
        settings = new GLib.Settings ("io.github.teamcons.mrworldwide");

        // Backend takes care of the async for us. We give it the text
        // And it will emit a signal whenever finished, which we can connect to
        backend = new DeepL ();
    }

    protected override void startup () {
        base.startup ();

        Granite.init ();

        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (GETTEXT_PACKAGE);

        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        // Also follow dark if system is dark lIke mY sOul.
        gtk_settings.gtk_application_prefer_dark_theme = (
	            granite_settings.prefers_color_scheme == DARK
            );
	
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = (
                    granite_settings.prefers_color_scheme == DARK
                );
        });

        var quit_action = new SimpleAction ("quit", null);
        add_action (quit_action);
        set_accels_for_action ("app.quit", {"<Control>q"});
        quit_action.activate.connect (quit);

        var menu_action = new SimpleAction ("menu", null);
        add_action (menu_action);
        set_accels_for_action ("app.menu", {"<Control>m"});

        var toggle_view_action = new SimpleAction ("toggle_view", null);
        add_action (toggle_view_action);
        set_accels_for_action ("app.toggle_view", {"<Control>o"});

        var switch_languages = new SimpleAction ("switch_languages", null);
        add_action (switch_languages);
        set_accels_for_action ("app.switch_languages", {"<Control>i"});

        var clear_source = new SimpleAction ("clear_source", null);
        add_action (clear_source);
        set_accels_for_action ("app.clear_source", {"<Control>l"});
    }

    protected override void activate () {
        if (main_window != null) {
			main_window.present ();
			return;
		}



        var main_window = new Window (this);

        /*
        * This is very finicky. Bind size after present else set_titlebar gives us bad sizes
        * Set maximize after height/width else window is min size on unmaximize
        * Bind maximize as SET else get get bad sizes
        */
        settings = new Settings ("io.github.teamcons.mrworldwide");
        settings.bind ("window-height", main_window, "default-height", SettingsBindFlags.DEFAULT);
        settings.bind ("window-width", main_window, "default-width", SettingsBindFlags.DEFAULT);

        if (settings.get_boolean ("window-maximized")) {
            main_window.maximize ();
        }

        settings.bind ("window-maximized", main_window, "maximized", SettingsBindFlags.SET);

        // Use Css
        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/io/github/teamcons/mrworldwide/Application.css");

        Gtk.StyleContext.add_provider_for_display (
            Gdk.Display.get_default (),
            provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

        main_window.present ();
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}