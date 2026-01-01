/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText:  2025 Stella & Charlie (teamcons.carrd.co)
 */

/**
 * libsoup.Status does not have all error codes, so we extend handling in ErrorView/ErrorBonuxBox with these custom ones.
 * Custom codes we can use safely for at least 0 to 10.
 * Specific return codes to DeepL, we use their Int representation.
 */
public enum MrWorldwide.StatusCode {
    NO_KEY = 0,
    NO_INTERNET = 1,
    QUOTA = 456,
    TOO_MANY_REQUESTS = 429,
    SSL_HANDSHAKE_ERROR = 525;
}