/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldwide.ErrorBonusBox : Gtk.Box {

    private const string ISSUES = "https://github.com/teamcons/mrworldwide/issues/";
    private const string LINK = "https://www.deepl.com/your-account/keys";
    public uint status { get; construct; }
    public bool if_report { get; construct; }

    public ErrorBonusBox (uint status, bool if_report) {
        Object (status: status,
                if_report: if_report);
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
                var explanation = new Gtk.Label (_("An API Key is like a password given by DeepL\nIt allows you to access services from applications such as this one\nIt looks like this: fr5617a-4875-4763-9119-564tjdvg89:fx")) {
                    wrap_mode = Pango.WrapMode.WORD_CHAR,
                    halign = Gtk.Align.START
                };
                //explanation.add_css_class (Granite.STYLE_CLASS_H4_LABEL);
                //explanation.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);
                append (explanation);
            }

            append (api_entry);
            append (link);
        };


        if (if_report) {
            var link_to_github = new Gtk.LinkButton.with_label (ISSUES, _("Report issue to the developer")) {
                halign = Gtk.Align.START
            };
            append (link_to_github);
        }
    }
}