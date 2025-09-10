/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */
 public class MrWorldWide.TargetPane : MrWorldWide.Pane {

    construct {
        load_model (MrWorldWide.TargetLang ());
        dropdown.tooltip_text = _("Set the language to translate to");

        textview.editable = false;

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
        copy.clicked.connect (copy_to_clipboard);
        save_as_button.clicked.connect (on_save_as);
        language_changed.connect (on_language_changed);
    }

  private void on_language_changed (string code) {
      Application.settings.set_string ("target-language", code);
      clear ();
  }

  private void copy_to_clipboard () {
        var clipboard = Gdk.Display.get_default ().get_clipboard ();
        clipboard.set_text (textview.buffer.text);
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

    save_dialog.save.begin ((Application).main_window, null, (obj, res) => {
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