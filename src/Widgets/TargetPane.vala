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

        var handle = new Gtk.WindowHandle () {
            child = pane,
            vexpand = true,
            valign = Gtk.Align.FILL
        };

        append (handle);

        pane.textview.editable = false;

        var copy = new Gtk.Button.from_icon_name ("edit-copy") {
            tooltip_text = _("Copy to clipboard")
        };

        copy.clicked.connect (copy_to_clipboard);


        pane.actionbar.pack_end (copy);
    }

  private void copy_to_clipboard () {
             var clipboard = Gdk.Display.get_default ().get_clipboard ();
            clipboard.set_text (pane.textview.buffer.text);
  }
}