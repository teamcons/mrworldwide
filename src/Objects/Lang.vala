
/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

public class MrWorldwide.Lang : Object {

    public string code {get; construct;}
    public string name {get; construct;}
    public string both {get; construct;}

    public Lang (string code, string name) {        
        Object( code: code,
                name: name);
    }

    // "Both" serves to evaluate both name and code in a single expression
    construct {
        both = name + "|" + code;
    }

	public bool efunc(Lang a, Lang b) {
		return (a.code == b.code);
	}
}
