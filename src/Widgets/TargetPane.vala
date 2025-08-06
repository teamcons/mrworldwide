/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */
 public class MrWorldWide.TargetPane : Gtk.Box {

    //TODO: I dont know how to chain constructs when an argument is requested
    public MrWorldWide.Pane pane;

    construct {
        orientation = VERTICAL;
        spacing = 0;

        pane = new MrWorldWide.Pane (MrWorldWide.TargetLang ());
        pane.dropdown.tooltip_text = _("Set the language to translate to");
        append (pane);

        pane.textview.editable = false;

        var copy = new Gtk.Button.from_icon_name ("edit-copy") {
            tooltip_text = _("Copy to clipboard")
        };
        pane.actionbar.pack_end (copy);

        copy.clicked.connect (copy_to_clipboard);

        pane.language_changed.connect (on_language_changed);
    }

  private void on_language_changed (string code) {
      Application.settings.set_string ("target-language", code);
      pane.clear ();
  }

  private void copy_to_clipboard () {
        var clipboard = Gdk.Display.get_default ().get_clipboard ();
        clipboard.set_text (pane.textview.buffer.text);
  }
}