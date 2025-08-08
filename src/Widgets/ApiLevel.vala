/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldWide.ApiLevel : Gtk.Box {

    private Gtk.LevelBar api_usage;

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        spacing = 6;

        var api_usage_label = new Gtk.Label (_("API Usage")) {
          halign = Gtk.Align.START,
          margin_start = 12
        };
        append (api_usage_label);

        api_usage = new Gtk.LevelBar ();
        api_usage.min_value = 0;
        append (api_usage);

        Application.settings.bind ("current-usage", api_usage, "value", SettingsBindFlags.DEFAULT);
        Application.settings.bind ("max-usage", api_usage, "max-value", SettingsBindFlags.DEFAULT);

        Application.backend.answer_received.connect (updated_usage);
        Application.backend.usage_retrieved.connect (updated_usage);
        updated_usage ();
    }

    private void updated_usage () {
        api_usage.value = Application.backend.current_word_usage;
        api_usage.max_value = Application.backend.max_word_usage;

        api_usage.tooltip_text = _("%s characters translated / %s maximum characters on your plan").printf (
            api_usage.value.to_string (),
            api_usage.max_value.to_string ());
    }
}
