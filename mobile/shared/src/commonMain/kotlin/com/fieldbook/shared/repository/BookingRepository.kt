package com.fieldbook.shared.repository

import com.fieldbook.shared.api.BookingApi
import com.fieldbook.shared.model.*
import com.fieldbook.shared.util.Result

class BookingRepository(private val bookingApi: BookingApi) {

    suspend fun createBooking(fieldId: Long, startTime: String, endTime: String): Result<Booking> =
        runCatching {
            Result.Success(bookingApi.createBooking(CreateBookingRequest(fieldId, startTime, endTime)))
        }.getOrElse { Result.Error(it.message ?: "Ошибка создания бронирования") }

    suspend fun getMyBookings(page: Int = 0, size: Int = 10): Result<Page<Booking>> =
        runCatching { Result.Success(bookingApi.getMyBookings(page, size)) }
            .getOrElse { Result.Error(it.message ?: "Ошибка загрузки бронирований") }

    suspend fun cancelBooking(id: Long): Result<Booking> =
        runCatching { Result.Success(bookingApi.cancelBooking(id)) }
            .getOrElse { Result.Error(it.message ?: "Ошибка отмены бронирования") }
}
