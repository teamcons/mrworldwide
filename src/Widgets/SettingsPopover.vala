/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

public class MrWorldWide.SettingsPopover : Gtk.Popover {

  private MrWorldWide.ApiEntry api_entry;
  private Gtk.LevelBar api_usage;

  construct {
    width_request = 340;
    //halign = Gtk.Align.END;

    var box = new Gtk.Box (VERTICAL, 12) {
      margin_top = margin_bottom = 12
    };

    box.append (new OrientationBox ());
    box.append (new Gtk.Separator (HORIZONTAL));

    api_entry = new MrWorldWide.ApiEntry () {
      margin_start = 12,
      margin_end = 12
    };

    box.append (api_entry);

    var api_usage_label = new Gtk.Label (_("API Usage")) {
      halign = Gtk.Align.START,
      margin_start = 12
    };
    box.append (api_usage_label);

    api_usage = new Gtk.LevelBar () {
        margin_start = 12,
        margin_end = 12
    };
    api_usage.min_value = 0;
    box.append (api_usage);

    //var usage_box = new Gtk.Box (VERTICAL, 6);
    //usage_box.append (api_usage_label);
    //usage_box.append (api_usage);

    //  var usage_revealer = new Gtk.Revealer () {
    //    transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN,
    //    transition_duration = 500,
    //    child = usage_box
    //  };
    //  usage_revealer.reveal_child = true;
    //  box.append (usage_revealer);

    var link = "https://www.deepl.com/your-account/keys";
    var linkname = _("DeepL API Keys");

    var hint = new Gtk.LinkButton.with_label (
                                              link,
                                              linkname);

    box.append (hint);

    child = box;

    Application.backend.usage_retrieved.connect (update_usage);
    Application.backend.answer_received.connect (update_usage);



    //  if (api_entry.text != "") {
    //    api_usage.value = Application.settings.get_int ("current-usage");
    //    api_usage.max_value = Application.settings.get_int ("max-usage");
    //  }

  }

  private void update_usage () {
    api_usage.value = Application.backend.current_word_usage;
    api_usage.max_value = Application.backend.max_word_usage;

    api_usage.tooltip_text = _("%s characters translated / %s maximum characters on your plan").printf (
      api_usage.value.to_string (), 
      api_usage.max_value.to_string ());
  }


}
