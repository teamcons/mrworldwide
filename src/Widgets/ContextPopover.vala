/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

public class MrWorldWide.ContextPopover : Gtk.Popover {


  construct {
    width_request = 260;
    //halign = Gtk.Align.START;

    var box = new Gtk.Box (VERTICAL,0) {
      margin_top = 12,
      margin_bottom = 12,
      margin_start = 12,
      margin_end = 12
    };

    /***************** FORMALITY *****************/
    var formalbox = new Gtk.Box (VERTICAL, 0) {
      margin_top = 6,
      margin_bottom = 12
    };

    var formal_label = new Gtk.Label (_("Set how formal the translation should be")) {
      halign = Gtk.Align.START
    };
    formal_label.add_css_class (Granite.STYLE_CLASS_H4_LABEL);
    //formalbox.append (formal_label);

    var center = new Gtk.CenterBox () {
      valign = Gtk.Align.END
    };
    center.start_widget = new Gtk.Label (_("Formal"));
    center.center_widget = new Gtk.Label (_("Default"));
    center.end_widget = new Gtk.Label (_("Informal"));
    //formalbox.append (formal_level);
    formalbox.append (center);


    var formal_level = new Gtk.Scale.with_range (HORIZONTAL, 0, 4, 1) {
      hexpand = true,
      halign = Gtk.Align.FILL,
      has_origin = false
    };

    formal_level.add_mark (0, Gtk.PositionType.TOP, (null));
    formal_level.add_mark (1, Gtk.PositionType.TOP, (null));
    formal_level.add_mark (2, Gtk.PositionType.TOP, (null));
    formal_level.add_mark (3, Gtk.PositionType.TOP, (null));
    formal_level.add_mark (4, Gtk.PositionType.TOP, (null));
    formal_level.set_round_digits (0);
    formal_level.adjustment.set_step_increment (1);
    formal_level.set_show_fill_level (false);

    formal_level.set_value (Application.settings.get_enum ("formality"));
    formal_level.add_css_class (Granite.STYLE_CLASS_WARMTH);

    formalbox.append (formal_level);

    box.append (formalbox);

    /***************** CONTEXT *****************/
    var context_entry = new Gtk.Entry ();
    context_entry.placeholder_text = _("Enter context here");
    box.append (context_entry);

    child = box;

    Application.settings.bind (
      "context", 
      context_entry, 
      "text", 
      SettingsBindFlags.DEFAULT
    );

    formal_level.change_value.connect (() => {
      var value_as_int = (int)formal_level.get_value ();
      Application.settings.set_enum ("formality", value_as_int);
    });

    this.show.connect (() => {

      var target = Application.settings.get_string ("target-language");

      if (target == "system") {
        target = Application.backend.system_language;
      }

      // I know this could be a cool one liner, but the one liner is ugly and unreadable
      if (target in DeepL.SUPPORTED_FORMALITY) {
        formalbox.sensitive = true;
        formalbox.tooltip_text = _("Set how formal the translation should be");

      } else {
        formalbox.sensitive = false;
        formalbox.tooltip_text = _("Formality control is not available for this target language");
      }

    });
  }
}
