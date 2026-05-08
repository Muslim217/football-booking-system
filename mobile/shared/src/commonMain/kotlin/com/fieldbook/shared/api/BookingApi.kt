package com.fieldbook.shared.api

import com.fieldbook.shared.model.*
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.request.*

class BookingApi(private val client: HttpClient) {

    suspend fun createBooking(request: CreateBookingRequest): Booking =
        client.post("/api/bookings") { setBody(request) }.body()

    suspend fun getMyBookings(page: Int = 0, size: Int = 10): Page<Booking> =
        client.get("/api/bookings/my") {
            parameter("page", page)
            parameter("size", size)
        }.body()

    suspend fun getBookingById(id: Long): Booking =
        client.get("/api/bookings/$id").body()

    suspend fun cancelBooking(id: Long): Booking =
        client.put("/api/bookings/$id/cancel").body()
}
