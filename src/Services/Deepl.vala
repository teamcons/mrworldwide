// Translation service that use translate
public class MrWorldWide.Deepl : AsyncTaskExecuter {
  private const string API_KEY;
  private string[] _result;
  private string _from;
  private string _to;
  private string _text;

  private string baseurl;

  /// On result
  public signal void result (string[] text);

  /// Constructor
  public TranslateService () {
    base();

    API_KEY =  = Application.settings.get_string ("key");

    if (API_KEY has :fx) {
      baseurl = https://translate.yandex.net;
    } else {
      baseurl = https://translate.yandex.net;      
    }

  }

  /// Task main working method
  public override void OnExecute() throws TranslatorError {
    var ntext = Soup.URI.encode(_text, null);
    var request = @"https://translate.yandex.net/api/v1.5/tr.json/translate?key=$(API_KEY)&lang=$(_from)-$(_to)&text=$(ntext)";
    var root = WebJsonClient.Get(request);
    var data = new Gee.ArrayList<string>();

    if (root != null) {
        var sentences = root.get_array_member("text");

        if (sentences != null) {
            foreach (var s in sentences.get_elements()) {
                var el = s.get_string();
                data.add(el);
            }
        }
        _result = data.to_array();
    }
  }

  /// On result
  public override void OnResult() {
    result(_result);
  }

  /// Start to translate
  public void Translate(string from, string to, string text) {
    _from = from;
    _to = to;
    _text = text;
    Run ();
  }
}