/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

/**
 * The backend, responsible for requests and answers.
 * This needs to be standardized into a template, and broken up in several files.
 */
public class Inscriptions.DeepL : Object {

  private const uint TIMEOUT = 3000;

  private Soup.Session session;
  internal Soup.Logger logger;
  private Secrets secrets;

  private string source_lang;
  private string target_lang;
  private string api_key;
  private string base_url;
  public string system_language;
  private string context;

  public signal void answer_received (uint status, string? translated_text = null);
  public signal void language_detected (string? detected_language_code = null);
  public signal void usage_retrieved (uint status);

  private const string URL_DEEPL_FREE = "https://api-free.deepl.com";
  private const string URL_DEEPL_PRO = "https://api.deepl.com";
  private const string REST_OF_THE_URL = "/v2/translate";
  private const string URL_USAGE = "/v2/usage";

  public const string[] SUPPORTED_FORMALITY = {"DE", "FR", "IT", "ES", "NL", "PL", "PT-BR", "PT-PT", "JA", "RU"};

  public int current_usage = 0;
  public int max_usage = 0;

  // Private debounce to not constantly check usage on key change
  private int interval = 1000; // ms
  private uint debounce_timer_id = 0;

  construct {
    session = new Soup.Session () {
      timeout = TIMEOUT
    };

    logger = new Soup.Logger (Soup.LoggerLogLevel.BODY);
    session.add_feature (logger);
    // optional, stderr (vice stdout)
    logger.set_printer ((_1, _2, dir, text) => {
      stderr.printf ("%c %s\n", dir, text);
    });

    secrets = Secrets.get_default ();

    system_language = detect_system ();

    // Fallback
    this.current_usage = Application.settings.get_int ("current-usage");
    this.max_usage = Application.settings.get_int ("max-usage");

    on_source_lang_changed ();
    on_target_lang_changed ();

    secrets.changed.connect (debounce_check);
    Application.settings.changed["source-language"].connect (on_source_lang_changed);
    Application.settings.changed["target-language"].connect (on_target_lang_changed);
  }

  private void debounce_check () {
    debug ("Key changed, starting debounce");
    if (debounce_timer_id != 0) {
        GLib.Source.remove (debounce_timer_id);
    }

    debounce_timer_id = Timeout.add (interval, () => {
        debug ("debounce timer off, reacting to key change");
        debounce_timer_id = 0;
        on_key_changed ();
        check_usage ();
        return GLib.Source.REMOVE;
    });
  }

  public void on_source_lang_changed () {
    source_lang = Application.settings.get_string ("source-language");
    if (source_lang == "system") {
      source_lang = system_language;
    }
  }

  public void on_target_lang_changed () {
    target_lang = Application.settings.get_string ("target-language");
    if (target_lang == "system") {
      target_lang = system_language;
    }
  }

  public void on_key_changed () {
    api_key = secrets.cached_key;

    if (api_key.chomp () == "") {
      answer_received (StatusCode.NO_KEY, _("Missing API Key"));
      return;
    }

    if (api_key.has_suffix (":fx")) {
          base_url = URL_DEEPL_FREE;
    } else {
          base_url = URL_DEEPL_PRO;
    }
  }

  public void send_request (string text) {

    context = Application.settings.get_string ("context");

    var a = prep_json (text);

    on_key_changed ();
    var msg = new Soup.Message ("POST", base_url + REST_OF_THE_URL);
    msg.request_headers.append ("Content-Type", "application/json");
    msg.request_headers.append ("User-Agent", "Inscriptions");
    msg.request_headers.append ("Authorization", "DeepL-Auth-Key %s".printf (api_key));
    msg.set_request_body_from_bytes ("application/json", new Bytes (a.data));

    session.send_and_read_async.begin (msg, 0, null, request_cb);
  }

  private void request_cb (Object? object, AsyncResult res) {
    try {
        var bytes = session.send_and_read_async.end (res);
        var answer = (string)bytes.get_data ();
        var msg = session.get_async_result_message (res);

        string unwrapped_text;
        if (msg.status_code == Soup.Status.OK) {
          unwrapped_text = unwrap_json (answer);

        } else {
          unwrapped_text = unwrap_error_message (answer);
        }

        answer_received (msg.status_code, unwrapped_text);

      } catch (Error e) {
        print (e.domain.to_string ());
        var err_domain = e.domain.to_string ();

        // g-io and g-resolver
        if (err_domain.has_prefix ("g-")) {
          answer_received (Inscriptions.StatusCode.NO_INTERNET, e.message);

        } else {
          stderr.printf ("Got: %s\n", e.message);
          answer_received (2, e.message);
        }
      }
  }

  public string prep_json (string text) {
    var builder = new Json.Builder ();

    builder.begin_object ();
    builder.set_member_name ("text");
    builder.begin_array ();
    builder.add_string_value (text);
    builder.end_array ();

    if (source_lang != "idk") {
      builder.set_member_name ("source_lang");
      builder.add_string_value (source_lang);
    }

    builder.set_member_name ("target_lang");
    builder.add_string_value (target_lang);

    if (context != "") {
      builder.set_member_name ("context");
      builder.add_string_value (context);
    }

    if (target_lang in SUPPORTED_FORMALITY) {
      var formality = Formality.from_int (Application.settings.get_enum ("formality"));
      builder.set_member_name ("formality");
      builder.add_string_value (formality.to_string ());
    }

    builder.set_member_name ("show_billed_characters");
    builder.add_boolean_value (true);

    builder.end_object ();

    Json.Generator generator = new Json.Generator ();
    Json.Node root = builder.get_root ();
    generator.set_root (root);
    string str = generator.to_data (null);
    return str;
  }


  public string unwrap_json (string text_json) {

    var parser = new Json.Parser ();
    try {
          parser.load_from_data (text_json);
    } catch (Error e) {
        print ("\nCannot: " + e.message);
        return text_json;
    }

    var root = parser.get_root ();
    var objects = root.get_object ();
    var array = objects.get_array_member ("translations");
    var translation = array.get_object_element (0);
    var billed_characters = (int)translation.get_int_member_with_default ("billed_characters", 0);
    current_usage = current_usage + billed_characters;
    Application.settings.set_int ("current-usage", current_usage);

    if (source_lang == "idk") {
          var detected_language_code = translation.get_string_member_with_default ("detected_source_language", (_("Cannot detect!")));
          print ("\n Detected language code: " + detected_language_code);
          language_detected (detected_language_code);
    }

    string translated_text = translation.get_string_member_with_default ("text", _("Cannot retrieve translated text!"));
    return translated_text;
  }



  public string unwrap_error_message (string text_json) {

    var parser = new Json.Parser ();
    try {
          parser.load_from_data (text_json);
    } catch (Error e) {
        print ("\nCannot: " + e.message);
        return text_json;
    }

    var root = parser.get_root ();
    var objects = root.get_object ();
    return objects.get_string_member_with_default ("message", _("Cannot retrieve error message text!"));
  }



  public void check_usage () {
    on_key_changed ();
    var msg = new Soup.Message ("GET", base_url + URL_USAGE);
    msg.request_headers.append ("Authorization", "DeepL-Auth-Key %s".printf (api_key));
    session.send_and_read_async.begin (msg, 0, null, usage_cb);
  }

  private void usage_cb (Object? object, AsyncResult res) {
    var session = object as Soup.Session;

    try {
        var bytes = session.send_and_read_async.end (res);
        var answer = (string)bytes.get_data ();

        var parser = new Json.Parser ();
        parser.load_from_data (answer);

        var root = parser.get_root ();
        var objects = root.get_object ();
        this.current_usage = (int)objects.get_int_member ("character_count");
        this.max_usage = (int)objects.get_int_member ("character_limit");

        Application.settings.set_int ("current-usage", current_usage);
        Application.settings.set_int ("max-usage", max_usage);

        var msg = session.get_async_result_message (res);
        usage_retrieved (msg.status_code);

        string? error_message = null;
        
        if (msg.status_code != Soup.Status.OK) {
          error_message = unwrap_error_message (answer);
        }

        answer_received (msg.status_code, error_message);

      } catch (Error e) {
        stderr.printf ("Got: %s\n", e.message);
      }
  }


  // FUCKY: DeepL is a bit weird with some codes
  // We have to hack at it for edge cases
  public string detect_system () {
    string system_language = Environment.get_variable ("LANG").ascii_up ();
    var minicode = system_language.substring (0, 2).ascii_up (-1);

    if (system_language == "C") {
      return "EN-GB";
    }

    if (system_language.has_prefix ("PT_BR")) {
      return "PT-BR";
    }

    if (system_language.has_prefix ("PT_PT")) {
      return "PT-PT";
    }

    if (system_language.has_prefix ("ZH_CN")) {
      return "ZH-HANS";
    }

    if (system_language.has_prefix ("ZH_TW")) {
      return "ZH-HANT";
    }

    if (system_language.has_prefix ("EN_GB")) {
      return "EN-GB";
    }

    if (system_language.has_prefix ("EN_US")) {
      return "EN-US";
    }

    if ((system_language.has_prefix ("ES_")) && (system_language.substring (0, 5) != "ES_ES")) {
      return "ES-419";
    }

    if (minicode == "NO") {
      return "NB";
    }

    print ("\nBackend: Detected system language: " + minicode);
    return minicode;
  }
}
