/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

public class MrWorldWide.Window : Gtk.Window {

    private Gtk.MenuButton popover_button;
    public Gtk.Spinner loading;
    public Gtk.Revealer loading_revealer;
    private Gtk.Paned paned;
    public MrWorldWide.SourcePane source_pane;
    public MrWorldWide.TargetPane target_pane;
    public MrWorldWide.Menu menu_popover;

    public SimpleActionGroup actions { get; construct; }
    public const string ACTION_PREFIX = "app.";
    public const string ACTION_MENU = "menu";
    public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

    private const GLib.ActionEntry[] ACTION_ENTRIES = {
        { ACTION_MENU, on_menu}
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


        title = _("Mr WorldWide");
        Gtk.Label title_widget = new Gtk.Label (_("Mr WorldWide"));
        title_widget.add_css_class (Granite.STYLE_CLASS_TITLE_LABEL);

        var headerbar = new Gtk.HeaderBar ();
        headerbar.title_widget = title_widget;
        headerbar.add_css_class (Granite.STYLE_CLASS_FLAT);

        set_titlebar (headerbar);


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


        source_pane = new MrWorldWide.SourcePane ();
        var selected_source_language = Application.settings.get_string ("source-language");
        source_pane.pane.set_selected_language (selected_source_language);


        target_pane = new MrWorldWide.TargetPane ();
        var selected_target_language = Application.settings.get_string ("target-language");
        target_pane.pane.set_selected_language (selected_target_language);


        paned = new Gtk.Paned (HORIZONTAL);
        paned.start_child = source_pane;
        paned.end_child = target_pane;

        var pos = Application.settings.get_int ("panes-position");
        if (pos != 0) {
            paned.position = pos;
        }

        child = paned;

        set_focus (source_pane.pane.textview);


        source_pane.pane.changed.connect (on_source_changed);
        target_pane.pane.changed.connect (on_target_changed);


        paned.notify ["position"].connect (() => {
            Application.settings.set_int ("panes-position", paned.position);
        });


    }

    private void on_menu () {
        popover_button.activate ();
    }

    private void on_source_changed (string code) {
        Application.settings.set_string ("source-language", code);
    }

    private void on_target_changed (string code) {
        Application.settings.set_string ("target-language", code);
    }
    
}
