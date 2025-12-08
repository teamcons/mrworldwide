/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */
 public class MrWorldwide.TargetPane : MrWorldwide.Pane {


    private Gtk.WindowHandle placeholder_view;

    private Gtk.Spinner loading;
    private Gtk.WindowHandle spin_view;

    public TargetPane () {
        var model = new MrWorldwide.DDModel ();
        foreach (var language in MrWorldwide.TargetLang ()) {
            model.model_append (language);
        }
        base (model);
    }

    construct {
        dropdown.tooltip_text = _("Set the language to translate to");
        //textview.editable = false;

        /* -------- PLACEHOLDER -------- */
        var placeholder = new Gtk.Label (_("Ready to translate"));
        //placeholder.icon = new ThemedIcon ("insert-text-symbolic");
        placeholder.add_css_class (Granite.STYLE_CLASS_H2_LABEL);

        placeholder_view = new Gtk.WindowHandle () {
            child = placeholder
        };
        stack.add_child (placeholder_view);
        stack.visible_child = placeholder_view;

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
        var copy = new Gtk.Button.from_icon_name ("edit-copy") {
            tooltip_text = _("Copy to clipboard")
        };
        actionbar.pack_end (copy);

        var save_as_button = new Gtk.Button.from_icon_name ("document-save-as") {
            tooltip_markup = Granite.markup_accel_tooltip (
                    {"<Control><Shift>s"}, 
                    _("Save the translation in a text file")
            )
        };

        actionbar.pack_end (save_as_button);

        /***************** CONNECTS *****************/

        language = Application.settings.get_string ("target-language");
        Application.settings.bind (
          "target-language", 
          this, 
          "language", 
          GLib.SettingsBindFlags.DEFAULT
        );

        copy.clicked.connect (copy_to_clipboard);
        save_as_button.clicked.connect (on_save_as);
        language_changed.connect (on_language_changed);
        textview.buffer.changed.connect (on_buffer_changed);
    }

  private void on_language_changed (string code) {
      Application.settings.set_string ("target-language", code);
      clear ();
  }

  private void copy_to_clipboard () {
        var clipboard = Gdk.Display.get_default ().get_clipboard ();
        clipboard.set_text (textview.buffer.text);
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

  public void on_save_as () {

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

    save_dialog.save.begin ((MrWorldwide.MainWindow)get_root (), null, (obj, res) => {
        try {
            var file = save_dialog.save.end (res);
                var content = this.text;
                FileUtils.set_contents (file.get_path (), content);

        } catch (Error err) {
            warning ("Failed to save file: %s", err.message);
        }
    });
    }


    private void on_buffer_changed () {
        if (text.chomp () == "") {
            return;
        }

        stack.visible_child = main_view;
        textview.buffer.changed.disconnect (on_buffer_changed);
    }
}