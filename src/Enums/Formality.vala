/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

public enum MrWorldWide.Formality {
    MORE,
    PREFER_MORE,
    DEFAULT,
    PREFER_LESS,
    LESS;

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
}