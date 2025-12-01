/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldwide.ErrorView : Gtk.Box {

    public int status { get; construct; }
    public string message { get; construct; }

    private string explanation_title;
    private string explanation_text;

    public ErrorView (int status, string? message = _("No details available")) {
        Object (
            status: status,
            message: message
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
            icon = new ThemedIcon ("dialog-error");
        };
        append (title);

        var button_retry = new Gtk.Button.with_label (_("Retry")) {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        append (button_retry);

        button_retry.clicked.connect (Application.backend.check_usage);


         var switch_reveal_console = new Granite.SwitchModelButton (_("Show Console"));
        append (switch_reveal_console);

        var console = new Gtk.TextView () {
            editable = false
        }
        console.text = message;
        console.add_css_class (Granite.STYLE_CLASS_TERMINAL);

        var scroll_console = new Gtk.ScrolledWindow {
            child = console
        }

        var revealer_console = Gtk.Revealer () {
            child = scroll_console
        };
        append (revealer_console);

        switch_reveal_console.bind_property ("active", revealer_console, "reveal-child", SYNC_CREATE);
    }

    private void status_to_message (int status) {
        switch (status) {
#if DEBUG_FEATURES
            case 200: explanation_title = _("Everything works great :)"); explanation_text = _("\n If you see this and are not me, then it means i forgor to disable this error");
#endif
            case 400: explanation_title = _("Bad request"); explanation_text = _("This is an issue on the app side and should not happen");
            case 429: explanation_title = _("Too many requests"); explanation_text = _("Wait before retrying");
            case 456: explanation_title = _("Your monthly quota has been exceeded"); explanation_text = _("If you are a Pro API user, this corresponds to your Cost Control limit");
            case 500: explanation_title = _("Internal server error"); explanation_text = _("Retry in a minute? If you see this several times, check online if there is a DeepL service interruption");
            case 525: explanation_title = _("SSL Handshake error"); explanation_text = _("This is an issue DeepL is aware of. If you have the know-show, going through a simple authenticated proxy may work");
            case 408: explanation_title = _("Request timeout"); explanation_text = _("No answer has been received. Either DeepL or your connection are having issues");
            case 504: explanation_title = _("Gateway timeout"); explanation_text = _("No answer has been received. Either DeepL or your connection are having issues");
            default: explanation_title = _("Unknown error"); explanation_text = _("code %s").printf(status.to_string ());
        }
    }
}