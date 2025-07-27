/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */


//https://dev.to/sdv43/how-to-use-curl-in-vala-i60

// Translation service that use translate
public class MrWorldWide.DeepL : Object {

  private string from;
  private string to;
  private string api_key;
  private string base_url;

  public signal void answer_received (string translated_text);

  private const string URL_DEEPL_FREE = "https://api-free.deepl.com";
  private const string URL_DEEPL_PRO = "https://api.deepl.com";
  private const string REST_OF_THE_URL = "/v2/translate";

  /*  
    curl -X POST https://api.deepl.com/v2/translate \
      --header "Content-Type: application/json" \
      --header "Authorization: DeepL-Auth-Key $API_KEY" \
      --data '{
        "text": ["Hello world!"], 
        "target_lang": "DE"
    }'  */

  public void reload () {
    from = Application.settings.get_string ("source-language");
    if (from == "system") {
      from = detect_system ();
    }

    to = Application.settings.get_string ("target-language");
    if (to == "system") {
      to = detect_system ();
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
    print (a);
/*      var a = "{
        'text': ['Hello world!'], 
        'target_lang': 'DE'
    }";  */

    var session = new Soup.Session ();
    var msg = new Soup.Message ("POST", base_url + REST_OF_THE_URL);
    msg.request_headers.append ("Content-Type", "application/json");
    msg.request_headers.append ("Content-Length", a.data.length.to_string ());
    msg.request_headers.append ("User-Agent", "Mr WorldWide");
    msg.request_headers.append ("Authorization", "DeepL-Auth-Key %s".printf (api_key));
    msg.set_request_body_from_bytes ("text/plain", new Bytes (a.data));

    session.send_and_read_async.begin (msg, 0, null, (obj,res) => {
      try {
        var bytes = session.send_and_read_async.end (res);
        var answer = (string)bytes.get_data ();
        answer_received (answer);                  

      } catch (Error e) {
        stderr.printf ("Got: %s\n", e.message);
      }
    });
  }

  public string detect_system () {
    return "de";
  }

  public string prep_json (string text) {
    var builder = new Json.Builder ();

    builder.begin_object ();
    builder.set_member_name ("text");
    builder.begin_array ();
    builder.add_string_value (text);
    builder.end_array ();

    if (from != "idk") {
      builder.set_member_name ("source_lang");
      builder.add_string_value (from);
    }

    builder.set_member_name ("target_lang");
    builder.add_string_value (to);
    builder.end_object ();

    Json.Generator generator = new Json.Generator ();
    Json.Node root = builder.get_root ();
    generator.set_root (root);
    string str = generator.to_data (null);
    return str;
  }

}

