/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldwide.TranslationView : Gtk.Box {

    private Gtk.Paned paned {get; set;}
    public MrWorldwide.SourcePane source_pane;
    public MrWorldwide.TargetPane target_pane;

    // Add a debounce so we aren't requesting the API constantly
    public int interval = 1500; // ms
    public uint debounce_timer_id = 0;

    construct {
        orientation = HORIZONTAL;
        spacing = 0;

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

        // translate when text is entered or user changes any language
        source_pane.textview.buffer.changed.connect (on_text_to_translate);
        source_pane.language_changed.connect (on_text_to_translate);
        target_pane.language_changed.connect (on_text_to_translate);

        Application.settings.changed["context"].connect (on_text_to_translate);
        Application.settings.changed["formality"].connect (on_text_to_translate);

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
        // Avoid translating empty text (useless request)
        // If auto translate is off, forget it
        if (Application.settings.get_boolean ("auto-translate") && (source_pane.text != "" )) {

            debug ("The buffer has been modified, starting the debounce timer");
            if (debounce_timer_id != 0) {
                GLib.Source.remove (debounce_timer_id);
            }

            debounce_timer_id = Timeout.add (interval, () => {
                debounce_timer_id = 0;

                    // Start translating!
                    target_pane.spin (true);
                    Application.backend.send_request (source_pane.text);

                return GLib.Source.REMOVE;
            });
        } else {

            // Only in the case the source text is empty, do a cleanup
            if (source_pane.text == "" ) {
                target_pane.clear ();
            }
        }
    }

    public void clear_source () {
        source_pane.clear ();
        target_pane.clear ();
    }
}