package com.fieldbook.shared.util

/**
 * Обёртка для результата любого API вызова.
 * Используется во всех Repository и ViewModel.
 */
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val message: String, val code: Int? = null) : Result<Nothing>()
    data object Loading : Result<Nothing>()
}

inline fun <T> Result<T>.onSuccess(action: (T) -> Unit): Result<T> {
    if (this is Result.Success) action(data)
    return this
}

inline fun <T> Result<T>.onError(action: (String, Int?) -> Unit): Result<T> {
    if (this is Result.Error) action(message, code)
    return this
}

fun <T> Result<T>.getOrNull(): T? = if (this is Result.Success) data else null
