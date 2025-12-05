/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldwide.RetryButton : Gtk.Box {

  private Gtk.Image result_icon;
  private Gtk.Revealer result_revealer;
  private Gtk.Spinner spin_retry;
  private Gtk.Revealer spin_revealer;
  private Gtk.Button retry_button;

  public signal void validated ();

public RetryButton () {
    Object (
        orientation: Gtk.Orientation.HORIZONTAL,
        spacing: 3
    );
}

construct {
    spin_retry = new Gtk.Spinner ();
    spin_revealer = new Gtk.Revealer () {child = spin_retry, reveal_child = false};
    result_revealer = new Gtk.Revealer () {reveal_child = false};

    append (spin_revealer);
    append (result_revealer);

    retry_button = new Gtk.Button.with_label (_("Retry"));
    retry_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);
    append (retry_button);

    Application.backend.usage_retrieved.connect (retry_answer);
    retry_button.clicked.connect (retry_auth);
  }

  private void retry_auth () {
    retry_button.sensitive = false;
    spin_retry.spinning = true;
    spin_revealer.reveal_child = true;

    Application.backend.check_usage ();
  }

  private void retry_answer (uint status_code) {

    retry_button.sensitive = true;
    switch (status_code) {
        case Soup.Status.OK:
            spin_retry.spinning = false;
            spin_revealer.reveal_child = false;

            result_icon = new Gtk.Image.from_icon_name ("process-completed-symbolic") {
              tooltip_text = _("Success connecting to DeepL")
            };
            result_icon.add_css_class (Granite.STYLE_CLASS_SUCCESS);

            result_revealer.child = result_icon;
            result_revealer.reveal_child = true;

            Application.backend.usage_retrieved.disconnect (retry_answer);
            retry_button.clicked.disconnect (retry_auth);
            validated ();
            break;

        case Soup.Status.FORBIDDEN:
            spin_retry.spinning = false;
            spin_revealer.reveal_child = false;

            result_icon = new Gtk.Image.from_icon_name ("dialog-error-symbolic") {
              tooltip_text = _("API key not valid!")
            };
            result_icon.add_css_class (Granite.STYLE_CLASS_ERROR);
            result_revealer.child = result_icon;
            result_revealer.reveal_child = true;
            break;

        default:
            spin_retry.spinning = false;
            spin_revealer.reveal_child = false;

            result_icon = new Gtk.Image.from_icon_name ("dialog-warning-symbolic") {
              tooltip_text = _("Status code %s").printf (status_code.to_string ())
            };
            result_icon.add_css_class (Granite.STYLE_CLASS_WARNING);
            result_revealer.child = result_icon;
            result_revealer.reveal_child = true;
            break;
    }
  }

}
