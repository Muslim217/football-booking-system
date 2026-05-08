package com.fieldbook.shared.repository

import com.fieldbook.shared.api.UserApi
import com.fieldbook.shared.model.*
import com.fieldbook.shared.util.Result

class UserRepository(private val userApi: UserApi) {

    suspend fun getMyProfile(): Result<UserProfile> =
        runCatching { Result.Success(userApi.getMyProfile()) }
            .getOrElse { Result.Error(it.message ?: "Ошибка загрузки профиля") }

    suspend fun updateMyProfile(fullName: String?, phone: String?): Result<UserProfile> =
        runCatching {
            Result.Success(userApi.updateMyProfile(UpdateProfileRequest(fullName, phone)))
        }.getOrElse { Result.Error(it.message ?: "Ошибка обновления профиля") }
}
