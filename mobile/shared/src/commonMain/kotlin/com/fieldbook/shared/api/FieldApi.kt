package com.fieldbook.shared.api

import com.fieldbook.shared.model.*
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.request.*

class FieldApi(private val client: HttpClient) {

    suspend fun getFields(page: Int = 0, size: Int = 10): Page<Field> =
        client.get("/api/fields") {
            parameter("page", page)
            parameter("size", size)
        }.body()

    suspend fun getFieldById(id: Long): Field =
        client.get("/api/fields/$id").body()

    suspend fun getSchedule(fieldId: Long, date: String): List<TimeSlot> =
        client.get("/api/fields/$fieldId/schedule") {
            parameter("date", date)   // "2026-05-10"
        }.body()

    suspend fun getMyFields(page: Int = 0, size: Int = 10): Page<Field> =
        client.get("/api/fields/my") {
            parameter("page", page)
            parameter("size", size)
        }.body()
}
