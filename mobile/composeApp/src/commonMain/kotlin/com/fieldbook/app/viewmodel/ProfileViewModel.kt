package com.fieldbook.app.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.fieldbook.shared.model.UserProfile
import com.fieldbook.shared.repository.UserRepository
import com.fieldbook.shared.util.Result
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

data class ProfileUiState(
    val profile: UserProfile? = null,
    val isLoading: Boolean    = false,
    val isSaving: Boolean     = false,
    val error: String?        = null,
    val saveSuccess: Boolean  = false
)

class ProfileViewModel(private val userRepository: UserRepository) : ViewModel() {

    private val _uiState = MutableStateFlow(ProfileUiState())
    val uiState: StateFlow<ProfileUiState> = _uiState.asStateFlow()

    init { loadProfile() }

    fun loadProfile() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            when (val result = userRepository.getMyProfile()) {
                is Result.Success -> _uiState.update { it.copy(profile = result.data, isLoading = false) }
                is Result.Error   -> _uiState.update { it.copy(isLoading = false, error = result.message) }
                else -> {}
            }
        }
    }

    fun updateProfile(fullName: String, phone: String) {
        viewModelScope.launch {
            _uiState.update { it.copy(isSaving = true, error = null) }
            when (val result = userRepository.updateMyProfile(
                fullName.ifBlank { null },
                phone.ifBlank { null }
            )) {
                is Result.Success -> _uiState.update { it.copy(profile = result.data, isSaving = false, saveSuccess = true) }
                is Result.Error   -> _uiState.update { it.copy(isSaving = false, error = result.message) }
                else -> {}
            }
        }
    }

    fun clearError()   = _uiState.update { it.copy(error = null) }
    fun resetSuccess() = _uiState.update { it.copy(saveSuccess = false) }
}
