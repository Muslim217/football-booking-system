package com.fieldbook.shared.model

import kotlinx.serialization.Serializable

// ─── Auth ────────────────────────────────────────────────────────────────────

@Serializable
data class LoginRequest(
    val username: String,
    val password: String
)

@Serializable
data class RegisterRequest(
    val username: String,
    val email: String,
    val password: String
)

@Serializable
data class RefreshTokenRequest(
    val refreshToken: String
)

@Serializable
data class AuthResponse(
    val accessToken: String,
    val refreshToken: String,
    val tokenType: String,
    val expiresIn: Long,
    val username: String,
    val role: String
)

// ─── User ─────────────────────────────────────────────────────────────────────

@Serializable
data class UserProfile(
    val id: Long,
    val username: String,
    val email: String,
    val fullName: String? = null,
    val phone: String? = null,
    val role: String,
    val createdAt: String
)

@Serializable
data class UpdateProfileRequest(
    val fullName: String? = null,
    val phone: String? = null
)

// ─── Field ────────────────────────────────────────────────────────────────────

@Serializable
data class Field(
    val id: Long,
    val name: String,
    val address: String,
    val city: String? = null,
    val fieldType: String,
    val pricePerHour: Double,
    val description: String? = null,
    val photoUrl: String? = null,
    val isActive: Boolean,
    val ownerUsername: String,
    val createdAt: String
)

@Serializable
data class TimeSlot(
    val startTime: String,   // "08:00:00"
    val endTime: String,     // "09:00:00"
    val available: Boolean,
    val price: Double
)

// ─── Booking ──────────────────────────────────────────────────────────────────

@Serializable
data class Booking(
    val id: Long,
    val username: String,
    val fieldId: Long,
    val fieldName: String,
    val startTime: String,
    val endTime: String,
    val totalPrice: Double,
    val status: String,
    val createdAt: String
)

@Serializable
data class CreateBookingRequest(
    val fieldId: Long,
    val startTime: String,  // ISO: "2026-05-10T10:00:00"
    val endTime: String
)

// ─── Pagination ───────────────────────────────────────────────────────────────

@Serializable
data class Page<T>(
    val content: List<T>,
    val totalElements: Long,
    val totalPages: Int,
    val number: Int,        // текущая страница
    val size: Int,
    val last: Boolean,
    val first: Boolean
)

// ─── Error ────────────────────────────────────────────────────────────────────

@Serializable
data class ApiError(
    val message: String,
    val status: Int? = null
)
