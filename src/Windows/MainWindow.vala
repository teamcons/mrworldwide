/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

public class MrWorldwide.MainWindow : Gtk.Window {

    private bool show_switcher {
        get {return headerbar.title_widget == switcher;}
        set {switcher_state (value);}
    }

    private Gtk.Revealer back_revealer;
    private Gtk.Button switchlang_button;
    private Gtk.Revealer switchlang_revealer;
    private Gtk.MenuButton popover_button;

    private Gtk.Stack stack_window_view;
    public MrWorldwide.TranslationView translation_view;
    private MrWorldwide.ErrorView? errorview = null;

    private Gtk.HeaderBar headerbar;
    private Gtk.StackSwitcher switcher;
    private Gtk.Label title_widget;

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
    public const string ACTION_TOGGLE_MESSAGES = "toggle_messages";
    public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

    private const GLib.ActionEntry[] ACTION_ENTRIES = {
        { ACTION_MENU, on_menu}, 
        { ACTION_TOGGLE_ORIENTATION, toggle_orientation}, 
        { ACTION_SWITCH_LANG, switch_languages}, 
        { ACTION_TRANSLATE, on_translate}, 
        { ACTION_CLEAR, clear_source}, 
        { ACTION_OPEN_FILE, action_open_file}, 
        { ACTION_SAVE_FILE, action_save_file}, 
        { ACTION_TOGGLE_MESSAGES, action_toggle_messages}
    };

    public MainWindow (Gtk.Application application) {
        Object (
            application: application, 
            default_height: 300, 
            default_width: 300, 
            icon_name: "io.github.teamcons.mrworldwide"
        );
    }

    construct {
        Intl.setlocale ();

        var actions = new SimpleActionGroup ();
        actions.add_action_entries (ACTION_ENTRIES, this);
        insert_action_group ("app", actions);

        /* ---------------- HEADERBAR ---------------- */
        //TRANSLATORS: Do not translate the name itself. You can write it in your writing system if that is usually done for your language
        title = _("Mr Worldwide");
        title_widget = new Gtk.Label (_("Mr Worldwide"));
        title_widget.add_css_class (Granite.STYLE_CLASS_TITLE_LABEL);

        headerbar = new Gtk.HeaderBar ();
        
        stack_window_view = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT
        };

        switcher = new Gtk.StackSwitcher () {
            stack = stack_window_view
        };
        
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
        switchlang_button.add_css_class ("rotato");
        switchlang_button.action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_SWITCH_LANG;

        switchlang_revealer = new Gtk.Revealer () {
            child = switchlang_button,
            transition_type = Gtk.RevealerTransitionType.SWING_LEFT,
            reveal_child = true
        };

        headerbar.pack_start (switchlang_revealer);


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

        //TRANSLATORS: The two following texts are for a button. The functionality is diabled. You can safely ignore these.
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

        stack_window_view.add_titled (translation_view, "translation", _("Translations"));


        child = stack_window_view;

        stack_window_view.visible_child = translation_view;
        set_focus (translation_view.source_pane.textview);

        // Listen if the backend recognize a language to switch to it
        // debatable whether to keep this idk
/*          backend.language_detected.connect ((detected_language_code) => {
            if (detected_language_code != null) {
                source_pane.pane.set_selected_language (detected_language_code);
            }
        });  */

        stack_window_view.add_titled (new LogView (), "messages", _("Messages"));


        // I know you can do this with binds, but it adds unnecessary read/writes everytime you do shit
        default_height = Application.settings.get_int ("window-height");
        default_width = Application.settings.get_int ("window-width");
        maximized = Application.settings.get_boolean ("window-maximized");

        /***************** CONNECTS AND BINDS *****************/
        check_up_key.begin (null);

        Application.backend.answer_received.connect (on_answer_received);

        Application.settings.bind (
            "auto-translate", 
            translate_revealer, 
            "reveal_child", 
            SettingsBindFlags.INVERT_BOOLEAN
        );

        back_button.clicked.connect (() => {on_back_clicked ();});

        close_request.connect (on_close);
    }

    private async bool check_up_key () {
        string key = yield Secrets.get_default ().load_secret ();

        if (key.chomp () == "") {
            on_error (MrWorldwide.StatusCode.NO_KEY, _("No saved API Key"));
            return false;
        }
        return true;
    }

    public void on_translate () {
        var to_translate = translation_view.source_pane.text.chug ();
        // Chug to save some billed characters on useless space
        if (to_translate == "") {
            return;
        }

        Application.backend.send_request (to_translate);
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
    
    public void on_answer_received (uint status_code, string? answer = null) {
        print (status_code.to_string ());

        if (status_code != Soup.Status.OK) {
            print ("Switching to error view, with status " + status_code.to_string () + "\nMessage: " + answer);
            on_error (status_code, answer);
            return;
        }

        if (answer == null) {
            return;
        }

        translation_view.target_pane.text = answer;
        translation_view.target_pane.spin (false);
        //stack_window_view.visible_child = translation_view;
    }

    private void on_back_clicked (bool? retry = false) {
        print ("\nBack to main view");
        Application.backend.answer_received.connect (on_answer_received);
        stack_window_view.visible_child = translation_view;
        stack_window_view.remove (errorview);
        errorview = null;
        back_revealer.reveal_child = false;
        switchlang_revealer.reveal_child = true;

        if (retry) {
            on_translate ();
        }
    }

    private void on_error (uint status_code, string? answer = null) {
        
            // ErrorView may need to do some fiddling. We reconnect when going back to main view via on_back_clicked
            Application.backend.answer_received.disconnect (on_answer_received);
            
            errorview = new MrWorldwide.ErrorView (status_code, answer);
            stack_window_view.add_titled (errorview, "error", _("Error"));
            stack_window_view.visible_child = errorview;

            switchlang_revealer.reveal_child = false;
            
            //if ((status_code != Soup.Status.FORBIDDEN) && (status_code != MrWorldwide.StatusCode.NO_KEY)) {
                back_revealer.reveal_child = true;
            //}
        
            errorview.return_to_main.connect (on_back_clicked);
    }

    private void action_toggle_messages () {
        switcher_state (!show_switcher);
    }

    private void switcher_state (bool if_show_switcher) {
        if (if_show_switcher) {
            headerbar.title_widget = switcher;

        } else {
            headerbar.title_widget = title_widget;
        }
    }

    private bool on_close () {
        int height, width;
        get_default_size (out width, out height);
        Application.settings.set_int ("window-height", height);
        Application.settings.set_int ("window-width", width);
        Application.settings.set_boolean ("window-maximized", maximized);
        return false;
    }

    public void open (string content) {
        translation_view.source_pane.text = content;
    }
}

