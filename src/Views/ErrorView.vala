/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldwide.ErrorView : Gtk.Box {

    public uint status { get; construct; }
    public string message { get; construct; }
    public string icon_name { get; construct; }

    private string explanation_title;
    private string explanation_text;

    public ErrorView (uint status, string? message = _("No details available"), string? icon_name = "dialog-error") {
        Object (
            status: status,
            message: message,
            icon_name: icon_name
        );
    }

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        halign = Gtk.Align.FILL;
        valign = Gtk.Align.CENTER;
        hexpand = true;
        vexpand = true;

        status_to_message (status);

        var title = new Granite.Placeholder (explanation_title) {
            description = explanation_text,
            icon = new ThemedIcon (icon_name)
        };
        append (title);

        var button_retry = new Gtk.Button.with_label (_("Retry")) {
            halign = Gtk.Align.RIGHT,
            valign = Gtk.Align.CENTER
        };
        append (button_retry);

        button_retry.clicked.connect (Application.backend.check_usage);

        var details_view = new Gtk.Label (message) {
            selectable = true,
            wrap = true,
            xalign = 0,
            yalign = 0
        };

        var scroll_box = new Gtk.ScrolledWindow () {
            child = details_view,
            margin_top = 12,
            min_content_height = 70
        };
        scroll_box.add_css_class (Granite.STYLE_CLASS_TERMINAL);

        var expander = new Gtk.Expander (_("Details")) {
            child = scroll_box,
            hexpand = true
        };
        
        append (expander);
    }

    private void status_to_message (uint status) {
        switch (status) {
            case 200:
                explanation_title = _("Everything works great :)");
                explanation_text = _("\nIf you see this and are not me, then it means i forgor to disable this error");
                icon_name = "process-completed";
                return;

            case 400:
                explanation_title = _("Bad request");
                explanation_text = _("The app sent a wrong translation request to DeepL...\nPlease report this to the app's developer with as much details as you can");
                icon_name = "dialog-warning";
                return;

            case 403:
                explanation_title = _("Forbidden");
                explanation_text = _("Your API key is invalid. Make sure it is the correct one!");
                icon_name = "dialog-password";
                return;

            case 429:
                explanation_title = _("Too many requests");
                explanation_text = _("Please wait before retrying. This error should not be possible to happen for this app...");
                icon_name = "dialog-warning";
                return;

            case 456:
                explanation_title = _("Your monthly quota has been exceeded");
                explanation_text = _("If you are a Pro API user, this corresponds to your Cost Control limit");
                icon_name = "dialog-warning";
                return;

            case 500:
                explanation_title = _("Internal server error");
                explanation_text = _("Retry in a minute? If you see this several times, check online if there is a DeepL service interruption");
                icon_name = "dialog-information";
                return;

            case 525:
                explanation_title = _("SSL Handshake error");
                explanation_text = _("This is an issue DeepL is aware of and this app can do nothing about...\nIf you have the know-show, going through a simple authenticated proxy may work");
                icon_name = "network-error";
                return;

            case 408:
                explanation_title = _("Request timeout");
                explanation_text = _("No answer has been received. Either DeepL or your connection are having issues");
                icon_name = "network-error";
                return;
            
            case 504:
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
}