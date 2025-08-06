/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

public class MrWorldWide.MainWindow : Gtk.Window {

    private Gtk.Button switchlang_button;
    private Gtk.MenuButton popover_button;
    private Gtk.Spinner loading;
    private Gtk.Revealer loading_revealer;

    private MrWorldWide.TranslationView translation_view;
    public MrWorldWide.SettingsPopover menu_popover;

    public SimpleActionGroup actions { get; construct; }
    public const string ACTION_PREFIX = "app.";
    public const string ACTION_MENU = "menu";
    public const string ACTION_TOGGLE_ORIENTATION = "toggle_orientation";
    public const string ACTION_SWITCH_LANG = "switch_languages";
    public const string ACTION_TRANSLATE = "translate";
    public const string ACTION_CLEAR = "clear_source";
    public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

    private const GLib.ActionEntry[] ACTION_ENTRIES = {
        { ACTION_MENU, on_menu},
        { ACTION_TOGGLE_ORIENTATION, toggle_orientation},
        { ACTION_SWITCH_LANG, switch_languages},
        { ACTION_TRANSLATE, on_translate},
        { ACTION_CLEAR, clear_source}
    };

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            default_height: 300,
            default_width: 300,
            icon_name: "io.github.teamcons.mrworldwide",
            title: _("Mr WorldWide")
        );
    }

    static construct {
		weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
		default_theme.add_resource_path ("io/github/teamcons/mrworldwide/");
	}

    construct {
        Intl.setlocale ();

        var actions = new SimpleActionGroup ();
        actions.add_action_entries (ACTION_ENTRIES, this);
        insert_action_group ("app", actions);

        height_request = 240;


        /* ---------------- HEADERBAR ---------------- */
        title = _("Mr WorldWide");
        Gtk.Label title_widget = new Gtk.Label (_("Mr WorldWide"));
        title_widget.add_css_class (Granite.STYLE_CLASS_TITLE_LABEL);

        var headerbar = new Gtk.HeaderBar ();
        headerbar.title_widget = title_widget;
        headerbar.add_css_class (Granite.STYLE_CLASS_FLAT);

        set_titlebar (headerbar);

        /* ---------------- PACK START ---------------- */

        var options_menu = new MrWorldWide.OptionsPopover ();
        var options_button = new Gtk.MenuButton () {
          icon_name = "tag",
          popover = options_menu,
          tooltip_text = _("Change options for the translation"),
        };
        options_button.direction = Gtk.ArrowType.DOWN;

        headerbar.pack_start (options_button);

        switchlang_button = new Gtk.Button.from_icon_name ("media-playlist-repeat") {
            tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>I"}, _("Switch languages"))
        };
        switchlang_button.action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_SWITCH_LANG;
        headerbar.pack_start (switchlang_button);




        /* ---------------- PACK END ---------------- */



        popover_button = new Gtk.MenuButton () {
            icon_name = "open-menu",
            tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>M"}, _("Settings")),
        };

        popover_button.set_primary (true);
        popover_button.set_direction (Gtk.ArrowType.NONE);

        var menu_popover = new MrWorldWide.SettingsPopover ();
        popover_button.popover = menu_popover;

        headerbar.pack_end (popover_button);


        var translate_button = new Gtk.Button () {
            label = _("Translate")
        };
        translate_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);
        translate_button.action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_TRANSLATE;

        var translate_revealer = new Gtk.Revealer () {
            child = translate_button,
            transition_type = Gtk.RevealerTransitionType.SWING_LEFT,
            transition_duration = 250
        };
        
        headerbar.pack_end (translate_revealer);


        loading = new Gtk.Spinner ();
        loading_revealer = new Gtk.Revealer () {
            child = loading,
            reveal_child = false,
            transition_type = Gtk.RevealerTransitionType.SWING_LEFT,
            transition_duration = 250
        };

        headerbar.pack_end (loading_revealer);

        /* ---------------- MAIN VIEW ---------------- */
        translation_view = new MrWorldWide.TranslationView ();
        child = translation_view;

        set_focus (translation_view.source_pane.pane.textview);

        // Listen if the backend recognize a language to switch to it
        // debatable whether to keep this idk
/*          backend.language_detected.connect ((detected_language_code) => {
            if (detected_language_code != null) {
                source_pane.pane.set_selected_language (detected_language_code);
            }
        });  */

        Application.settings.bind (
            "auto-translate", 
            translate_revealer, 
            "reveal_child", 
            SettingsBindFlags.INVERT_BOOLEAN
        );

    }

    private void on_translate () {
        Application.backend.send_request (translation_view.source_pane.pane.get_text ());
    }

    private void on_menu () {
        popover_button.activate ();
    }

    private void toggle_orientation () {
        Application.settings.set_boolean (
            "vertical-layout",
            ! Application.settings.get_boolean ("vertical-layout")
        );
    }

    private void switch_languages () {
        translation_view.switch_languages ();
    }

    private void clear_source () {
        translation_view.clear_source ();
    }
}
