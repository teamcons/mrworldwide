
/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

public class MrWorldWide.Lang : Object {

    public string code {get; private set;}
    public string name {get; private set;}

        public Lang (string code, string name) {        
            this.code = code;
            this.name = name;
        }


        public string get_name () {
            return name;
        }
}


