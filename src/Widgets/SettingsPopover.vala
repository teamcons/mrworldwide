/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

public class MrWorldWide.SettingsPopover : Gtk.Popover {

  private MrWorldWide.ApiEntry api_entry;

  construct {
    width_request = 200;
    //halign = Gtk.Align.END;

    var box = new Gtk.Box (VERTICAL, 12) {
      margin_top = 12,
      margin_bottom = 6
    };

    box.append (new OrientationBox ());

    var auto_switch = new Granite.SwitchModelButton (_("Translate automatically")) {
      description = _("The translation will start 2 seconds after typing has stopped"),
      hexpand = true
    };

    box.append (new Gtk.Separator (HORIZONTAL));

    api_entry = new MrWorldWide.ApiEntry () {
      margin_start = 12,
      margin_end = 12
    };

    box.append (api_entry);

    var api_level = new MrWorldWide.ApiLevel () {
      margin_start = 12,
      margin_end = 12
    };

    box.append (api_level);

/*           var usage_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN,
            transition_duration = 500,
            child = usage_box
          };
          usage_revealer.reveal_child = true; */


    box.append (new Gtk.Separator (HORIZONTAL));
    box.append (auto_switch);

    child = box;

    //  if (api_entry.text != "") {
    //    api_usage.value = Application.settings.get_int ("current-usage");
    //    api_usage.max_value = Application.settings.get_int ("max-usage");
    //  }

    Application.settings.bind (
      "auto-translate", 
      auto_switch, 
      "active", 
      SettingsBindFlags.DEFAULT
    );
  }
}
