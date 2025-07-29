/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

public class MrWorldWide.Window : Gtk.Window {

    private Gtk.Button toggleview_button;
    private Gtk.Button switchlang_button;
    private Gtk.MenuButton popover_button;
    private Gtk.Spinner loading;
    private Gtk.Revealer loading_revealer;
    private Gtk.Paned paned;
    public MrWorldWide.SourcePane source_pane;
    public MrWorldWide.TargetPane target_pane;
    public MrWorldWide.Menu menu_popover;

    private DeepL backend;

    // Add a debounce so we aren't requesting the API constantly
    public int interval = 2000; // ms
    public uint debounce_timer_id = 0;

    public SimpleActionGroup actions { get; construct; }
    public const string ACTION_PREFIX = "app.";
    public const string ACTION_MENU = "menu";
    public const string ACTION_TOGGLE_VIEW = "toggle_view";
    public const string ACTION_SWITCH_LANG = "switch_languages";
    public const string ACTION_CLEAR = "clear_source";
    public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

    private const GLib.ActionEntry[] ACTION_ENTRIES = {
        { ACTION_MENU, on_menu},
        { ACTION_TOGGLE_VIEW, toggle_view},
        { ACTION_SWITCH_LANG, switch_languages},
        { ACTION_CLEAR, clear_source}
    };


    public Window (Gtk.Application application) {
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

        /* ---------------- HEADERBAR ---------------- */
        title = _("Mr WorldWide");
        Gtk.Label title_widget = new Gtk.Label (_("Mr WorldWide"));
        title_widget.add_css_class (Granite.STYLE_CLASS_TITLE_LABEL);

        var headerbar = new Gtk.HeaderBar ();
        headerbar.title_widget = title_widget;
        headerbar.add_css_class (Granite.STYLE_CLASS_FLAT);

        set_titlebar (headerbar);

        toggleview_button = new Gtk.Button.from_icon_name ("view-dual") {
            tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>O"}, _("Switch orientation")),
        };
        headerbar.pack_start (toggleview_button);

        switchlang_button = new Gtk.Button.from_icon_name ("media-playlist-repeat") {
            tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>I"}, _("Switch languages")),
        };
        headerbar.pack_start (switchlang_button);

        popover_button = new Gtk.MenuButton () {
        icon_name = "open-menu",
        tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>M"}, _("Settings")),
        };

        popover_button.set_primary (true);
        popover_button.set_direction (Gtk.ArrowType.NONE);

        var menu_popover = new MrWorldWide.Menu ();
        popover_button.popover = menu_popover;

        headerbar.pack_end (popover_button);
        loading = new Gtk.Spinner ();

        loading_revealer = new Gtk.Revealer () {
            child = loading,
            reveal_child = false,
            transition_type = Gtk.RevealerTransitionType.SWING_LEFT,
            transition_duration = 500
        };

        headerbar.pack_end (loading_revealer);


        /* ---------------- MAIN VIEW ---------------- */
        source_pane = new MrWorldWide.SourcePane ();
        var selected_source_language = Application.settings.get_string ("source-language");
        source_pane.pane.set_selected_language (selected_source_language);


        target_pane = new MrWorldWide.TargetPane ();
        var selected_target_language = Application.settings.get_string ("target-language");
        target_pane.pane.set_selected_language (selected_target_language);

        paned = new Gtk.Paned (HORIZONTAL);
        paned.start_child = source_pane;
        paned.end_child = target_pane;
        child = paned;

        set_focus (source_pane.pane.textview);




        /* ---------------- CONNECTS ---------------- */
        // Logic for toggling the panes/layout
        toggleview_button.clicked.connect (toggle_view);
        on_toggle_pane_changed ();
        Application.settings.changed["vertical-layout"].connect (on_toggle_pane_changed);

        switchlang_button.clicked.connect (switch_languages);    

        // Backend takes care of the async for us. We give it the text
        // And it will emit a signal whenever finished, which we can connect to
        backend = new DeepL ();

        // translate when text is entered or user changes any language
        source_pane.pane.textview.buffer.changed.connect (on_text_to_translate);
        source_pane.pane.language_changed.connect (on_text_to_translate);
        target_pane.pane.language_changed.connect (on_text_to_translate);

        // Connect to the backend and do stuff if answer
        backend.answer_received.connect (on_answer_received);

        // Listen if the backend recognize a language to switch to it
        // debatable whether to keep this idk
/*          backend.language_detected.connect ((detected_language_code) => {
            if (detected_language_code != null) {
                source_pane.pane.set_selected_language (detected_language_code);
            }
        });  */
    }

    private void on_menu () {
        popover_button.activate ();
    }

    private void toggle_view () {
        Application.settings.set_boolean (
            "vertical-layout",
            ! Application.settings.get_boolean ("vertical-layout")
        );
    }

    private void switch_languages () {
        var newtarget = source_pane.pane.get_selected_language ();
        var newsource = target_pane.pane.get_selected_language ();

        source_pane.pane.set_selected_language (newsource);
        target_pane.pane.set_selected_language (newtarget);
    }

    private void on_toggle_pane_changed () {
        if (Application.settings.get_boolean ("vertical-layout")) {            
            paned.orientation = Gtk.Orientation.VERTICAL;
            toggleview_button.remove_css_class ("rotated");

        } else {
            paned.orientation = Gtk.Orientation.HORIZONTAL;
            toggleview_button.add_css_class ("rotated");
        }
    }
    
    private void on_text_to_translate () {
        // Avoid translating empty text (useless request)
        if (source_pane.pane.get_text () != "") {

            debug ("The buffer has been modified, starting the debounce timer");
            if (debounce_timer_id != 0) {
                GLib.Source.remove (debounce_timer_id);
            }

            debounce_timer_id = Timeout.add (interval, () => {
                debounce_timer_id = 0;

                    // Start translating!
                    loading.start ();
                    loading_revealer.reveal_child = true;
                    backend.send_request (source_pane.pane.get_text ());

                return GLib.Source.REMOVE;
            });
        } else {
            target_pane.pane.set_text ("");
        }
    }

    private void on_answer_received (string answer) {
        target_pane.pane.set_text (answer);
        loading_revealer.reveal_child = false;
        loading.stop ();
    }

    
  private void clear_source () {
    source_pane.pane.set_text ("");
  }

}
