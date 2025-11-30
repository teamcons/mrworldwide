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

    public signal void retrieved (string result);

    private Secret.Schema secret;
    private GLib.HashTable<string,string> attributes;

    private string cached_password;


    public Secrets () {
        secret = new Secret.Schema ("io.github.teamcons.mrworldwide",
                                        Secret.SchemaFlags.NONE,
                                        "backend",
                                        Secret.SchemaAttributeType.STRING);


        attributes = new GLib.HashTable<string,string> (null, null);
    }

    public void set_api_key (string backend, string api_key) {
        attributes["backend"] = backend;
        Secret.password_storev.begin (secret,
                                    attributes,
                                    Secret.COLLECTION_DEFAULT,
                                    backend, api_key, null, (obj, async_res) => {

                                    try {
                                        bool res = Secret.password_store.end (async_res);
                                        print ("\n Finished saving %s:%s".printf (api_key,res.to_string ()));

                                    } catch (Error e) {
                                        print ("S Secrets: %s".printf (e.message));
                                    }
        });
    }

    public void retrieve_api_key (string backend) {
        attributes["backend"] = backend;
        Secret.password_lookupv.begin (
            secret,
            attributes,
            null, (obj, async_res) => {

            try {
                string password = Secret.password_lookup.end (async_res);
                cached_password = password;
                retrieved (password);
                print ("\nRETRIEVED: %s".printf (password));

            } catch (Error e) {
                print ("S Secrets: %s".printf (e.message));
            }

        });
    }

    public string whats_key (string backend) {
        return cached_password;
    }

}
