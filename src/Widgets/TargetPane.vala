/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

/**
 * Specialized subclass of Pane. The Stack is used to display waiting
 */
public class Inscriptions.TargetPane : Inscriptions.Pane {

    Gtk.WindowHandle placeholder_handle;
    Gtk.Spinner loading;
    Gtk.WindowHandle spin_view;

    private const float DEBOUNCE_IN_S = ((float)TranslationView.DEBOUNCE_INTERVAL) / 1000;

    public TargetPane () {
        var model = new Inscriptions.DDModel ();
        foreach (var language in Inscriptions.TargetLang ()) {
            model.model_append (language);
        }
        base (model);
    }

    construct {
        dropdown.tooltip_text = _("Set the language to translate to");
        //textview.editable = false;

        /* -------- PLACEHOLDER -------- */
        var placeholder_box = new Gtk.Box (VERTICAL, 12) {
            hexpand = vexpand = true,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
        };
        
        var placeholder = new Gtk.Label (_("Ready to translate")) {
            wrap = true
        };
        placeholder.add_css_class (Granite.STYLE_CLASS_H2_LABEL);

        var placeholder_switcher = new Granite.ModeSwitch.from_icon_name ("input-mouse-symbolic", "tools-timer-symbolic") {
            tooltip_text = _("Switch between click to translate // translate %.2fs after typing has stopped").printf (DEBOUNCE_IN_S),
            halign = Gtk.Align.CENTER,
        };

        placeholder_box.append (placeholder);
        placeholder_box.append (placeholder_switcher);

        placeholder_handle = new Gtk.WindowHandle () {
            child = placeholder_box
        };
        stack.add_child (placeholder_handle);
        show_placeholder ();

        /* -------- SPINNER -------- */
        loading = new Gtk.Spinner () {
            valign = Gtk.Align.CENTER,
            width_request = 64,
            height_request = 64
        };

        spin_view = new Gtk.WindowHandle () {
            child = loading
        };

        stack.add_child (spin_view);


        /* -------- TOOLBAR -------- */
        var auto_switcher = new Granite.ModeSwitch.from_icon_name ("input-mouse-symbolic", "tools-timer-symbolic") {
            tooltip_text = _("Switch between click to translate // translate %.2fs after typing has stopped").printf (DEBOUNCE_IN_S)
        };

        actionbar.pack_start (auto_switcher);

        /* -------- TOOLBAR -------- */
        var copy = new Gtk.Button.from_icon_name ("edit-copy-symbolic") {
            tooltip_text = _("Copy to clipboard")
        };
        actionbar.pack_end (copy);

        var save_as_button = new Gtk.Button.from_icon_name ("document-save-as-symbolic") {
            action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_SAVE_TEXT,
            tooltip_markup = Granite.markup_accel_tooltip (
                    {"<Control><Shift>s"}, 
                    _("Save the translation in a text file")
            )
        };

        actionbar.pack_end (save_as_button);

        /***************** CONNECTS *****************/

        Application.settings.bind ("auto-translate", 
            auto_switcher, "active", 
            GLib.SettingsBindFlags.DEFAULT);

        Application.settings.bind ("auto-translate", 
            placeholder_switcher, "active", 
            GLib.SettingsBindFlags.DEFAULT);

        language = Application.settings.get_string ("target-language");
        Application.settings.bind (
          "target-language", 
          this, 
          "language", 
          GLib.SettingsBindFlags.DEFAULT
        );

        Application.settings.changed["auto-translate"].connect (on_auto_translate_changed);
        copy.clicked.connect (copy_to_clipboard);
        language_changed.connect (on_language_changed);
        textview.buffer.changed.connect (on_buffer_changed);
    }

    private void on_auto_translate_changed () {        
        if (Application.settings.get_boolean ("auto-translate")) {
            // TRANSLATORS: This is for a small notification toast. Very little space is available
            message (_("Translation %.2fs after typing").printf (DEBOUNCE_IN_S));

        } else {
            // TRANSLATORS: This is for a small notification toast. Very little space is available
            message (_("Automatic translation paused"));
        }
    }

    private void on_language_changed (string code) {
        Application.settings.set_string ("target-language", code);
        clear ();
    }

    private void copy_to_clipboard () {
        var clipboard = Gdk.Display.get_default ().get_clipboard ();
        clipboard.set_text (textview.buffer.text);
        message (_("Copied!"));
    }

    public void show_placeholder () {
        stack.visible_child = placeholder_handle;
    }

    public void spin (bool if_spin) {
        if (if_spin) {
            loading.start ();
            stack.visible_child = spin_view;
        } else {
            loading.stop ();
            stack.visible_child = main_view;
        }
        //loading_revealer.reveal_child = if_spin;
    }

    private void on_buffer_changed () {
        if (text.chomp () == "") {
            return;
        }

        stack.visible_child = main_view;
        textview.buffer.changed.disconnect (on_buffer_changed);
    }

    public void action_save_text () {

        var all_files_filter = new Gtk.FileFilter () {
        name = _("All files"),
        };
        all_files_filter.add_pattern ("*");

        var text_files_filter = new Gtk.FileFilter () {
        name = _("Text files"),
        };
        text_files_filter.add_mime_type ("text/*");

        var filter_model = new ListStore (typeof (Gtk.FileFilter));
        filter_model.append (all_files_filter);
        filter_model.append (text_files_filter);

        var save_dialog = new Gtk.FileDialog () {
            //TRANSLATORS: The following text is for the dialog to save the translation
            title = _("Save translation to text file"),
            accept_label = _("Save"),
            initial_name = _("translation.txt"),
            default_filter = text_files_filter,
            filters = filter_model,
            modal = true
        };

        
        save_dialog.save.begin (Application.main_window, null, (obj, res) => {
            try {
                var file = save_dialog.save.end (res);
                    var content = this.text;
                    FileUtils.set_contents (file.get_path (), content);

            } catch (Error err) {
                warning ("Failed to save file: %s", err.message);
            }
        });
    }
}