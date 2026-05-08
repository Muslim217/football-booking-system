package com.fieldbook.shared.repository

import com.fieldbook.shared.api.FieldApi
import com.fieldbook.shared.model.*
import com.fieldbook.shared.util.Result

class FieldRepository(private val fieldApi: FieldApi) {

    suspend fun getFields(page: Int = 0, size: Int = 10): Result<Page<Field>> =
        runCatching { Result.Success(fieldApi.getFields(page, size)) }
            .getOrElse { Result.Error(it.message ?: "Ошибка загрузки площадок") }

    suspend fun getFieldById(id: Long): Result<Field> =
        runCatching { Result.Success(fieldApi.getFieldById(id)) }
            .getOrElse { Result.Error(it.message ?: "Площадка не найдена") }

    suspend fun getSchedule(fieldId: Long, date: String): Result<List<TimeSlot>> =
        runCatching { Result.Success(fieldApi.getSchedule(fieldId, date)) }
            .getOrElse { Result.Error(it.message ?: "Ошибка загрузки расписания") }

    suspend fun getMyFields(page: Int = 0, size: Int = 10): Result<Page<Field>> =
        runCatching { Result.Success(fieldApi.getMyFields(page, size)) }
            .getOrElse { Result.Error(it.message ?: "Ошибка загрузки ваших площадок") }
}
