/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldwide.ErrorBonusBox : Gtk.Box {

    public uint status { get; construct; }
    private string icon_name = "dialog-error";

    private string explanation_title;
    private string explanation_text;

    public signal void return_to_main (bool? retry = true);

    //TRANSLATORS: This text shows up when the app fails to show technical details on an error
    public ErrorBonusBox (uint status) {
        Object (
            status: status
        );
    }

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        spacing = 12;
        margin_top = 6;
        margin_bottom = 6;

        // In the event the API is the issue, ask user
        if (status == Soup.Status.FORBIDDEN || status == StatusCode.NO_KEY) {
            
            var api_entry = new MrWorldwide.ApiEntry ();

            //TRANSLATORS: This is the text of a link to DeepL website, specifically account settings
            var link = new Gtk.LinkButton.with_label (LINK, _("You can get an API key here")) {
                halign = Gtk.Align.START
            };

            if (status == StatusCode.NO_KEY) {
                var explanation = new Gtk.Label (_("An API Key is like a password given by DeepL in your account settings.\nIt allows you to access and use services from applications")) {
                    wrap_mode = Pango.WrapMode.WORD_CHAR,
                    halign = Gtk.Align.START
                };
                explanation.add_css_class (Granite.STYLE_CLASS_H4_LABEL);
                append (explanation);
            }

            append (api_entry);
            append (link);
        };
    }
}