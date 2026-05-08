package com.fieldbook.shared.storage

/**
 * expect/actual — хранение токенов.
 * Android: DataStore  |  iOS: NSUserDefaults (KeyChain в продакшне)
 */
interface TokenStorage {
    suspend fun saveTokens(accessToken: String, refreshToken: String)
    suspend fun getAccessToken(): String?
    suspend fun getRefreshToken(): String?
    suspend fun clearTokens()
    suspend fun isLoggedIn(): Boolean = getAccessToken() != null
}
