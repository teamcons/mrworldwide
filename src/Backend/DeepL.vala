/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */


 /*
The object has two signals:
  answer_received (translated_text): This one tells us we have translated text
  language_detected (detected_language_code): this one is to set language detected to detected language

  Handlers on the other side will know what to do with the signals.

  public void reload:
  Set the various object properties

  public void send_request (string text)
  allrounder for the service, takes a text to translate and takes care of the rest

  public string detect_system
  Detects what system language code we do be do having

  public string prep_json (string text)
  does the whole wrapping request into a json we can send

  public string unwrap_json (text_json)
  does the whole unwrapping response from a json we get back
 
 
  If you want to write your own backend, everything would pretty much work if you
   do a drop in replacement with send_request (text) and the two signals to retrieve
   i may open up a bit more the possibilities to do other backends in the future


  public void send_request (text);
  public signal void answer_received (string translated_text);
  public signal void language_detected (string? detected_language_code = null);
  public signal void usage_retrieved (int current_word_usage, int max_word_usage);

  public const string SUPPORTED_FORMALITY
public const SUPPORTED_SOURCE
public const SUPPORTED_TARGET

  */

// Translation service that use translate
public class MrWorldWide.DeepL : Object {

  private string source_lang;
  private string target_lang;
  private string api_key;
  private string base_url;
  public string system_language;
  private string context;

  public signal void answer_received (string translated_text);
  public signal void language_detected (string? detected_language_code = null);
  public signal void usage_retrieved ();

  private const string URL_DEEPL_FREE = "https://api-free.deepl.com";
  private const string URL_DEEPL_PRO = "https://api.deepl.com";
  private const string REST_OF_THE_URL = "/v2/translate";
  private const string URL_USAGE = "/v2/usage";

  public const string[] SUPPORTED_FORMALITY = {"DE", "FR", "IT", "ES", "NL", "PL", "PT-BR", "PT-PT", "JA", "RU"};

  public int current_usage = 0;
  public int max_usage = 0;

  construct {
    system_language = detect_system ();

    // Fallback
    this.current_usage = Application.settings.get_int ("current-usage");
    this.max_usage = Application.settings.get_int ("max-usage");

    // on_key_changed does a request to check usage
    // I dont want that at each app start
    on_key_changed ();

    on_source_lang_changed ();
    on_target_lang_changed ();

    Application.settings.changed["key"].connect (() => {on_key_changed (); check_usage ();});
    Application.settings.changed["source-language"].connect (on_source_lang_changed);
    Application.settings.changed["target-language"].connect (on_target_lang_changed);
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

  public void on_key_changed (bool? do_check = true) {
    api_key = Application.settings.get_string ("key");

    if (api_key != "") {
        if (api_key.has_suffix (":fx")) {
          base_url = URL_DEEPL_FREE;
        } else {
          base_url = URL_DEEPL_PRO;
        }
    }
  }

  public void send_request (string text) {

    context = Application.settings.get_string ("context");

    var a = prep_json (text);
    var session = new Soup.Session ();

    var logger = new Soup.Logger (Soup.LoggerLogLevel.BODY);
    session.add_feature (logger);
    // optional, stderr (vice stdout)
    logger.set_printer ((_1, _2, dir, text) => {
      stderr.printf ("%c %s\n", dir, text);
    });

    var msg = new Soup.Message ("POST", base_url + REST_OF_THE_URL);
    msg.request_headers.append ("Content-Type", "application/json");
    msg.request_headers.append ("User-Agent", "Mr WorldWide");
    msg.request_headers.append ("Authorization", "DeepL-Auth-Key %s".printf (api_key));
    msg.set_request_body_from_bytes ("application/json", new Bytes (a.data));

    session.send_and_read_async.begin (msg, 0, null, (obj, res) => {
      try {
        var bytes = session.send_and_read_async.end (res);
        var answer = (string)bytes.get_data ();
        var unwrapped_text = unwrap_json (answer);
        answer_received (unwrapped_text);

      } catch (Error e) {
        stderr.printf ("Got: %s\n", e.message);
      }
    });
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

    // TODO: This but cleaner
    if (target_lang in SUPPORTED_FORMALITY) {
      string formality;

      switch (Application.settings.get_enum ("formality")) {
        case 0: formality = "more"; break;
        case 1: formality = "prefer_more"; break;
        case 2: formality = "default"; break;
        case 3: formality = "prefer_less"; break;
        case 4: formality = "less"; break;
        default: formality = "default"; break;
      }

      builder.set_member_name ("formality");
      builder.add_string_value (formality);
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
    }

    var root = parser.get_root ();
    var objects = root.get_object ();
    var array = objects.get_array_member ("translations");
    var translation = array.get_object_element (0);

    var billed_characters = (int)translation.get_int_member_with_default (
                                                                          "billed_characters",
                                                                          0);
    current_usage = current_usage + billed_characters;
    Application.settings.set_int ("current-usage", current_usage);

    if (source_lang == "idk") {
          var detected_language_code = translation.get_string_member_with_default (
                                                                                          "detected_source_language",
                                                                                           (_("Cannot detect!")));
          print ("\n Detected language code: " + detected_language_code);
          language_detected (detected_language_code);
    }


    string translated_text = translation.get_string_member_with_default (
                                                                        "text",
                                                                        _("Cannot retrieve translated text!"));
    return translated_text;
  }


  public void check_usage () {

    var msg = new Soup.Message ("GET", base_url + URL_USAGE);
    msg.request_headers.append ("Authorization", "DeepL-Auth-Key %s".printf (api_key));

    var session = new Soup.Session ();

    var logger = new Soup.Logger (Soup.LoggerLogLevel.BODY);
    session.add_feature (logger);
    // optional, stderr (vice stdout)
    logger.set_printer ((_1, _2, dir, text) => {
      stderr.printf ("%c %s\n", dir, text);
    });

    session.send_and_read_async.begin (msg, 0, null, (obj, res) => {
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

        usage_retrieved ();

      } catch (Error e) {
        stderr.printf ("Got: %s\n", e.message);
      }
    });
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
