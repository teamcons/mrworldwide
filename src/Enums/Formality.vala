/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

/**
 * For the formality options as in OptionsPopover.
 * We use its Int aspect for saving/restoring in gsettings.
 * We convert it to string for the DeepL API request.
 */
public enum MrWorldwide.Formality {
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

    public static Formality from_int (int number) {
      switch (number) {
        case 0: return MORE;
        case 1: return PREFER_MORE;
        case 2: return DEFAULT;
        case 3: return PREFER_LESS;
        case 4: return LESS;
        default: return DEFAULT;
      }
    }
}