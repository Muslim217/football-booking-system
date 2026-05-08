package com.fieldbook.app.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.fieldbook.app.ui.components.ErrorBox
import com.fieldbook.app.ui.components.LoadingBox
import com.fieldbook.app.ui.components.StatusChip
import com.fieldbook.app.viewmodel.BookingViewModel
import com.fieldbook.shared.model.Booking
import org.koin.compose.viewmodel.koinViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MyBookingsScreen(
    onBack: () -> Unit,
    viewModel: BookingViewModel = koinViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(Unit) { viewModel.loadMyBookings() }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Мои бронирования") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Назад")
                    }
                }
            )
        }
    ) { padding ->
        when {
            uiState.isLoading -> LoadingBox(Modifier.padding(padding))
            uiState.error != null -> ErrorBox(uiState.error!!, onRetry = { viewModel.loadMyBookings() })
            uiState.bookings.isEmpty() -> {
                Box(Modifier.fillMaxSize().padding(padding), contentAlignment = Alignment.Center) {
                    Text("У вас пока нет бронирований", color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }
            else -> {
                LazyColumn(
                    modifier       = Modifier.fillMaxSize().padding(padding),
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(uiState.bookings, key = { it.id }) { booking ->
                        BookingCard(
                            booking  = booking,
                            onCancel = if (booking.status == "CONFIRMED") {
                                { viewModel.cancelBooking(booking.id) }
                            } else null
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun BookingCard(booking: Booking, onCancel: (() -> Unit)?) {
    Card(
        modifier  = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Row(
                Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment     = Alignment.CenterVertically
            ) {
                Text(booking.fieldName, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
                StatusChip(booking.status)
            }

            val startDate = booking.startTime.take(10)
            val startHour = booking.startTime.substring(11, 16)
            val endHour   = booking.endTime.substring(11, 16)
            Text("$startDate   $startHour – $endHour", style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant)

            Row(
                Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment     = Alignment.CenterVertically
            ) {
                Text(
                    "${booking.totalPrice.toInt()} ₽",
                    style      = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.Bold,
                    color      = MaterialTheme.colorScheme.primary
                )
                if (onCancel != null) {
                    var showDialog by remember { mutableStateOf(false) }
                    OutlinedButton(
                        onClick = { showDialog = true },
                        colors  = ButtonDefaults.outlinedButtonColors(contentColor = MaterialTheme.colorScheme.error)
                    ) {
                        Text("Отменить")
                    }
                    if (showDialog) {
                        AlertDialog(
                            onDismissRequest = { showDialog = false },
                            title   = { Text("Отмена бронирования") },
                            text    = { Text("Вы уверены, что хотите отменить бронирование?") },
                            confirmButton = {
                                TextButton(onClick = { showDialog = false; onCancel() }) { Text("Да, отменить") }
                            },
                            dismissButton = {
                                TextButton(onClick = { showDialog = false }) { Text("Нет") }
                            }
                        )
                    }
                }
            }
        }
    }
}
