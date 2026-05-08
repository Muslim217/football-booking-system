package com.fieldbook.shared.api

import com.fieldbook.shared.model.*
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.request.*

class UserApi(private val client: HttpClient) {

    suspend fun getMyProfile(): UserProfile =
        client.get("/api/users/me").body()

    suspend fun updateMyProfile(request: UpdateProfileRequest): UserProfile =
        client.put("/api/users/me") { setBody(request) }.body()
}
