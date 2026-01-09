/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: {{YEAR}} {{DEVELOPER_NAME}} <{{DEVELOPER_EMAIL}}>
*/

public class Inscriptions.Application : Gtk.Application {

    internal static Settings settings;
    internal static DeepL backend;
    internal static MainWindow main_window;


    public const string ACTION_PREFIX = "app.";
    public const string ACTION_QUIT = "action_quit";

    public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

    private const GLib.ActionEntry[] ACTION_ENTRIES = {
        { ACTION_QUIT, quit}
    };

    public Application () {
        Object (
            application_id: "io.github.elly_codes.inscriptions",
            flags: ApplicationFlags.HANDLES_OPEN
        );
    }

    construct {
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (GETTEXT_PACKAGE);
    }

    static construct {
        settings = new GLib.Settings ("io.github.elly_codes.inscriptions");

        // Backend takes care of the async for us. We give it the text
        // And it will emit a signal whenever finished, which we can connect to
        backend = new DeepL ();
    }

    protected override void startup () {
        base.startup ();
        Gtk.init ();
        Granite.init ();

        // App
        add_action_entries (ACTION_ENTRIES, this);
        set_accels_for_action ("app.action_quit", {"<Control>q"});

        // Window
        set_accels_for_action ("window.menu", {"<Control>m"});
        set_accels_for_action ("window.switch_languages", {"<Control>i"});
        set_accels_for_action ("window.toggle_messages", {"<Control><Shift>m"});

        // Translation view
        set_accels_for_action ("window.toggle_orientation", {"<Control><Shift>o"});
        set_accels_for_action ("window.translate", {"<Control>t"});
        set_accels_for_action ("window.clear_text", {"<Control>l"});

        // Source & target
        set_accels_for_action ("window.load_text", {"<Control>o"});
        set_accels_for_action ("window.save_text", {"<Control>s", "<Control><Shift>s"});

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

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/io.github.elly_codes.inscriptions/Application.css");

        Gtk.StyleContext.add_provider_for_display (
            Gdk.Display.get_default (),
            provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

    }

    protected override void activate () {
        if (main_window != null) {
            main_window.present ();
            return;
        }

        main_window = new MainWindow (this);
        main_window.show ();
        main_window.present ();
    }

    protected override void open (File[] files, string hint) {
        if (main_window == null) {
            activate ();
        }
        var file = files [0];
        string content = "";

        try {
            FileUtils.get_contents (file.get_path (), out content);

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

        main_window.open (content);
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}