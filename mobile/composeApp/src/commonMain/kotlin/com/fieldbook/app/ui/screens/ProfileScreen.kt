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
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.fieldbook.app.ui.components.LoadingBox
import com.fieldbook.app.ui.components.StadiumButton
import com.fieldbook.app.ui.components.StadiumTextField
import com.fieldbook.app.ui.theme.*
import com.fieldbook.app.viewmodel.AuthViewModel
import com.fieldbook.app.viewmodel.ProfileViewModel
import org.koin.compose.viewmodel.koinViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(
    onLogout: () -> Unit,
    onBack: () -> Unit,
    profileViewModel: ProfileViewModel = koinViewModel(),
    authViewModel: AuthViewModel       = koinViewModel(),
) {
    val uiState by profileViewModel.uiState.collectAsState()
    var fullName by remember { mutableStateOf("") }
    var phone    by remember { mutableStateOf("") }

    LaunchedEffect(uiState.profile) {
        uiState.profile?.let { fullName = it.fullName ?: ""; phone = it.phone ?: "" }
    }
    LaunchedEffect(uiState.saveSuccess) { if (uiState.saveSuccess) profileViewModel.resetSuccess() }

    Scaffold(
        containerColor = ColorBg,
        topBar = {
            TopAppBar(
                title = { Text("Профиль", fontWeight = FontWeight.W700, color = ColorText) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Назад", tint = ColorText)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = ColorBg),
            )
        },
    ) { padding ->
        when {
            uiState.isLoading && uiState.profile == null -> LoadingBox(Modifier.padding(padding))
            else -> {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding)
                        .padding(horizontal = 20.dp)
                        .verticalScroll(rememberScrollState()),
                    verticalArrangement = Arrangement.spacedBy(16.dp),
                ) {
                    Spacer(Modifier.height(4.dp))

                    // Avatar card
                    uiState.profile?.let { profile ->
                        Surface(
                            shape    = RoundedCornerShape(20.dp),
                            color    = ColorSurface,
                            modifier = Modifier.fillMaxWidth(),
                            shadowElevation = 2.dp,
                        ) {
                            Row(
                                Modifier.padding(20.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(16.dp),
                            ) {
                                // Avatar circle
                                Box(
                                    modifier = Modifier
                                        .size(56.dp)
                                        .clip(RoundedCornerShape(28.dp))
                                        .background(
                                            Brush.linearGradient(listOf(ColorPrimaryLight, ColorPrimaryDark)),
                                        ),
                                    contentAlignment = Alignment.Center,
                                ) {
                                    Text(
                                        profile.username.first().uppercaseChar().toString(),
                                        style     = MaterialTheme.typography.headlineMedium,
                                        fontWeight = FontWeight.W700,
                                        color     = Color.White,
                                    )
                                }
                                Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                                    Text(profile.username, style = MaterialTheme.typography.titleMedium,
                                        fontWeight = FontWeight.W700, color = ColorText)
                                    Text(profile.email, style = MaterialTheme.typography.bodySmall, color = ColorTextMuted)
                                    Surface(color = ColorPrimarySoft, shape = RoundedCornerShape(6.dp)) {
                                        Text(roleLabel(profile.role), color = ColorPrimary,
                                            style = MaterialTheme.typography.labelSmall,
                                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp))
                                    }
                                }
                            }
                        }
                    }

                    // Edit form
                    Surface(
                        shape    = RoundedCornerShape(20.dp),
                        color    = ColorSurface,
                        modifier = Modifier.fillMaxWidth(),
                        shadowElevation = 2.dp,
                    ) {
                        Column(
                            Modifier.padding(20.dp),
                            verticalArrangement = Arrangement.spacedBy(14.dp),
                        ) {
                            Text("Редактировать профиль", style = MaterialTheme.typography.titleSmall,
                                fontWeight = FontWeight.W700, color = ColorTextMuted)

                            StadiumTextField(value = fullName, onValueChange = { fullName = it },
                                label = "Полное имя", placeholder = "Иван Иванов")
                            StadiumTextField(value = phone,    onValueChange = { phone = it },
                                label = "Телефон", placeholder = "+7 999 000 00 00")

                            uiState.error?.let {
                                Text(it, color = ColorDanger, style = MaterialTheme.typography.bodySmall)
                            }
                            if (uiState.saveSuccess) {
                                Surface(color = ColorPrimarySoft, shape = RoundedCornerShape(8.dp)) {
                                    Text("Профиль обновлён", color = ColorPrimary,
                                        style = MaterialTheme.typography.bodySmall,
                                        modifier = Modifier.padding(10.dp))
                                }
                            }

                            StadiumButton(
                                text    = "Сохранить",
                                onClick = { profileViewModel.updateProfile(fullName, phone) },
                                loading = uiState.isSaving,
                            )
                        }
                    }

                    // Logout
                    OutlinedButton(
                        onClick  = { authViewModel.logout(); onLogout() },
                        modifier = Modifier.fillMaxWidth().height(52.dp),
                        shape    = RoundedCornerShape(14.dp),
                        colors   = ButtonDefaults.outlinedButtonColors(contentColor = ColorDanger),
                        border   = androidx.compose.foundation.BorderStroke(1.dp, ColorDanger.copy(alpha = 0.4f)),
                    ) {
                        Text("Выйти из аккаунта", style = MaterialTheme.typography.titleSmall,
                            fontWeight = FontWeight.W600)
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
