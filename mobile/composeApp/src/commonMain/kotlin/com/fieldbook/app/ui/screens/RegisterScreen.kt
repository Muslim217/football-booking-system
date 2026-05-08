package com.fieldbook.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.fieldbook.app.ui.components.StadiumButton
import com.fieldbook.app.ui.components.StadiumTextField
import com.fieldbook.app.ui.theme.*
import com.fieldbook.app.viewmodel.AuthViewModel
import org.koin.compose.viewmodel.koinViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RegisterScreen(
    onRegisterSuccess: () -> Unit,
    onNavigateToLogin: () -> Unit,
    viewModel: AuthViewModel = koinViewModel(),
) {
    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(uiState.isSuccess) {
        if (uiState.isSuccess) { viewModel.resetSuccess(); onRegisterSuccess() }
    }

    Scaffold(
        containerColor = ColorBg,
        topBar = {
            TopAppBar(
                title = { Text("Регистрация", fontWeight = FontWeight.W700, color = ColorText) },
                navigationIcon = {
                    IconButton(onClick = onNavigateToLogin) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Назад", tint = ColorText)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = ColorBg),
            )
        },
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 24.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            Spacer(Modifier.height(8.dp))

            var username        by remember { mutableStateOf("") }
            var email           by remember { mutableStateOf("") }
            var password        by remember { mutableStateOf("") }
            var confirmPassword by remember { mutableStateOf("") }

            StadiumTextField(value = username,        onValueChange = { username = it },        label = "Имя пользователя", placeholder = "your_username")
            StadiumTextField(value = email,           onValueChange = { email = it },           label = "Email",           placeholder = "mail@example.com")
            StadiumTextField(value = password,        onValueChange = { password = it },        label = "Пароль",          isPassword  = true)
            StadiumTextField(value = confirmPassword, onValueChange = { confirmPassword = it }, label = "Подтвердите пароль", isPassword = true)

            uiState.error?.let { err ->
                Surface(color = ColorDangerSoft, shape = RoundedCornerShape(8.dp)) {
                    Text(err, color = ColorDanger, style = MaterialTheme.typography.bodySmall,
                        modifier = Modifier.padding(10.dp))
                }
            }

            StadiumButton(
                text    = "Зарегистрироваться",
                onClick = { viewModel.register(username, email, password, confirmPassword) },
                loading = uiState.isLoading,
            )

            TextButton(onClick = onNavigateToLogin, modifier = Modifier.fillMaxWidth()) {
                Text("Уже есть аккаунт? Войти", color = ColorPrimary,
                    style = MaterialTheme.typography.bodyMedium, fontWeight = FontWeight.W500)
            }
            Spacer(Modifier.height(24.dp))
        }
    }
}
