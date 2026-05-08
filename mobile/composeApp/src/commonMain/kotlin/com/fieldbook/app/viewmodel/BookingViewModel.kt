package com.fieldbook.app.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.fieldbook.shared.model.Booking
import com.fieldbook.shared.repository.BookingRepository
import com.fieldbook.shared.util.Result
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

data class BookingUiState(
    val bookings: List<Booking> = emptyList(),
    val isLoading: Boolean      = false,
    val error: String?          = null,
    val bookingSuccess: Boolean = false
)

class BookingViewModel(private val bookingRepository: BookingRepository) : ViewModel() {

    private val _uiState = MutableStateFlow(BookingUiState())
    val uiState: StateFlow<BookingUiState> = _uiState.asStateFlow()

    fun loadMyBookings() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            when (val result = bookingRepository.getMyBookings()) {
                is Result.Success -> _uiState.update { it.copy(bookings = result.data.content, isLoading = false) }
                is Result.Error   -> _uiState.update { it.copy(isLoading = false, error = result.message) }
                else -> {}
            }
        }
    }

    fun createBooking(fieldId: Long, startTime: String, endTime: String) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null, bookingSuccess = false) }
            when (val result = bookingRepository.createBooking(fieldId, startTime, endTime)) {
                is Result.Success -> _uiState.update { it.copy(isLoading = false, bookingSuccess = true) }
                is Result.Error   -> _uiState.update { it.copy(isLoading = false, error = result.message) }
                else -> {}
            }
        }
    }

    fun cancelBooking(id: Long) {
        viewModelScope.launch {
            when (val result = bookingRepository.cancelBooking(id)) {
                is Result.Success -> {
                    _uiState.update { state ->
                        state.copy(bookings = state.bookings.map {
                            if (it.id == id) result.data else it
                        })
                    }
                }
                is Result.Error -> _uiState.update { it.copy(error = result.message) }
                else -> {}
            }
        }
    }

    fun clearError()   = _uiState.update { it.copy(error = null) }
    fun resetSuccess() = _uiState.update { it.copy(bookingSuccess = false) }
}
