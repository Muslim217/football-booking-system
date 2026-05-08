package com.fieldbook.app.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.fieldbook.app.ui.components.FieldBookingButton
import com.fieldbook.app.ui.components.FieldBookingTextField
import com.fieldbook.app.ui.components.LoadingBox
import com.fieldbook.app.viewmodel.AuthViewModel
import com.fieldbook.app.viewmodel.ProfileViewModel
import org.koin.compose.viewmodel.koinViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(
    onLogout: () -> Unit,
    onBack: () -> Unit,
    profileViewModel: ProfileViewModel = koinViewModel(),
    authViewModel: AuthViewModel       = koinViewModel()
) {
    val uiState by profileViewModel.uiState.collectAsState()

    // Инициализируем поля из профиля
    var fullName by remember { mutableStateOf("") }
    var phone    by remember { mutableStateOf("") }

    LaunchedEffect(uiState.profile) {
        uiState.profile?.let {
            fullName = it.fullName ?: ""
            phone    = it.phone    ?: ""
        }
    }

    LaunchedEffect(uiState.saveSuccess) {
        if (uiState.saveSuccess) profileViewModel.resetSuccess()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Профиль") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Назад")
                    }
                }
            )
        }
    ) { padding ->
        when {
            uiState.isLoading && uiState.profile == null -> LoadingBox(Modifier.padding(padding))
            else -> {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding)
                        .padding(horizontal = 24.dp)
                        .verticalScroll(rememberScrollState()),
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    Spacer(Modifier.height(8.dp))

                    // Аватар + имя пользователя
                    uiState.profile?.let { profile ->
                        Card(
                            colors   = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Column(
                                Modifier.padding(20.dp).fillMaxWidth(),
                                horizontalAlignment = Alignment.CenterHorizontally,
                                verticalArrangement = Arrangement.spacedBy(4.dp)
                            ) {
                                Surface(
                                    shape  = MaterialTheme.shapes.extraLarge,
                                    color  = MaterialTheme.colorScheme.primary,
                                    modifier = Modifier.size(64.dp)
                                ) {
                                    Box(contentAlignment = Alignment.Center) {
                                        Text(
                                            profile.username.first().uppercaseChar().toString(),
                                            style = MaterialTheme.typography.headlineMedium,
                                            color = MaterialTheme.colorScheme.onPrimary
                                        )
                                    }
                                }
                                Spacer(Modifier.height(8.dp))
                                Text(profile.username, style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                                Text(profile.email,    style = MaterialTheme.typography.bodyMedium,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant)
                                AssistChip(
                                    onClick = {},
                                    label   = { Text(roleLabel(profile.role)) }
                                )
                            }
                        }
                    }

                    HorizontalDivider()
                    Text("Редактировать профиль", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)

                    FieldBookingTextField(value = fullName, onValueChange = { fullName = it }, label = "Полное имя")
                    FieldBookingTextField(value = phone,    onValueChange = { phone = it },    label = "Телефон")

                    uiState.error?.let {
                        Text(it, color = MaterialTheme.colorScheme.error, style = MaterialTheme.typography.bodySmall)
                    }
                    if (uiState.saveSuccess) {
                        Text("Профиль обновлён", color = MaterialTheme.colorScheme.primary,
                            style = MaterialTheme.typography.bodySmall)
                    }

                    FieldBookingButton(
                        text    = "Сохранить",
                        onClick = { profileViewModel.updateProfile(fullName, phone) },
                        loading = uiState.isSaving
                    )

                    HorizontalDivider()

                    // Выход
                    OutlinedButton(
                        onClick  = { authViewModel.logout(); onLogout() },
                        modifier = Modifier.fillMaxWidth().height(52.dp),
                        colors   = ButtonDefaults.outlinedButtonColors(contentColor = MaterialTheme.colorScheme.error)
                    ) {
                        Text("Выйти из аккаунта")
                    }
                    Spacer(Modifier.height(24.dp))
                }
            }
        }
    }
}

private fun roleLabel(role: String) = when (role) {
    "ADMIN" -> "Администратор"
    "OWNER" -> "Владелец площадки"
    else    -> "Пользователь"
}
