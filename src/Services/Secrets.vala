/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

/*
The plan: Something that replaces pretty much in-place gsettings

a function to set and forget
a function to trigger retrieval. The relevant part of the API will be connected to the signal spitting the key out.

Store the key when the PassWordEntry in Menu is changed
Retrieve upon Menu creation.
Let the backend access it in a cache called "attributes" so there is no async BS.

Store in a table, under "deepl", as in the future we may want to save keys in other backends

*/

public class MrWorldWide.Secrets : Object {

    public signal void retrieved (string result);

    private Secret.Schema secret;
    private GLib.HashTable<string,string> attributes;

    public Secrets () {
        secret = new Secret.Schema (Application.application_id,
                                        Secret.SchemaFlags.NONE,
                                        "api_key",
                                        Secret.SchemaAttributeType.STRING);


        attributes = new GLib.HashTable<string,string> ();                                        
    }

    public void set_api_key (string api_key) {
        attributes["deepl"] = api_key;
        Secret.password_storev.begin (Application.application_id,
                                    attributes,
                                    Secret.COLLECTION_DEFAULT,
                                    "api_key", api_key, null, (obj, async_res) => {
            
                                    bool res = Secret.password_store.end (async_res);
        });
    }

    public void retrieve_api_key () {
        Secret.password_lookup.begin (Application.application_id, attributes, null, (obj, async_res) => {
            string password = Secret.password_lookup.end (async_res);
            // What password exactly is this?...
            retrieved (password);
        });
    }

    public string whats_key (string backend_name) {
        return attributes[backend_name];
    }

}
