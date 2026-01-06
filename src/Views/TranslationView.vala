/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

/**
 * Main view for translations. Mostly a Gtk.Paned with SourcePane and TargetPane with a couple binds for ease of control.
 */
public class MrWorldwide.TranslationView : Gtk.Box {

    private Gtk.Paned paned {get; set;}
    public MrWorldwide.SourcePane source_pane;
    public MrWorldwide.TargetPane target_pane;

    // Add a debounce so we aren't requesting the API constantly
    public const int DEBOUNCE_INTERVAL = 1250; // ms
    public uint debounce_timer_id = 0;

    public SimpleActionGroup actions { get; construct; }
    public const string ACTION_PREFIX = "translation-view.";
    public const string ACTION_TOGGLE_ORIENTATION = "toggle_orientation";
    public const string ACTION_TRANSLATE = "translate";
    public const string ACTION_CLEAR_TEXT = "clear_text";

    public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();
    private const GLib.ActionEntry[] ACTION_ENTRIES = {
        { ACTION_TOGGLE_ORIENTATION, toggle_orientation},
        { ACTION_TRANSLATE, translate_now},
        { ACTION_CLEAR_TEXT, action_clear_text}
    };

    construct {
        orientation = HORIZONTAL;
        spacing = 0;

        var actions = new SimpleActionGroup ();
        actions.add_action_entries (ACTION_ENTRIES, this);
        insert_action_group ("translation-view", actions);

        source_pane = new MrWorldwide.SourcePane ();
        var selected_source_language = Application.settings.get_string ("source-language");

        source_pane.language = selected_source_language;

        target_pane = new MrWorldwide.TargetPane ();
        var selected_target_language = Application.settings.get_string ("target-language");
        target_pane.language = selected_target_language;

        paned = new Gtk.Paned (HORIZONTAL);
        paned.start_child = source_pane;
        paned.end_child = target_pane;

        append (paned);
        
        /* ---------------- CONNECTS ---------------- */
        // Logic for toggling the panes/layout
        on_orientation_toggled ();
        Application.settings.changed["vertical-layout"].connect (on_orientation_toggled);

        // translate when text is entered or user changes any language or option
        source_pane.textview.buffer.changed.connect (on_text_to_translate);
        source_pane.language_changed.connect (on_text_to_translate);
        target_pane.language_changed.connect (on_text_to_translate);
        Application.settings.changed["context"].connect (on_text_to_translate);
        Application.settings.changed["formality"].connect (on_text_to_translate);

        Application.settings.changed["auto-translate"].connect (() => {
            if (Application.settings.get_boolean ("auto-translate")) {
                on_text_to_translate ();
            }
        });

        source_pane.scrolledwindow.vadjustment.bind_property (
            "value",
            target_pane.scrolledwindow.vadjustment, "value",
            GLib.BindingFlags.SYNC_CREATE | GLib.BindingFlags.BIDIRECTIONAL
        );
    }

    public void switch_languages () {
        var newtarget = source_pane.language;
        var newtarget_text = source_pane.text;

        var newsource = target_pane.language;
        var newsource_text = target_pane.text;

        source_pane.language = newsource;
        source_pane.text = newsource_text;

        target_pane.language = newtarget;
        target_pane.text = newtarget_text;
    }

    public void on_orientation_toggled () {
        if (Application.settings.get_boolean ("vertical-layout")) {            
            paned.orientation = Gtk.Orientation.VERTICAL;
        } else {
            paned.orientation = Gtk.Orientation.HORIZONTAL;
        }
    }

    public void on_text_to_translate () {
        if (source_pane.language == target_pane.language) {
            source_pane.message (_("Target language is the same as source"));
            return;
        }

        // If auto translate is off, forget it
        if (!Application.settings.get_boolean ("auto-translate")) {
            return;
        }

        debug ("The buffer has been modified, starting the debounce timer");
        if (debounce_timer_id != 0) {
            GLib.Source.remove (debounce_timer_id);
        }

        debounce_timer_id = Timeout.add (DEBOUNCE_INTERVAL, () => {
            debounce_timer_id = 0;
            translate_now ();
            return GLib.Source.REMOVE;
        });

    }


    public void toggle_orientation () {
        Application.settings.set_boolean (
            "vertical-layout",
            ! Application.settings.get_boolean ("vertical-layout")
        );
    }

    public void translate_now () {
        var to_translate = source_pane.text;
        if (to_translate.chomp () == "" ) {
            target_pane.clear ();
            return;
        }

        target_pane.spin (true);
        Application.backend.send_request (to_translate);
    }

    public void action_clear_text () {
        source_pane.clear ();
        target_pane.clear ();
        source_pane.message (_("Cleared!"));
    }

    public void action_load_text () {
        source_pane.action_load_text ();
    }

    public void action_save_text () {
        target_pane.action_save_text ();
    }
}