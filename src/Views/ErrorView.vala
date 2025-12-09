/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldwide.ErrorView : Granite.Bin {

    private const string LINK = "https://www.deepl.com/your-account/keys";
    private const uint WAIT_BEFORE_MAIN = 1500; //In milliseconds

    public uint status { get; construct; }
    public string message { get; construct; }
    private string icon_name = "dialog-error";

    private string explanation_title;
    private string explanation_text;

    public signal void return_to_main (bool? retry = true);

    //TRANSLATORS: This text shows up when the app fails to show technical details on an error
    public ErrorView (uint status, string? message = _("No details available")) {
        Object (
            status: status,
            message: message
        );
    }

    construct {
        var box = new Gtk.Box (VERTICAL, 12) {
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.CENTER,
            margin_start = 24,
            margin_end = 24,
            margin_bottom = 24,
        };

        status_to_message (status);

        var title = new Granite.Placeholder (explanation_title) {
            description = explanation_text,
            icon = new ThemedIcon (icon_name),
            valign = Gtk.Align.CENTER,
        };
        box.append (title);

        // In the event the API is the issue, ask user
        if (status == Soup.Status.FORBIDDEN || status == StatusCode.NO_KEY) {
            var apibox = new Gtk.Box (VERTICAL, 12) {
                margin_top = 6,
                margin_bottom = 6
            };
            var api_entry = new MrWorldwide.ApiEntry ();

            //TRANSLATORS: This is the text of a link to DeepL website, specifically account settings
            var link = new Gtk.LinkButton.with_label (LINK, _("You can get an API key here")) {
                halign = Gtk.Align.START
            };

            apibox.append (api_entry);
            apibox.append (link);
            box.append (apibox);
        };

        var retry_button = new MrWorldwide.RetryButton () {
            halign = Gtk.Align.END
        };
        retry_button.validated.connect (on_validated);

        box.append (retry_button);


        var details_text = message + "\n\n";
        var details_view = new Gtk.Label (details_text) {
            selectable = true,
            wrap = true,
            xalign = 0,
            yalign = 0
        };
        details_view.add_css_class (Granite.STYLE_CLASS_TERMINAL);

        var scroll_box = new Gtk.ScrolledWindow () {
            child = details_view,
            margin_top = 12,
            min_content_height = 90
        };

        var expander = new Gtk.Expander (_("Details")) {
            child = scroll_box,
            hexpand = true,
            margin_top = 12
        };

        if (status != StatusCode.NO_KEY) {
            box.append (expander);
        }


        var handle = new Gtk.WindowHandle () {
            child = box
        };

        child = handle;

    }

    private void status_to_message (uint status) {
        switch (status) {
            //Custom status codes feel super evil
            //TRANSLATORS: The following texts show up respectively, as a title, and error message, when translating has gone wrong. This needs to be as little technical as possible
            case StatusCode.NO_KEY:
                explanation_title = _("Hello, World!");
                explanation_text = _("You need a DeepL API key to translate text\n\nAn API Key is like a password given by DeepL in account settings, to allow you to use it from apps\nIt can be either DeepL Free or Pro");
                icon_name = "dialog-password";
                return;

            case StatusCode.NO_INTERNET:
                explanation_title = _("No Internet");
                icon_name = "network-offline-symbolic";

                if (Environment.get_variable ("XDG_CURRENT_DESKTOP") == "Pantheon") {
                    ///TRANSLATORS: This is twice the same text, but the first one has links for elementary OS
                    explanation_text = _("Please verify you are <a href='%s'>connected to the internet</a>, and that this app has <a href='%s'>permission to access it</a>").printf (Granite.SettingsUri.NETWORK, Granite.SettingsUri.PERMISSIONS);
                } else {
                    explanation_text = _("Please verify you are connected to the internet, and that this app has permission to access it");
                }

                return;

            case Soup.Status.OK:
                explanation_title = _("Everything works great :)");
                explanation_text = _("If you see this and are not me, then it means i forgor to disable this error");
                icon_name = "process-completed";
                return;

            case Soup.Status.BAD_REQUEST:
                explanation_title = _("Bad request");
                explanation_text = _("The app sent a wrong translation request to DeepL...\nPlease report this to the app's developer with as much details as you can");
                icon_name = "dialog-warning";
                return;

            case Soup.Status.FORBIDDEN:
                explanation_title = _("Forbidden");
                explanation_text = _("Your API key is invalid. Make sure it is the correct one!");
                icon_name = "dialog-error";
                return;

            case 429:
                explanation_title = _("Too many requests");
                explanation_text = _("Please wait before retrying. This error should not be possible to happen for this app...");
                icon_name = "dialog-warning";
                return;

            case StatusCode.QUOTA:
                explanation_title = _("Your monthly quota has been exceeded");
                explanation_text = _("If you are a Pro API user, this corresponds to your Cost Control limit");
                icon_name = "dialog-warning";
                return;

            case Soup.Status.INTERNAL_SERVER_ERROR:
                explanation_title = _("Internal server error");
                explanation_text = _("Retry in a minute? If you see this several times, check online if there is a DeepL service interruption");
                icon_name = "dialog-information";
                return;

            case 525:
                explanation_title = _("SSL Handshake error");
                explanation_text = _("This is an issue DeepL is aware of and this app can do nothing about...\nIf you have the know-show, going through a simple authenticated proxy may work");
                icon_name = "network-error";
                return;

            case Soup.Status.REQUEST_TIMEOUT:
                explanation_title = _("Request timeout");
                explanation_text = _("No answer has been received. Either DeepL or your connection are having issues");
                icon_name = "network-error";
                return;

            case Soup.Status.GATEWAY_TIMEOUT:
                explanation_title = _("Gateway timeout");
                explanation_text = _("No answer has been received. Either DeepL or your connection are having issues");
                icon_name = "network-error";
                return;

            default:
                explanation_title = _("Unknown error");
                explanation_text = _("Status code %s, please report this to this app's developer").printf(status.to_string ());
                icon_name = "dialog-question";
                return;
        }
    }

    private void on_validated () {
        Timeout.add_once (WAIT_BEFORE_MAIN, () => {
            return_to_main ();
        });
    }
}