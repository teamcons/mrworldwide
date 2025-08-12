/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldWide.ApiLevel : Gtk.Box {

    private Gtk.LevelBar api_usage;

    private Gtk.Spinner loading;
    private Gtk.Stack refresher;

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        spacing = 9;
        margin_bottom = 6;

        /***************** LABEL AND BUTTON *****************/
        var cb = new Gtk.CenterBox ();

        var api_usage_label = new Gtk.Label (_("API Usage")) {
        halign = Gtk.Align.START,
        margin_top = 3
        };
        cb.start_widget = api_usage_label;

        refresher = new Gtk.Stack ();

        loading = new Gtk.Spinner ();
        refresher.add_named (loading, "loading");

        var hint = new Gtk.Button.from_icon_name ("view-refresh") {
            tooltip_text = _("Update API usage")
        };
        refresher.add_named (hint, "hint");
        refresher.visible_child_name = "hint";

        cb.end_widget = refresher;

        append (cb);

        /***************** LEVEL BAR *****************/
        api_usage = new Gtk.LevelBar ();
        api_usage.min_value = 0;
        append (api_usage);

        Application.settings.bind ("current-usage", api_usage, "value", SettingsBindFlags.DEFAULT);
        Application.settings.bind ("max-usage", api_usage, "max-value", SettingsBindFlags.DEFAULT);

        hint.clicked.connect (on_refresh);
        Application.backend.answer_received.connect (updated_usage);
        Application.backend.usage_retrieved.connect (updated_usage);
        updated_usage ();
    }

    private void updated_usage () {
        api_usage.value = Application.backend.current_usage;
        api_usage.max_value = Application.backend.max_usage;

        this.tooltip_text = _("%s characters translated / %s maximum characters on your plan").printf (
            api_usage.value.to_string (),
            api_usage.max_value.to_string ());

        if (refresher.visible_child_name == "loading") {
            refresher.visible_child_name = "hint";
            loading.spinning = false;
        }
    }

    private void on_refresh () {
        loading.spinning = true;
        refresher.visible_child_name = "loading";
        Application.backend.check_usage ();
    }
}
