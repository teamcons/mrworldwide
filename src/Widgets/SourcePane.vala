/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

/**
 * Specialized subclass of Pane for source text. The stack is not used, but an Options button is added.
 */
public class Inscriptions.SourcePane : Inscriptions.Pane {

    public SourcePane () {
        var model = new Inscriptions.DDModel ();
        foreach (var language in Inscriptions.SourceLang ()) {
            model.model_append (language);
        }
        base (model);
    }

  construct {
      stack.visible_child = main_view;
      dropdown.tooltip_text = _("Set the language to translate from");

      var options_button_label = new Gtk.Label (_("Options"));
      var options_button_box = new Gtk.Box (HORIZONTAL, 0);
      options_button_box.append (new Gtk.Image.from_icon_name ("tag-symbolic"));
      options_button_box.append (options_button_label);

      var options_button = new Gtk.MenuButton () {
          child = options_button_box,
          tooltip_text = _("Change options for the translation"),
          margin_end = 6
      };
      options_button.add_css_class (Granite.STYLE_CLASS_FLAT);
      options_button.add_css_class ("flat_menu_button");
      options_button_label.mnemonic_widget = options_button;
      options_button.popover = new Inscriptions.OptionsPopover () {halign = Gtk.Align.START};
      options_button.direction = Gtk.ArrowType.UP;

      actionbar.pack_start (options_button);


      var clear = new Gtk.Button.from_icon_name ("edit-clear-all-symbolic") {
          action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_CLEAR_TEXT,
          tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>L"}, _("Clear text")),
            margin_start = 3
      };
      actionbar.pack_end (clear);

      var paste = new Gtk.Button.from_icon_name ("edit-paste-symbolic") {
          tooltip_text = _("Paste from clipboard"),
            margin_start = 3
      };
      actionbar.pack_end (paste);

      var open_button = new Gtk.Button.from_icon_name ("document-open-symbolic") {
          action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_LOAD_TEXT,
          tooltip_markup = Granite.markup_accel_tooltip (
                  {"<Control>o"}, 
                  _("Load text from a file")
          )
      };
      actionbar.pack_end (open_button);

      /***************** CONNECTS *****************/

      language = Application.settings.get_string ("source-language");
      Application.settings.bind (
        "source-language", 
        this, 
        "language", 
        GLib.SettingsBindFlags.DEFAULT
      );

      paste.clicked.connect (paste_from_clipboard);
      language_changed.connect (on_language_changed);
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
        textview.buffer.text = pasted_text;
        message (_("Pasted"));

      } catch (Error e) {
        print ("Cannot access clipboard: " + e.message);
      }
    });
  }

  public void action_load_text () {

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

    open_dialog.open.begin (Application.main_window, null, (obj, res) => {
      try {
        var file = open_dialog.open.end (res);
        var content = "";
        FileUtils.get_contents (file.get_path (), out content);

        this.text = content;

      } catch (Error err) {
        warning ("Failed to select file to open: %s", err.message);
      }
    });
  }
}
