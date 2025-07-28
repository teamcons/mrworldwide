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
        append (pane);

        var paste = new Gtk.Button.from_icon_name ("edit-paste") {
            tooltip_text = _("Paste from clipboard"),
            margin_start = 6
        };
        pane.actionbar.pack_end (paste);


        var options_menu = new MrWorldWide.OptionsMenu ();
        var options_button = new Gtk.MenuButton () {
          icon_name = "tag",
          popover = options_menu,
          tooltip_text = _("Add context to the text to translate"),
        };
        options_button.direction = Gtk.ArrowType.UP;
        pane.actionbar.pack_end (options_button);


        paste.clicked.connect (paste_from_clipboard);
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
