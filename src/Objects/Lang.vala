
/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

public class MrWorldWide.Lang : Object {

    public string code {get; private set;}
    public string name {get; private set;}

        public Lang (string _code, string _name) {        
            this.code = _code;
            this.name = _name;
        }


	public bool efunc(Lang a, Lang b) {
		return (a.code == b.code);
	}
}
