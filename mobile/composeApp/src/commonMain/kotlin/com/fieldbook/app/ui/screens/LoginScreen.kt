package com.fieldbook.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.fieldbook.app.ui.components.StadiumButton
import com.fieldbook.app.ui.components.StadiumTextField
import com.fieldbook.app.ui.theme.*
import com.fieldbook.app.viewmodel.AuthViewModel
import org.koin.compose.viewmodel.koinViewModel

@Composable
fun LoginScreen(
    onLoginSuccess: () -> Unit,
    onNavigateToRegister: () -> Unit,
    viewModel: AuthViewModel = koinViewModel(),
) {
    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(uiState.isSuccess) {
        if (uiState.isSuccess) { viewModel.resetSuccess(); onLoginSuccess() }
    }

    Box(
        Modifier
            .fillMaxSize()
            .background(ColorBg),
    ) {
        // Green header accent
        Box(
            Modifier
                .fillMaxWidth()
                .height(220.dp)
                .background(
                    Brush.verticalGradient(listOf(ColorPrimary, ColorPrimaryDark)),
                ),
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 24.dp),
            verticalArrangement = Arrangement.Center,
        ) {
            Spacer(Modifier.height(60.dp))

            // Logo block
            Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.fillMaxWidth()) {
                Surface(
                    shape = RoundedCornerShape(20.dp),
                    color = ColorSurface.copy(alpha = 0.15f),
                    modifier = Modifier.size(72.dp),
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Text("S", style = MaterialTheme.typography.displaySmall, fontWeight = FontWeight.W700, color = Color.White)
                    }
                }
                Spacer(Modifier.height(16.dp))
                Text(
                    "Stadium",
                    style     = MaterialTheme.typography.displaySmall,
                    fontWeight = FontWeight.W700,
                    color     = Color.White,
                )
                Text(
                    "Бронирование площадок",
                    style  = MaterialTheme.typography.bodyMedium,
                    color  = Color.White.copy(alpha = 0.8f),
                    textAlign = TextAlign.Center,
                )
            }

            Spacer(Modifier.height(40.dp))

            // Card
            Surface(
                shape    = RoundedCornerShape(20.dp),
                color    = ColorSurface,
                tonalElevation = 0.dp,
                modifier = Modifier.fillMaxWidth(),
                shadowElevation = 2.dp,
            ) {
                Column(
                    modifier = Modifier.padding(24.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp),
                ) {
                    Text("Вход", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.W700, color = ColorText)

                    var username by remember { mutableStateOf("") }
                    var password by remember { mutableStateOf("") }

                    StadiumTextField(
                        value         = username,
                        onValueChange = { username = it },
                        label         = "Имя пользователя",
                        placeholder   = "your_username",
                    )
                    StadiumTextField(
                        value         = password,
                        onValueChange = { password = it },
                        label         = "Пароль",
                        isPassword    = true,
                    )

                    uiState.error?.let { err ->
                        Surface(color = ColorDangerSoft, shape = RoundedCornerShape(8.dp)) {
                            Text(err, color = ColorDanger, style = MaterialTheme.typography.bodySmall,
                                modifier = Modifier.padding(10.dp))
                        }
                    }

                    StadiumButton(
                        text    = "Войти",
                        onClick = { viewModel.login(username, password) },
                        loading = uiState.isLoading,
                    )
                }
            }

            Spacer(Modifier.height(16.dp))

            TextButton(
                onClick  = onNavigateToRegister,
                modifier = Modifier.fillMaxWidth(),
            ) {
                Text(
                    "Нет аккаунта? Зарегистрироваться",
                    style = MaterialTheme.typography.bodyMedium,
                    color = ColorPrimary,
                    fontWeight = FontWeight.W500,
                )
            }
            Spacer(Modifier.height(32.dp))
        }
    }
}
