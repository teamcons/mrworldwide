/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: {{YEAR}} {{DEVELOPER_NAME}} <{{DEVELOPER_EMAIL}}>
*/

public class MyApp : Gtk.Application {
    public MainWindow main_window;

    public MyApp () {
        Object (
            application_id: "{{APPLICATION_ID}}",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void startup () {
        base.startup ();

        Granite.init ();

        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (GETTEXT_PACKAGE);

        var quit_action = new SimpleAction ("quit", null);

        add_action (quit_action);
        set_accels_for_action ("app.quit", {"<Control>q"});

        quit_action.activate.connect (quit);
    }

    protected override void activate () {
        if (main_window != null) {
			main_window.present ();
			return;
		}

        var main_window = new MainWindow (this);

        /*
        * This is very finicky. Bind size after present else set_titlebar gives us bad sizes
        * Set maximize after height/width else window is min size on unmaximize
        * Bind maximize as SET else get get bad sizes
        */
        var settings = new Settings ("{{APPLICATION_ID}}");
        settings.bind ("window-height", main_window, "default-height", SettingsBindFlags.DEFAULT);
        settings.bind ("window-width", main_window, "default-width", SettingsBindFlags.DEFAULT);

        if (settings.get_boolean ("window-maximized")) {
            main_window.maximize ();
        }

        settings.bind ("window-maximized", main_window, "maximized", SettingsBindFlags.SET);

        // Use Css
        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/{{APPLICATION_ID_GSCHEMA}}/Application.css");

        Gtk.StyleContext.add_provider_for_display (
            Gdk.Display.get_default (),
            provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

        main_window.present ();
    }

    public static int main (string[] args) {
        return new MyApp ().run (args);
    }
}