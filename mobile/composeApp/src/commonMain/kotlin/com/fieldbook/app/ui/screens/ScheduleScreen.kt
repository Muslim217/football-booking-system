package com.fieldbook.app.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
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
import com.fieldbook.app.ui.components.FieldBookingButton
import com.fieldbook.app.ui.components.LoadingBox
import com.fieldbook.app.ui.theme.Green600
import com.fieldbook.app.viewmodel.BookingViewModel
import com.fieldbook.app.viewmodel.FieldViewModel
import com.fieldbook.shared.model.TimeSlot
import org.koin.compose.viewmodel.koinViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ScheduleScreen(
    fieldId: Long,
    date: String,
    onBack: () -> Unit,
    onBooked: () -> Unit,
    fieldViewModel: FieldViewModel   = koinViewModel(),
    bookingViewModel: BookingViewModel = koinViewModel()
) {
    val scheduleState by fieldViewModel.scheduleState.collectAsState()
    val bookingState  by bookingViewModel.uiState.collectAsState()

    LaunchedEffect(fieldId, date) { fieldViewModel.loadSchedule(fieldId, date) }

    // Переход к моим бронированиям после успешного бронирования
    LaunchedEffect(bookingState.bookingSuccess) {
        if (bookingState.bookingSuccess) {
            bookingViewModel.resetSuccess()
            onBooked()
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Расписание — $date") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Назад")
                    }
                }
            )
        }
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding)) {
            when {
                scheduleState.isLoading -> LoadingBox()
                scheduleState.error != null -> ErrorBox(scheduleState.error!!)
                else -> {
                    // Сетка слотов
                    LazyVerticalGrid(
                        columns             = GridCells.Fixed(3),
                        modifier            = Modifier.weight(1f).padding(16.dp),
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        verticalArrangement   = Arrangement.spacedBy(8.dp)
                    ) {
                        items(scheduleState.slots) { slot ->
                            SlotItem(
                                slot       = slot,
                                isSelected = scheduleState.selectedSlot == slot,
                                onClick    = { if (slot.available) fieldViewModel.selectSlot(slot) }
                            )
                        }
                    }

                    // Легенда
                    Row(
                        Modifier.fillMaxWidth().padding(horizontal = 16.dp),
                        horizontalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        LegendItem(color = MaterialTheme.colorScheme.primary, label = "Свободно")
                        LegendItem(color = MaterialTheme.colorScheme.surfaceVariant, label = "Занято")
                        LegendItem(color = MaterialTheme.colorScheme.secondary, label = "Выбрано")
                    }

                    Spacer(Modifier.height(12.dp))

                    // Кнопка бронирования
                    val selected = scheduleState.selectedSlot
                    if (selected != null) {
                        Card(
                            modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
                            colors   = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer)
                        ) {
                            Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                Text("Выбранный слот", style = MaterialTheme.typography.labelMedium)
                                Text(
                                    "${selected.startTime.take(5)} – ${selected.endTime.take(5)}",
                                    style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold
                                )
                                Text("${selected.price.toInt()} ₽", color = MaterialTheme.colorScheme.primary,
                                    style = MaterialTheme.typography.titleSmall)
                            }
                        }
                        Spacer(Modifier.height(8.dp))
                    }

                    bookingState.error?.let {
                        Text(it, color = MaterialTheme.colorScheme.error,
                            style = MaterialTheme.typography.bodySmall,
                            modifier = Modifier.padding(horizontal = 16.dp))
                        Spacer(Modifier.height(4.dp))
                    }

                    FieldBookingButton(
                        text    = "Забронировать",
                        onClick = {
                            val slot = scheduleState.selectedSlot ?: return@FieldBookingButton
                            bookingViewModel.createBooking(
                                fieldId   = fieldId,
                                startTime = "${date}T${slot.startTime}",
                                endTime   = "${date}T${slot.endTime}"
                            )
                        },
                        modifier = Modifier.padding(horizontal = 16.dp),
                        enabled  = scheduleState.selectedSlot != null,
                        loading  = bookingState.isLoading
                    )
                    Spacer(Modifier.height(16.dp))
                }
            }
        }
    }
}

@Composable
private fun SlotItem(slot: TimeSlot, isSelected: Boolean, onClick: () -> Unit) {
    val containerColor = when {
        isSelected     -> MaterialTheme.colorScheme.secondary
        slot.available -> MaterialTheme.colorScheme.primaryContainer
        else           -> MaterialTheme.colorScheme.surfaceVariant
    }
    val border = if (isSelected) BorderStroke(2.dp, MaterialTheme.colorScheme.onSecondary) else null

    OutlinedCard(
        onClick = onClick,
        enabled = slot.available,
        border  = border,
        colors  = CardDefaults.outlinedCardColors(containerColor = containerColor),
        modifier = Modifier.aspectRatio(1f)
    ) {
        Column(
            Modifier.fillMaxSize().padding(4.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(slot.startTime.take(5), style = MaterialTheme.typography.labelMedium,
                fontWeight = FontWeight.Bold, textAlign = TextAlign.Center)
            Text(slot.endTime.take(5), style = MaterialTheme.typography.labelSmall,
                textAlign = TextAlign.Center, color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
    }
}

@Composable
private fun LegendItem(color: androidx.compose.ui.graphics.Color, label: String) {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
        Surface(Modifier.size(12.dp), color = color, shape = MaterialTheme.shapes.extraSmall) {}
        Text(label, style = MaterialTheme.typography.labelSmall)
    }
}
