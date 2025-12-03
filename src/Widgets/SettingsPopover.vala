/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

public class MrWorldwide.SettingsPopover : Gtk.Popover {
  
  const string DONATE_LINK = "https://ko-fi.com/teamcons";

  private MrWorldwide.ApiEntry api_entry;
  private Gtk.Revealer usage_revealer;
  private const string LINK = "https://www.deepl.com/your-account/keys";

  construct {
    width_request = 200;
    //halign = Gtk.Align.END;

    var box = new Gtk.Box (VERTICAL, 9) {
      margin_top = 12,
      margin_bottom = 6
    };

    box.append (new OrientationBox ());

    var auto_switch = new Granite.SwitchModelButton (_("Translate automatically")) {
      description = _("The translation will start 1.5 seconds after typing has stopped"),
      hexpand = true,
      margin_top = 3
    };

    //box.append (auto_switch);

    box.append (new Gtk.Separator (HORIZONTAL));

    var cb = new Gtk.CenterBox () {
      margin_end = 12
    };

    var api_label = new Gtk.Label (_("DeepL API Key")) {
      halign = Gtk.Align.START,
      margin_start = 12,
      margin_top = 3
    };
    cb.start_widget = api_label;

    var hint = new Gtk.Button.from_icon_name ("help-contents") {
          tooltip_text = _("You can get an API key here")
    };
    cb.end_widget = hint;

  
    box.append (cb);

    api_entry = new MrWorldwide.ApiEntry () {
      margin_start = 12,
      margin_end = 12
    };

    box.append (api_entry);

    var api_level = new MrWorldwide.ApiLevel () {
      margin_start = 15,
      margin_end = 15,
      margin_top = 3
    };

    usage_revealer = new Gtk.Revealer () {
      transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN,
      transition_duration = 500,
      child = api_level
    };

    box.append (usage_revealer);

    box.append (new Gtk.Separator (HORIZONTAL));

    var support_button = new Gtk.LinkButton.with_label (DONATE_LINK, _("Support us!")) {
      halign = Gtk.Align.START,
      margin_bottom = 6,
      margin_start = 12,
    };
    box.append (support_button);


    child = box;

    hint.clicked.connect (open_webpage);
    api_entry.api_entry.changed.connect (relevant_levelbar);
    relevant_levelbar ();

    Application.settings.bind ("auto-translate", auto_switch, "active", SettingsBindFlags.DEFAULT);
  }

  private void relevant_levelbar () {
    if (api_entry.api_entry.text == "") {
      usage_revealer.reveal_child = false;

    } else {
      usage_revealer.reveal_child = true;
    }
  }

  private void open_webpage () {
    try {
      AppInfo.launch_default_for_uri (LINK, null);
    } catch (Error e) {
      warning ("%s\n", e.message);
    }
  }
}
