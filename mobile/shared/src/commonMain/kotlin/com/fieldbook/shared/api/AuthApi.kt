package com.fieldbook.shared.api

import com.fieldbook.shared.model.*
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.request.*

class AuthApi(private val client: HttpClient) {

    suspend fun login(request: LoginRequest): AuthResponse =
        client.post("/api/auth/login") { setBody(request) }.body()

    suspend fun register(request: RegisterRequest): MessageResponse =
        client.post("/api/auth/register") { setBody(request) }.body()

    suspend fun refresh(request: RefreshTokenRequest): AuthResponse =
        client.post("/api/auth/refresh") { setBody(request) }.body()

    suspend fun logout(request: RefreshTokenRequest): MessageResponse =
        client.post("/api/auth/logout") { setBody(request) }.body()
}

@kotlinx.serialization.Serializable
data class MessageResponse(val message: String)
