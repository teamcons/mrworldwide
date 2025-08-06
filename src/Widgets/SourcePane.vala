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
        pane.dropdown.tooltip_text = _("Set the language to translate from");

        append (pane);


        var clear = new Gtk.Button.from_icon_name ("edit-clear") {
            tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>L"}, _("Clear text")),
            margin_start = 6
        };
        pane.actionbar.pack_end (clear);

        var paste = new Gtk.Button.from_icon_name ("edit-paste") {
            tooltip_text = _("Paste from clipboard"),
            margin_start = 6
        };
        pane.actionbar.pack_end (paste);

        clear.clicked.connect (() => {
          pane.set_text ("");
        });

        paste.clicked.connect (paste_from_clipboard);

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
}
