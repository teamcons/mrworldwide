/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

public enum MrWorldWide.Formality {
    MORE,
    PREFER_MORE,
    DEFAULT,
    PREFER_LESS,
    LESS

    public string to_string () {
      switch (this) {
        case 0: return "more";
        case 1: return "prefer_more";
        case 2: return "default";
        case 3: return "prefer_less";
        case 4: return "less";
        default: return "default";
      }
    }

    public int to_int () {
      switch (this) {
        case MORE: return 0;
        case PREFER_MORE: return 1;
        case DEFAULT: return 2;
        case PREFER_LESS: return 3;
        case LESS: return 4;
        default: return 2;
      }
    }

    public static int Formality.from_int (int formality) {
      switch (formality) {
        case 0: return MORE;
        case 1: return PREFER_MORE;
        case 2: return DEFAULT;
        case 3: return PREFER_LESS;
        case 4: return LESS;
        default: return DEFAULT;
      }
    }
}