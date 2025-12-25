/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

/*
The plan: Something that replaces pretty much in-place gsettings
You call the object from anywhere and it manages the rest

a function to set and forget
a function to trigger retrieval. The relevant part of the API will be connected to the signal spitting the key out.

Retrieve key upon Menu creation.
Store the key when the PassWordEntry in Menu is changed
Let the backend access it in a cache so there is no async BS.

*/

public class MrWorldwide.Secrets : Object {

    public signal void changed ();

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
        schema = new Secret.Schema ("io.github.teamcons.mrworldwide", Secret.SchemaFlags.NONE,
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
                                                print ("saved");

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
