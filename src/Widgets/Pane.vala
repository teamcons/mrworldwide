public class MrWorldWide.Pane : Gtk.Box {

public Gtk.TextView textview;
public Gtk.DropDown dropdown;
public Gtk.StringList langs

public Pane (Lang[] langs) {
langs: langs
}

construct {

orientation = Gtk.Orientation.Vertical;
spacing = 6;

dropdown = new Gtk.DropDown (langs) {
hexpand = true,
vexpand = false,
valign = Gtk.Align.START,
halign = Gtk.Align.FILL
};
dropdown.selected = Application.settings.get_enum (lang_source).to_string ();
append (dropdown);

textview = new Gtk.TextView () {
hexpand = true,
vexpand = true,
valign = Gtk.Align.START,
halign = Gtk.Align.FILL
};
append (textview);
}
}
