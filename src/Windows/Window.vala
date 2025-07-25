/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

public class MrWorldWide.Window : Gtk.Window {

public Gtk.Spinner loading;
public Gtk.Revealer loading_revealer;
private Gtk.Paned paned;
public MrWorldWide.Pane source_pane;
public MrWorldWide.Pane target_pane;
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

        restore_state ();


        title = _("Captain WorldWide");
        Gtk.Label title_widget = new Gtk.Label (_("Captain WorldWide"));
        title_widget.add_css_class (Granite.STYLE_CLASS_TITLE_LABEL);

        var headerbar = new Gtk.HeaderBar ();
        headerbar.title_widget = title_widget;
        headerbar.add_css_class (Granite.STYLE_CLASS_FLAT);

        set_titlebar (headerbar);


        var popover_button = new Gtk.MenuButton () {
        icon_name = "open-menu",
        tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>M", "M"}, _("Settings")),
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


        var sources = MrWorldWide.SourceLang ();
        var targets = MrWorldWide.TargetLang ();

        source_pane = new MrWorldWide.Pane (sources);
        target_pane = new MrWorldWide.Pane (targets);

        paned = new Gtk.Paned (HORIZONTAL);
        paned.start_child = source_pane;
        paned.end_child = target_pane;

        var scrolled = new Gtk.ScrolledWindow () {
            child = paned
        };

        child = scrolled;
    }

    private void restore_state () {
        var rect = Gdk.Rectangle ();
        Application.settings.get ("window-size", "(ii)", out rect.width, out rect.height);

        default_width = rect.width;
        default_height = rect.height;
    }

    private void on_menu () {
        menu_popover.popup ();
    }

}