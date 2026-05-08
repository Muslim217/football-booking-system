package com.fieldbook.app.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.fieldbook.shared.model.Field
import com.fieldbook.shared.model.TimeSlot
import com.fieldbook.shared.repository.FieldRepository
import com.fieldbook.shared.util.Result
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

data class FieldListUiState(
    val fields: List<Field>  = emptyList(),
    val isLoading: Boolean   = false,
    val error: String?       = null,
    val hasMore: Boolean     = true,
    val currentPage: Int     = 0
)

data class FieldDetailUiState(
    val field: Field?       = null,
    val isLoading: Boolean  = false,
    val error: String?      = null
)

data class ScheduleUiState(
    val slots: List<TimeSlot> = emptyList(),
    val isLoading: Boolean    = false,
    val error: String?        = null,
    val selectedSlot: TimeSlot? = null
)

class FieldViewModel(private val fieldRepository: FieldRepository) : ViewModel() {

    private val _listState = MutableStateFlow(FieldListUiState())
    val listState: StateFlow<FieldListUiState> = _listState.asStateFlow()

    private val _detailState = MutableStateFlow(FieldDetailUiState())
    val detailState: StateFlow<FieldDetailUiState> = _detailState.asStateFlow()

    private val _scheduleState = MutableStateFlow(ScheduleUiState())
    val scheduleState: StateFlow<ScheduleUiState> = _scheduleState.asStateFlow()

    init { loadFields() }

    fun loadFields(refresh: Boolean = false) {
        val page = if (refresh) 0 else _listState.value.currentPage
        viewModelScope.launch {
            _listState.update { it.copy(isLoading = true, error = null) }
            when (val result = fieldRepository.getFields(page)) {
                is Result.Success -> {
                    val newFields = if (refresh) result.data.content
                                    else _listState.value.fields + result.data.content
                    _listState.update {
                        it.copy(
                            fields      = newFields,
                            isLoading   = false,
                            hasMore     = !result.data.last,
                            currentPage = page + 1
                        )
                    }
                }
                is Result.Error -> _listState.update { it.copy(isLoading = false, error = result.message) }
                else -> {}
            }
        }
    }

    fun loadField(id: Long) {
        viewModelScope.launch {
            _detailState.update { it.copy(isLoading = true, error = null) }
            when (val result = fieldRepository.getFieldById(id)) {
                is Result.Success -> _detailState.update { it.copy(field = result.data, isLoading = false) }
                is Result.Error   -> _detailState.update { it.copy(isLoading = false, error = result.message) }
                else -> {}
            }
        }
    }

    fun loadSchedule(fieldId: Long, date: String) {
        viewModelScope.launch {
            _scheduleState.update { it.copy(isLoading = true, error = null) }
            when (val result = fieldRepository.getSchedule(fieldId, date)) {
                is Result.Success -> _scheduleState.update { it.copy(slots = result.data, isLoading = false) }
                is Result.Error   -> _scheduleState.update { it.copy(isLoading = false, error = result.message) }
                else -> {}
            }
        }
    }

    fun selectSlot(slot: TimeSlot) {
        _scheduleState.update { it.copy(selectedSlot = if (it.selectedSlot == slot) null else slot) }
    }
}
