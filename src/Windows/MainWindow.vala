/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

public class MrWorldwide.MainWindow : Gtk.Window {

    private Gtk.Revealer back_revealer;

    private Gtk.Button switchlang_button;
    private Gtk.MenuButton popover_button;

    private Gtk.Stack stack_window_view;
    public MrWorldwide.TranslationView translation_view;
    private MrWorldwide.ErrorView? errorview = null;

    public MrWorldwide.SettingsPopover menu_popover;

    public SimpleActionGroup actions { get; construct; }
    public const string ACTION_PREFIX = "app.";
    public const string ACTION_MENU = "menu";
    public const string ACTION_TOGGLE_ORIENTATION = "toggle_orientation";
    public const string ACTION_SWITCH_LANG = "switch_languages";
    public const string ACTION_TRANSLATE = "translate";
    public const string ACTION_CLEAR = "clear_source";
    public const string ACTION_OPEN_FILE = "open_file";
    public const string ACTION_SAVE_FILE = "save_file";
    public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

    private const GLib.ActionEntry[] ACTION_ENTRIES = {
        { ACTION_MENU, on_menu},
        { ACTION_TOGGLE_ORIENTATION, toggle_orientation},
        { ACTION_SWITCH_LANG, switch_languages},
        { ACTION_TRANSLATE, on_translate},
        { ACTION_CLEAR, clear_source},
        { ACTION_OPEN_FILE, action_open_file},
        { ACTION_SAVE_FILE, action_save_file}
    };

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            default_height: 300,
            default_width: 300,
            icon_name: "io.github.teamcons.mrworldwide",
            title: _("Mr Worldwide")
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

        /* ---------------- HEADERBAR ---------------- */
        title = _("Mr Worldwide");
        Gtk.Label title_widget = new Gtk.Label (_("Mr Worldwide"));
        title_widget.add_css_class (Granite.STYLE_CLASS_TITLE_LABEL);

        var headerbar = new Gtk.HeaderBar ();
        headerbar.title_widget = title_widget;
        headerbar.add_css_class (Granite.STYLE_CLASS_FLAT);

        set_titlebar (headerbar);

        /* ---------------- PACK START ---------------- */

        //TRANSLATORS: Back button to go back to translating
        var back_button = new Gtk.Button.with_label (_("Back"));
        back_button.add_css_class (Granite.STYLE_CLASS_BACK_BUTTON);

        back_revealer = new Gtk.Revealer () {
            child = back_button,
            transition_type = Gtk.RevealerTransitionType.SWING_LEFT,
            reveal_child = false
        };
        headerbar.pack_start (back_revealer);
        

        //TRANSLATORS: This is for a button that switches source and target language
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

        var menu_popover = new MrWorldwide.SettingsPopover ();
        popover_button.popover = menu_popover;

        headerbar.pack_end (popover_button);

        //TRANSLATORS: This appears on a button at the top of the window. User clicks it to start translating
        var translate_button = new Gtk.Button () {
            label = _("Translate"),
            tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>T"}, _("Start translating the entered text"))
        };
        translate_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);
        translate_button.action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_TRANSLATE;

        var translate_revealer = new Gtk.Revealer () {
            child = translate_button,
            transition_type = Gtk.RevealerTransitionType.SWING_RIGHT
        };
        
        headerbar.pack_end (translate_revealer);


        /* ---------------- MAIN VIEW ---------------- */
        translation_view = new MrWorldwide.TranslationView ();
        stack_window_view = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.SLIDE_LEFT
        };
        stack_window_view.add_child (translation_view);
        stack_window_view.visible_child = translation_view;

        child = stack_window_view;

        set_focus (translation_view.source_pane.textview);

        // Listen if the backend recognize a language to switch to it
        // debatable whether to keep this idk
/*          backend.language_detected.connect ((detected_language_code) => {
            if (detected_language_code != null) {
                source_pane.pane.set_selected_language (detected_language_code);
            }
        });  */

        /***************** CONNECTS *****************/
        Application.backend.answer_received.connect (on_answer_received);

        Application.settings.bind (
            "auto-translate", 
            translate_revealer, 
            "reveal_child", 
            SettingsBindFlags.INVERT_BOOLEAN
        );

        back_button.clicked.connect (on_back_clicked);
    }

    public void on_translate () {
        Application.backend.send_request (translation_view.source_pane.text);
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

    private void action_open_file () {
        translation_view.source_pane.on_open_file ();
    }

    private void action_save_file () {
        translation_view.target_pane.on_save_as ();
    }

    private void on_back_clicked () {
        stack_window_view.visible_child = translation_view;
        stack_window_view.remove (errorview);
        errorview = null;
        back_revealer.reveal_child = false;
    }

    public void on_answer_received (uint status_code, string answer) {
        print (status_code.to_string ());

        if (status_code != Soup.Status.OK) {
            errorview = new MrWorldwide.ErrorView (status_code, answer);
            stack_window_view.add_child (errorview);
            stack_window_view.visible_child = errorview;
            back_revealer.reveal_child = true;
            return;
        }

        translation_view.target_pane.text = answer;
        translation_view.target_pane.spin (false);
        //stack_window_view.visible_child = translation_view;
    }
}

