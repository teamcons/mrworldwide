
/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 // Thank you stronnag!
public class MrWorldWide.DDModel : Object {
	public GLib.ListStore model {get; set;}
	public Gtk.SignalListItemFactory factory {get; set;}

	public DDModel() {
		model = new GLib.ListStore(typeof(Lang));
		factory = new Gtk.SignalListItemFactory();
		factory.setup.connect ((f,o) => {
				Gtk.ListItem list_item =  (Gtk.ListItem)o;
				var label=new Gtk.Label("");
				list_item.set_child(label);
			});
		factory.bind.connect ((f,o) => {
				Gtk.ListItem list_item =  (Gtk.ListItem)o;
				var language = list_item.get_item () as Lang;
				var label = list_item.get_child() as Gtk.Label;
				label.set_text(language.name);
			});
	}

	public void model_append(Lang l) {
		model.append (l);
	}

	public void model_remove(Lang l) {
		uint pos;
		if(model.find_with_equal_func(l, (a,b) => {
					return ((Lang)a).code == ((Lang)b).code;
				}, out pos)) {
			model.remove(pos);
		}
	}

	public uint model_where_code (string code) {
		uint pos;
		var l = new Lang (code,"");
		if(model.find_with_equal_func(l, (a,b) => {
					return ((Lang)a).code == ((Lang)b).code;
				}, out pos)) {
			return (pos);
		}
		return pos;
	}
}

