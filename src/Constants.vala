/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */


namespace MrWorldWide {


	// https://developers.deepl.com/docs/getting-started/supported-languages
	// TODO: In the far future people might declare their own in a backend file
	public Lang[] SourceLang () {
		return {
			new Lang ("idk",_("Detect automatically")),
			new Lang ("system",_("System language")),
			new Lang ("AR",_("Arabic")),
			new Lang ("BG",_("Bulgarian")),
			new Lang ("CS",_("Czech")),
			new Lang ("DA",_("Danish")),
			new Lang ("DE",_("German")),
			new Lang ("EL",_("Greek")),
			new Lang ("EN",_("English (All)")),
			new Lang ("ES",_("Spanish (All)")),
			new Lang ("ET",_("Estonian")),
			new Lang ("FI",_("Finnish")),
			new Lang ("FR",_("French")),
			new Lang ("HE",_("Hebrew")),
			new Lang ("HU",_("Hungarian")),
			new Lang ("ID",_("Indonesian")),
			new Lang ("IT",_("Italian")),
			new Lang ("JA",_("Japanese")),
			new Lang ("KO",_("Korean")),
			new Lang ("LT",_("Lithuanian")),
			new Lang ("LV",_("Latvian")),
			new Lang ("NB",_("Norwegian Bokmål")),
			new Lang ("NL",_("Dutch")),
			new Lang ("PL",_("Polish")),
			new Lang ("PT",_("Portuguese (All)")),
			new Lang ("RO",_("Romanian")),
			new Lang ("RU",_("Russian")),
			new Lang ("SK",_("Slovak")),
			new Lang ("SL",_("Slovenian")),
			new Lang ("SV",_("Swedish")),
			new Lang ("TH",_("Thai")),
			new Lang ("TR",_("Turkish")),
			new Lang ("UK",_("Ukrainian")),
			new Lang ("VI",_("Vietnamese")),
			new Lang ("ZH",_("Chinese (All)"))
		};
	}

	public Lang[] TargetLang () {
		return {
			new Lang ("system",_("System language")),
			new Lang ("AR",_("Arabic")),
			new Lang ("BG",_("Bulgarian")),
			new Lang ("CS",_("Czech")),
			new Lang ("DA",_("Danish")),
			new Lang ("DE",_("German")),
			new Lang ("EL",_("Greek")),
			new Lang ("EN",_("English (GB)")),
			new Lang ("EN",_("English (US)")),
			new Lang ("ES",_("Spanish (All)")),
			new Lang ("ES-419",_("Spanish (Latin American)")),
			new Lang ("ET",_("Estonian")),
			new Lang ("FI",_("Finnish")),
			new Lang ("FR",_("French")),
			new Lang ("HE",_("Hebrew")),
			new Lang ("HU",_("Hungarian")),
			new Lang ("ID",_("Indonesian")),
			new Lang ("IT",_("Italian")),
			new Lang ("JA",_("Japanese")),
			new Lang ("KO",_("Korean")),
			new Lang ("LT",_("Lithuanian")),
			new Lang ("LV",_("Latvian")),
			new Lang ("NB",_("Norwegian Bokmål")),
			new Lang ("NL",_("Dutch")),
			new Lang ("PL",_("Polish")),
			new Lang ("PT-PT",_("Portuguese (Portugual)")),
			new Lang ("PT-BR",_("Portuguese (Brazilian)")),
			new Lang ("RO",_("Romanian")),
			new Lang ("RU",_("Russian")),
			new Lang ("SK",_("Slovak")),
			new Lang ("SL",_("Slovenian")),
			new Lang ("SV",_("Swedish")),
			new Lang ("TH",_("Thai")),
			new Lang ("TR",_("Turkish")),
			new Lang ("UK",_("Ukrainian")),
			new Lang ("VI",_("Vietnamese")),
			new Lang ("ZH-HANS",_("Chinese (Simplified)")),
			new Lang ("ZH-HANT",_("Chinese (Traditional)"))
		};
	}
}
