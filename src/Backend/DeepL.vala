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
 */




// Translation service that use translate
public class MrWorldWide.DeepL : Object {

  private string source_lang;
  private string target_lang;
  private string api_key;
  private string base_url;
  private string system_language;

  public signal void answer_received (string translated_text);
  public signal void language_detected (string? detected_language_code = null);

  private const string URL_DEEPL_FREE = "https://api-free.deepl.com";
  private const string URL_DEEPL_PRO = "https://api.deepl.com";
  private const string REST_OF_THE_URL = "/v2/translate";

  public void reload () {
    system_language = detect_system ();

    source_lang = Application.settings.get_string ("source-language");
    if (source_lang == "system") {
      source_lang = system_language;
    }

    target_lang = Application.settings.get_string ("target-language");
    if (target_lang == "system") {
      target_lang = system_language;
    }

    api_key = Application.settings.get_string ("key");
    if (api_key.has_suffix (":fx")) {
      base_url = URL_DEEPL_FREE;
    } else {
      base_url = URL_DEEPL_PRO;
    }
  }

  public void send_request (string text) {
    reload ();

    var a = prep_json (text);
/*      var a = "{
        'text': ['Hello world!'], 
        'target_lang': 'DE'
    }";  */

    var session = new Soup.Session ();


    var logger = new Soup.Logger(Soup.LoggerLogLevel.BODY);
    session.add_feature (logger);
    // optional, stderr (vice stdout)
    logger.set_printer ((_1, _2, dir, text) => {
      stderr.printf ("%c %s\n", dir, text);
    });

    var msg = new Soup.Message ("POST", base_url + REST_OF_THE_URL);
    msg.request_headers.append ("Content-Type", "application/json");
    //msg.request_headers.append ("Content-Length", a.data.length.to_string ());
    msg.request_headers.append ("User-Agent", "Mr WorldWide");
    msg.request_headers.append ("Authorization", "DeepL-Auth-Key %s".printf (api_key));
    msg.set_request_body_from_bytes ("text/plain", new Bytes (a.data));

    session.send_and_read_async.begin (msg, 0, null, (obj, res) => {
      try {
        var bytes = session.send_and_read_async.end (res);
        var answer = (string)bytes.get_data ();
        answer_received (answer);

        var unwrapped_text = unwrap_json (answer);
        //answer_received (unwrapped_text);
        print (unwrapped_text);

      } catch (Error e) {
        stderr.printf ("Got: %s\n", e.message);
      }
    });
  }

  // FUCKY
  public string detect_system () {
    unowned string system_language = Environment.get_variable ("LANG");
    var minicode = system_language.substring (0, 2).ascii_up (-1);
    print ("\nDetected system language: " + minicode);
    return minicode;
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
    builder.end_object ();

    Json.Generator generator = new Json.Generator ();
    Json.Node root = builder.get_root ();
    generator.set_root (root);
    string str = generator.to_data (null);
    return str;
  }


  public string unwrap_json (string text_json) {
    print ("\n Answer we got: " + text_json);
    var parser = new Json.Parser ();

    try {
          parser.load_from_data (text_json);
    } catch (Error e) {
        print ("\nCannot: " + e.message);
    }

    var root = parser.get_root ();
    var objects = root.get_object ();
    //var items = objects.get_array_member ("translations");

    string translated_text = objects.get_string_member_with_default ("text", _("Cannot retrieve translated text!"));
    print ("\n Translated text:" + translated_text);

    if (source_lang == "idk") {
          string detected_language_code = objects.get_string_member_with_default ("detected_source_language", (_("Cannot detect!")));
          print ("\n Detected language code: " + detected_language_code);
          language_detected (detected_language_code);
    }

    return translated_text;
  }


}

