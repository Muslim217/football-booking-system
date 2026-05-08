package com.fieldbook.shared.storage

import platform.Foundation.NSUserDefaults

/**
 * iOS реализация хранения токенов.
 * Для продакшна замени на Keychain через Security framework.
 */
class NSUserDefaultsTokenStorage : TokenStorage {

    private val defaults = NSUserDefaults.standardUserDefaults

    override suspend fun saveTokens(accessToken: String, refreshToken: String) {
        defaults.setObject(accessToken,  forKey = "access_token")
        defaults.setObject(refreshToken, forKey = "refresh_token")
    }

    override suspend fun getAccessToken(): String? =
        defaults.stringForKey("access_token")

    override suspend fun getRefreshToken(): String? =
        defaults.stringForKey("refresh_token")

    override suspend fun clearTokens() {
        defaults.removeObjectForKey("access_token")
        defaults.removeObjectForKey("refresh_token")
    }
}
