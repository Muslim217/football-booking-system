package com.fieldbook.app.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.fieldbook.app.ui.components.*
import com.fieldbook.app.viewmodel.AuthViewModel
import org.koin.compose.viewmodel.koinViewModel

@Composable
fun LoginScreen(
    onLoginSuccess: () -> Unit,
    onNavigateToRegister: () -> Unit,
    viewModel: AuthViewModel = koinViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(uiState.isSuccess) {
        if (uiState.isSuccess) {
            viewModel.resetSuccess()
            onLoginSuccess()
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 24.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Заголовок
        Text(
            text  = "⚽ FieldBooking",
            style = MaterialTheme.typography.headlineMedium.copy(fontWeight = FontWeight.Bold),
            color = MaterialTheme.colorScheme.primary
        )
        Text(
            text  = "Бронирование спортивных площадок",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Spacer(Modifier.height(40.dp))

        // Форма
        var username by remember { mutableStateOf("") }
        var password by remember { mutableStateOf("") }

        FieldBookingTextField(
            value         = username,
            onValueChange = { username = it },
            label         = "Имя пользователя"
        )
        Spacer(Modifier.height(12.dp))
        FieldBookingTextField(
            value         = password,
            onValueChange = { password = it },
            label         = "Пароль",
            isPassword    = true
        )
        Spacer(Modifier.height(8.dp))

        // Ошибка
        uiState.error?.let { error ->
            Text(error, color = MaterialTheme.colorScheme.error, style = MaterialTheme.typography.bodySmall)
            Spacer(Modifier.height(8.dp))
        }

        // Кнопка входа
        FieldBookingButton(
            text    = "Войти",
            onClick = { viewModel.login(username, password) },
            loading = uiState.isLoading
        )
        Spacer(Modifier.height(16.dp))

        // Переход к регистрации
        TextButton(onClick = onNavigateToRegister) {
            Text("Нет аккаунта? Зарегистрироваться")
        }
    }
}
