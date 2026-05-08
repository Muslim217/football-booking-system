package com.fieldbook.shared.repository

import com.fieldbook.shared.api.AuthApi
import com.fieldbook.shared.api.MessageResponse
import com.fieldbook.shared.model.*
import com.fieldbook.shared.storage.TokenStorage
import com.fieldbook.shared.util.Result

class AuthRepository(
    private val authApi: AuthApi,
    private val tokenStorage: TokenStorage
) {

    suspend fun login(username: String, password: String): Result<AuthResponse> =
        runCatching {
            val response = authApi.login(LoginRequest(username, password))
            tokenStorage.saveTokens(response.accessToken, response.refreshToken)
            Result.Success(response)
        }.getOrElse { Result.Error(it.message ?: "Ошибка входа") }

    suspend fun register(username: String, email: String, password: String): Result<MessageResponse> =
        runCatching {
            Result.Success(authApi.register(RegisterRequest(username, email, password)))
        }.getOrElse { Result.Error(it.message ?: "Ошибка регистрации") }

    suspend fun logout(): Result<Unit> =
        runCatching {
            val refreshToken = tokenStorage.getRefreshToken()
            if (refreshToken != null) {
                authApi.logout(RefreshTokenRequest(refreshToken))
            }
            tokenStorage.clearTokens()
            Result.Success(Unit)
        }.getOrElse {
            tokenStorage.clearTokens()
            Result.Success(Unit)   // даже при ошибке сети — чистим локально
        }

    suspend fun isLoggedIn(): Boolean = tokenStorage.isLoggedIn()
}
