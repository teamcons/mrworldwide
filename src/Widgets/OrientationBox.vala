/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

public class MrWorldWide.OrientationBox : Gtk.Box {

    construct {
        homogeneous = true;
        hexpand = true;
        margin_start = 12;
        margin_end = 12;

        var box_vert = new Gtk.Box (HORIZONTAL,0) {
            halign = Gtk.Align.CENTER
        };
        box_vert.append (new Gtk.Image.from_icon_name ("view-dual"));
        box_vert.append (new Gtk.Label (_("Vertical")));

        var toggle_vertical = new Gtk.ToggleButton () {
            child = box_vert,
            tooltip_markup = Granite.markup_accel_tooltip (
                {"<Ctrl>O"},
                _("Switch orientation to vertical")
            )
        };

        var box_horiz = new Gtk.Box (HORIZONTAL,0) {
            halign = Gtk.Align.CENTER
        };
        box_horiz.append (new Gtk.Image.from_icon_name ("view-dual"));
        box_horiz.append (new Gtk.Label (_("Horizontal")));
        box_horiz.add_css_class ("rotated");

        var toggle_horizontal = new Gtk.ToggleButton () {
            child = box_horiz,
            tooltip_markup = Granite.markup_accel_tooltip (
                {"<Ctrl>O"},
                _("Switch orientation to horizontal")
            )
        };
            //toggle_horizontal.add_css_class ("rotated");

        Application.settings.bind (
            "vertical-layout",
            toggle_vertical,
            "active",
            SettingsBindFlags.INVERT_BOOLEAN
        );

                Application.settings.bind (
            "vertical-layout",
            toggle_horizontal,
            "active",
            SettingsBindFlags.DEFAULT
        );

        append (toggle_vertical);
        append (toggle_horizontal);
        add_css_class (Granite.STYLE_CLASS_LINKED);
    }
}
