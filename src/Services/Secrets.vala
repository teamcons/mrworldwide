/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

/**
 * Wrapper to handle loading/Saving the DeepL API Key safely.
 * It is done asynchronously to not have the UI hang and freeze.
 */
public class MrWorldwide.Secrets : Object {

    public signal void changed ();

    // Ensure only once instance, accessible whenever needed.
    private static Secrets? instance;
    public static Secrets get_default () {
        if (instance == null) {
            instance = new Secrets ();
        }
        return instance;
    }

    private string _cached = "";
    public string cached_key {
        get { return _cached;}
        set { store_key (value);}
    }

    Secret.Schema schema;
    GLib.HashTable<string,string> attributes;

    construct {
        schema = new Secret.Schema ("io.github.teamcons.inscriptions", Secret.SchemaFlags.NONE,
                                        "label", Secret.SchemaAttributeType.STRING);

        attributes = new GLib.HashTable<string,string> (str_hash, str_equal);
        attributes["label"] = "DeepL";

        //  try {
        //      _cached = Secret.password_lookupv_sync (schema, attributes, null);
        //      print ("retrieved password!");
        //  } catch (Error e) {
        //      warning (e.message);
        //  }

    }

    public void store_key (string new_key) {
            _cached = new_key;
            changed ();

            Secret.password_storev.begin (schema, attributes, Secret.COLLECTION_DEFAULT,
                                            "DeepL", new_key, null, (obj, async_res) => {

                                            try {
                                                bool res = Secret.password_store.end (async_res);
                                                print ("saved? %b".printf (res));

                                            } catch (Error e) {
                                                print (e.message);
                                            }
            });
    }

    public async string load_secret () {
        var key = "";
        try {
            key = yield Secret.password_lookupv (schema, attributes, null);
        } catch (Error e) {
            print (e.message);

        }
        _cached = key;
        return key;
    }


}
