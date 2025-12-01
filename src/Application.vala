/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: {{YEAR}} {{DEVELOPER_NAME}} <{{DEVELOPER_EMAIL}}>
*/

public class MrWorldwide.Application : Gtk.Application {

    public static Settings settings;
    public static DeepL backend;

    private bool new_window = false;

    public Application () {
        Object (
            application_id: "io.github.teamcons.mrworldwide",
            flags: ApplicationFlags.HANDLES_OPEN | ApplicationFlags.HANDLES_COMMAND_LINE
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

        var toggle_orientation_action = new SimpleAction ("toggle_orientation", null);
        add_action (toggle_orientation_action);
        //set_accels_for_action ("app.toggle_orientation", {"<Control>o"});

        var switch_languages = new SimpleAction ("switch_languages", null);
        add_action (switch_languages);
        set_accels_for_action ("app.switch_languages", {"<Control>i"});

        var translate = new SimpleAction ("translate", null);
        add_action (translate);
        set_accels_for_action ("app.translate", {"<Control>t"});

        var clear_source = new SimpleAction ("clear_source", null);
        add_action (clear_source);
        set_accels_for_action ("app.clear_source", {"<Control>l"});

        var open_file = new SimpleAction ("open_file", null);
        add_action (open_file);
        set_accels_for_action ("app.open_file", {"<Control>o"});

        var save_file = new SimpleAction ("save_file", null);
        add_action (save_file);
        set_accels_for_action ("app.save_file", {"<Control><Shift>s"});

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/io/github/teamcons/mrworldwide/Application.css");

        Gtk.StyleContext.add_provider_for_display (
            Gdk.Display.get_default (),
            provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

    }

    protected override void activate () {
        if ((get_windows ().length () == 0) || new_window) {
            open_new_window ();

        } else {
            foreach (var window in get_windows) {
                window.present ();
            }
        }
    }

    private void open_new_window () {
        var window = new MainWindow (this)
        /*
        * This is very finicky. Bind size after present else set_titlebar gives us bad sizes
        * Set maximize after height/width else window is min size on unmaximize
        * Bind maximize as SET else get get bad sizes
        */
        settings = new Settings ("io.github.teamcons.mrworldwide");
        settings.bind ("window-height", window, "default-height", SettingsBindFlags.DEFAULT);
        settings.bind ("window-width", window, "default-width", SettingsBindFlags.DEFAULT);

        if (settings.get_boolean ("window-maximized")) {
            window.maximize ();
        }

        settings.bind ("window-maximized", window, "maximized", SettingsBindFlags.SET);

        window.show ();
        window.present ();
    }

    protected override void open (File[] files, string hint) {
        if (active_window == null) {
            activate ();
        }
        var file = files [0];

        try {
            var content = "";
            FileUtils.get_contents (file.get_path (), out content);
            main_window.translation_view.source_pane.text = content;

        } catch (Error e) {
            warning ("Failed to open file: %s", e.message);

            var dialog = new Granite.MessageDialog (
                _("Couldn't open file"),
                e.message,
                new ThemedIcon ("document-open")
            ) {
                badge_icon = new ThemedIcon ("dialog-error"),
                modal = true,
                transient_for = main_window
            };
            dialog.present ();
            dialog.response.connect (dialog.destroy);
        }
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }

    public override int command_line (ApplicationCommandLine command_line) {
        debug ("Parsing commandline arguments...");

        OptionEntry[] CMD_OPTION_ENTRIES = {
                {"new-window", 'n', OptionFlags.NONE, OptionArg.NONE, ref new_window, _("Open a new window"), null}
        };

        // We have to make an extra copy of the array, since .parse assumes
        // that it can remove strings from the array without freeing them.
        string[] args = command_line.get_arguments ();
        string[] _args = new string[args.length];
        for (int i = 0; i < args.length; i++) {
            _args[i] = args[i];
        }

        try {
            var ctx = new OptionContext ();
            ctx.set_help_enabled (true);
            ctx.add_main_entries (CMD_OPTION_ENTRIES, null);
            unowned string[] tmp = _args;
            ctx.parse (ref tmp);

        } catch (OptionError e) {
            command_line.print ("error: %s\n", e.message);
            return 0;
        }

        hold ();
        activate ();
        return 0;
    }
}