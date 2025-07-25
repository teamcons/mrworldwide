public class MrWorldWide.Menu : Gtk.Box {

public Gtk.PasswordEntry api_entry;

construct {

orientation = Gtk.Orientation.Vertical;
spacing = 6;
margin_top = margin_bottom = 6;
margin_start = margin_end = 6;

//NOTE: Gtk.PasswordEntry ? No ability to paste, but securener
// TODO: Secondary button is a paste button

var api_field = new Gtk.Box (HORIZONTAL, 0) {
hexpand = true,
halign = Gtk.Align.FILL
};

api_entry = new Gtk.PasswordEntry {
placeholder_text = _("Enter API key here"),
show_peek_icon = true
}

api_paste = new Gtk.Button.from_icon_name ("edit-paste-symbolic") {
tooltip_text = _("Paste Deepl API")
};

api_field.append (api_paste)
api_field.append (api_entry)
append (api_field);

var link = "";
var linkname = _("API Key");

var hint = new Gtk.LinkButton.with_label (
                                                        link,
                                                        linkname
  );

var hint_label = new Granite.HeaderLabel (_("You can get an API key on Deepl Website")) {
            mnemonic_widget = hint,
            halign = Gtk.Align.START,
            hexpand = true,
            valign = Gtk.Align.START,
            margin_top = 0
};

append (hint);
append (hint_label);


}
}