package com.fieldbook.shared.storage

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.coroutines.flow.map

class DataStoreTokenStorage(
    private val dataStore: DataStore<Preferences>
) : TokenStorage {

    companion object {
        private val KEY_ACCESS  = stringPreferencesKey("access_token")
        private val KEY_REFRESH = stringPreferencesKey("refresh_token")
    }

    override suspend fun saveTokens(accessToken: String, refreshToken: String) {
        dataStore.edit { prefs ->
            prefs[KEY_ACCESS]  = accessToken
            prefs[KEY_REFRESH] = refreshToken
        }
    }

    override suspend fun getAccessToken(): String? =
        dataStore.data.map { it[KEY_ACCESS] }.firstOrNull()

    override suspend fun getRefreshToken(): String? =
        dataStore.data.map { it[KEY_REFRESH] }.firstOrNull()

    override suspend fun clearTokens() {
        dataStore.edit { it.clear() }
    }
}
