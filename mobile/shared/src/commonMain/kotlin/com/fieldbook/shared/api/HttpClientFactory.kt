package com.fieldbook.shared.api

import com.fieldbook.shared.storage.TokenStorage
import io.ktor.client.*
import io.ktor.client.plugins.*
import io.ktor.client.plugins.auth.*
import io.ktor.client.plugins.auth.providers.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.plugins.logging.*
import io.ktor.client.request.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.Json

/**
 * Фабрика Ktor клиента.
 * Автоматически прикрепляет Bearer токен к каждому запросу.
 * При 401 — обновляет токен через /auth/refresh.
 */
fun createHttpClient(
    tokenStorage: TokenStorage,
    baseUrl: String
): HttpClient = HttpClient {

    install(ContentNegotiation) {
        json(Json {
            ignoreUnknownKeys = true   // безопасно игнорируем новые поля API
            isLenient          = true
            prettyPrint        = false
        })
    }

    install(Logging) {
        logger = Logger.DEFAULT
        level  = LogLevel.BODY         // в релизе переключи на LogLevel.NONE
    }

    install(DefaultRequest) {
        url(baseUrl)
        contentType(ContentType.Application.Json)
    }

    install(HttpTimeout) {
        requestTimeoutMillis  = 30_000
        connectTimeoutMillis  = 15_000
        socketTimeoutMillis   = 30_000
    }

    install(Auth) {
        bearer {
            // Загружаем сохранённый токен
            loadTokens {
                val access  = tokenStorage.getAccessToken()  ?: return@loadTokens null
                val refresh = tokenStorage.getRefreshToken() ?: return@loadTokens null
                BearerTokens(access, refresh)
            }

            // Вызывается автоматически при 401
            refreshTokens {
                val refreshToken = tokenStorage.getRefreshToken() ?: return@refreshTokens null
                try {
                    val response = client.post("${baseUrl}/api/auth/refresh") {
                        markAsRefreshTokenRequest()
                        setBody(mapOf("refreshToken" to refreshToken))
                        contentType(ContentType.Application.Json)
                    }
                    if (response.status == HttpStatusCode.OK) {
                        val body = response.body<com.fieldbook.shared.model.AuthResponse>()
                        tokenStorage.saveTokens(body.accessToken, body.refreshToken)
                        BearerTokens(body.accessToken, body.refreshToken)
                    } else {
                        tokenStorage.clearTokens()
                        null
                    }
                } catch (e: Exception) {
                    tokenStorage.clearTokens()
                    null
                }
            }
        }
    }
}
