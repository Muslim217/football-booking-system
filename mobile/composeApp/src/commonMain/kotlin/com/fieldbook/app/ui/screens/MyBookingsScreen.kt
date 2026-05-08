package com.fieldbook.app.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.fieldbook.app.ui.components.ErrorBox
import com.fieldbook.app.ui.components.LoadingBox
import com.fieldbook.app.ui.components.StatusChip
import com.fieldbook.app.ui.theme.*
import com.fieldbook.app.viewmodel.BookingViewModel
import com.fieldbook.shared.model.Booking
import org.koin.compose.viewmodel.koinViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MyBookingsScreen(
    onBack: () -> Unit,
    viewModel: BookingViewModel = koinViewModel(),
) {
    val uiState by viewModel.uiState.collectAsState()
    LaunchedEffect(Unit) { viewModel.loadMyBookings() }

    Scaffold(
        containerColor = ColorBg,
        topBar = {
            TopAppBar(
                title = { Text("Мои бронирования", fontWeight = FontWeight.W700, color = ColorText) },
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
            uiState.isLoading -> LoadingBox(Modifier.padding(padding))
            uiState.error != null -> ErrorBox(uiState.error!!, onRetry = { viewModel.loadMyBookings() })
            uiState.bookings.isEmpty() -> {
                Box(Modifier.fillMaxSize().padding(padding), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text("Бронирований пока нет", style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.W700, color = ColorText)
                        Text("Выберите площадку и забронируйте время",
                            style = MaterialTheme.typography.bodyMedium, color = ColorTextMuted,
                            textAlign = TextAlign.Center)
                    }
                }
            }
            else -> {
                LazyColumn(
                    modifier            = Modifier.fillMaxSize().padding(padding),
                    contentPadding      = PaddingValues(horizontal = 16.dp, vertical = 12.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp),
                ) {
                    items(uiState.bookings, key = { it.id }) { booking ->
                        BookingCard(
                            booking  = booking,
                            onCancel = if (booking.status == "CONFIRMED") {
                                { viewModel.cancelBooking(booking.id) }
                            } else null,
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun BookingCard(booking: Booking, onCancel: (() -> Unit)?) {
    Surface(
        shape    = RoundedCornerShape(14.dp),
        color    = ColorSurface,
        modifier = Modifier.fillMaxWidth(),
        shadowElevation = 2.dp,
    ) {
        Column(Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Row(
                Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment     = Alignment.Top,
            ) {
                Text(booking.fieldName, style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.W700, color = ColorText, modifier = Modifier.weight(1f))
                StatusChip(booking.status)
            }

            val startDate = booking.startTime.take(10)
            val startHour = if (booking.startTime.length >= 16) booking.startTime.substring(11, 16) else ""
            val endHour   = if (booking.endTime.length   >= 16) booking.endTime.substring(11, 16)   else ""

            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                Surface(color = ColorBg, shape = RoundedCornerShape(6.dp)) {
                    Text(startDate, style = MaterialTheme.typography.bodySmall, color = ColorTextMuted,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp))
                }
                if (startHour.isNotEmpty()) {
                    Text("$startHour – $endHour", style = MaterialTheme.typography.bodyMedium,
                        fontWeight = FontWeight.W600, color = ColorText)
                }
            }

            Row(
                Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment     = Alignment.CenterVertically,
            ) {
                Text(
                    "${booking.totalPrice.toInt()} ₽",
                    style     = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.W700,
                    color     = ColorPrimary,
                )
                if (onCancel != null) {
                    var showDialog by remember { mutableStateOf(false) }
                    OutlinedButton(
                        onClick = { showDialog = true },
                        shape   = RoundedCornerShape(8.dp),
                        colors  = ButtonDefaults.outlinedButtonColors(contentColor = ColorDanger),
                        border  = androidx.compose.foundation.BorderStroke(1.dp, ColorDanger.copy(alpha = 0.4f)),
                        contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp),
                    ) {
                        Text("Отменить", style = MaterialTheme.typography.labelMedium)
                    }
                    if (showDialog) {
                        AlertDialog(
                            onDismissRequest = { showDialog = false },
                            shape            = RoundedCornerShape(20.dp),
                            containerColor   = ColorSurface,
                            title   = { Text("Отмена бронирования", fontWeight = FontWeight.W700, color = ColorText) },
                            text    = { Text("Вы уверены, что хотите отменить бронирование?", color = ColorTextMuted) },
                            confirmButton = {
                                TextButton(onClick = { showDialog = false; onCancel() }) {
                                    Text("Да, отменить", color = ColorDanger, fontWeight = FontWeight.W600)
                                }
                            },
                            dismissButton = {
                                TextButton(onClick = { showDialog = false }) {
                                    Text("Нет", color = ColorTextMuted)
                                }
                            },
                        )
                    }
                }
            }
        }
    }
}
