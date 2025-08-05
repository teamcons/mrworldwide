/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldWide.WelcomeView : Gtk.Box {

    private Granite.Placeholder title;
    private MrWorldWide.ApiEntry api_entry;
    // Then a link?

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        halign = Gtk.Align.FILL;
        valign = Gtk.Align.FILL;

        hexpand = true;
        vexpand = true;

        title = new Granite.Placeholder (_("Hello World!")) {
            description = _("To start translating, enter your DeepL API Key below"),
        };
        append (title);

        api_entry = new MrWorldWide.ApiEntry ();
        append (api_entry);

        var link = "https://www.deepl.com/your-account/keys";
        var linkname = _("You can get an API Key here");
        var hint = new Gtk.LinkButton.with_label (link, linkname);
        append (hint);
    }
}