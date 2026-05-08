package com.fieldbook.app.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.fieldbook.app.ui.components.*
import com.fieldbook.app.viewmodel.AuthViewModel
import org.koin.compose.viewmodel.koinViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RegisterScreen(
    onRegisterSuccess: () -> Unit,
    onNavigateToLogin: () -> Unit,
    viewModel: AuthViewModel = koinViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(uiState.isSuccess) {
        if (uiState.isSuccess) {
            viewModel.resetSuccess()
            onRegisterSuccess()
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Регистрация") },
                navigationIcon = {
                    IconButton(onClick = onNavigateToLogin) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Назад")
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 24.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Spacer(Modifier.height(16.dp))

            var username        by remember { mutableStateOf("") }
            var email           by remember { mutableStateOf("") }
            var password        by remember { mutableStateOf("") }
            var confirmPassword by remember { mutableStateOf("") }

            FieldBookingTextField(value = username,        onValueChange = { username = it },        label = "Имя пользователя")
            FieldBookingTextField(value = email,           onValueChange = { email = it },           label = "Email")
            FieldBookingTextField(value = password,        onValueChange = { password = it },        label = "Пароль",           isPassword = true)
            FieldBookingTextField(value = confirmPassword, onValueChange = { confirmPassword = it }, label = "Подтвердите пароль", isPassword = true)

            uiState.error?.let {
                Text(it, color = MaterialTheme.colorScheme.error, style = MaterialTheme.typography.bodySmall)
            }

            FieldBookingButton(
                text    = "Зарегистрироваться",
                onClick = { viewModel.register(username, email, password, confirmPassword) },
                loading = uiState.isLoading
            )
            Spacer(Modifier.height(16.dp))
        }
    }
}
