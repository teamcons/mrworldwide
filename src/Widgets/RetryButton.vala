/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

 public class MrWorldwide.RetryButton : Gtk.Box {

  private Gtk.Revealer result_revealer;
  private Gtk.Spinner spin_retry;
  private Gtk.Revealer spin_revealer;
  private Gtk.Button retry_button;

  public signal void validated ();

public RetryButton () {
    Object (
        orientation: Gtk.Orientation.HORIZONTAL,
        spacing: 6
    );
}

construct {
    spin_retry = new Gtk.Spinner ();
    spin_revealer = new Gtk.Revealer () {
      child = spin_retry,
      reveal_child = false,
      transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT
    };

    result_revealer = new Gtk.Revealer () {
      reveal_child = false,
      transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT
    };

    append (spin_revealer);
    append (result_revealer);

    retry_button = new Gtk.Button.with_label (_("Verify"));
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

            var result_box = new Gtk.Box (HORIZONTAL, 3) {
              tooltip_text = _("200 OK: Success connecting to server")
            };
            result_box.add_css_class (Granite.STYLE_CLASS_SUCCESS);
            result_box.append (new Gtk.Image.from_icon_name ("process-completed-symbolic"));
            result_box.append (new Gtk.Label (_("Success!")));

            result_revealer.child = result_box;
            result_revealer.reveal_child = true;

            Application.backend.usage_retrieved.disconnect (retry_answer);
            retry_button.clicked.disconnect (retry_auth);
            validated ();
            break;

        case Soup.Status.FORBIDDEN:
            spin_retry.spinning = false;
            spin_revealer.reveal_child = false;

            var result_box = new Gtk.Box (HORIZONTAL, 3) {
              tooltip_text = _("403 Forbidden: Invalid API Key")
            };
            result_box.add_css_class (Granite.STYLE_CLASS_ERROR);
            result_box.append (new Gtk.Image.from_icon_name ("dialog-error-symbolic"));
            result_box.append (new Gtk.Label (_("Invalid")));

            result_revealer.child = result_box;
            result_revealer.reveal_child = true;
            retry_button.sensitive = true;
            break;

        default:
            spin_retry.spinning = false;
            spin_revealer.reveal_child = false;

            var result_box = new Gtk.Box (HORIZONTAL, 3) {
              tooltip_text = _("Status code %s: Unrelated to authentication").printf (status_code.to_string ())
            };
            result_box.add_css_class (Granite.STYLE_CLASS_WARNING);
            result_box.append (new Gtk.Image.from_icon_name ("dialog-warning-symbolic"));
            result_box.append (new Gtk.Label (_("Error")));

            result_revealer.child = result_box;
            result_revealer.reveal_child = true;
            retry_button.sensitive = true;
            break;
    }
  }

}
