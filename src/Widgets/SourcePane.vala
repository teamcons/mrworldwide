/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldWide.SourcePane : Gtk.Box {

    //TODO: I dont know how to chain constructs when an argument is requested
    public MrWorldWide.Pane pane;

    construct {
        orientation = VERTICAL;
        spacing = 0;

        pane = new MrWorldWide.Pane (MrWorldWide.SourceLang ());
        pane.options_button.visible = true;
        pane.dropdown.tooltip_text = _("Set the language to translate from");

        append (pane);

        var clear = new Gtk.Button.from_icon_name ("edit-clear") {
            tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>L"}, _("Clear text"))
        };
        pane.actionbar.pack_end (clear);

        var paste = new Gtk.Button.from_icon_name ("edit-paste") {
            tooltip_text = _("Paste from clipboard")
        };
        pane.actionbar.pack_end (paste);

        var open_button = new Gtk.Button.from_icon_name ("document-open") {
            tooltip_markup = Granite.markup_accel_tooltip (
                    {"<Control>o"},
                    _("Load text from a file")
            )
        };
        pane.actionbar.pack_end (open_button);

        /***************** CONNECTS *****************/
        clear.clicked.connect (pane.clear);
        paste.clicked.connect (paste_from_clipboard);
        open_button.clicked.connect (on_open_file);
        pane.language_changed.connect (on_language_changed);
    }

    private void on_language_changed (string code) {
          Application.settings.set_string ("source-language", code);
  }

  private void paste_from_clipboard () {
    var clipboard = Gdk.Display.get_default ().get_clipboard ();

   //Paste without overwrite:
   //    pane.textview.buffer.paste_clipboard (clipboard, null, true);
    clipboard.read_text_async.begin ((null), (obj, res) => {
      try {

        var pasted_text = clipboard.read_text_async.end (res);
        pane.textview.buffer.text = pasted_text;

      } catch (Error e) {
        print ("Cannot access clipboard: " + e.message);
      }
    });
  }

  public void on_open_file () {

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

    var open_dialog = new Gtk.FileDialog () {
      //TRANSLATORS: The following text is for the dialog to load a text file to translate
      title = _("Open text file to translate"),
        accept_label = _("Open"),
        default_filter = text_files_filter,
        filters = filter_model,
        modal = true
    };

    open_dialog.open.begin ((Application).main_window, null, (obj, res) => {
      try {
        var file = open_dialog.open.end (res);
        var content = "";
        FileUtils.get_contents (file.get_path (), out content);

        this.pane.set_text (content);

      } catch (Error err) {
        warning ("Failed to select file to open: %s", err.message);
      }
    });
  }
}
