package com.fieldbook.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.fieldbook.app.ui.components.ErrorBox
import com.fieldbook.app.ui.components.LoadingBox
import com.fieldbook.app.ui.components.StadiumButton
import com.fieldbook.app.ui.theme.*
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
    fieldViewModel: FieldViewModel     = koinViewModel(),
    bookingViewModel: BookingViewModel = koinViewModel(),
) {
    val scheduleState by fieldViewModel.scheduleState.collectAsState()
    val bookingState  by bookingViewModel.uiState.collectAsState()

    LaunchedEffect(fieldId, date) { fieldViewModel.loadSchedule(fieldId, date) }
    LaunchedEffect(bookingState.bookingSuccess) {
        if (bookingState.bookingSuccess) { bookingViewModel.resetSuccess(); onBooked() }
    }

    Scaffold(
        containerColor = ColorBg,
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Расписание", fontWeight = FontWeight.W700, color = ColorText,
                            style = MaterialTheme.typography.titleLarge)
                        Text(date, style = MaterialTheme.typography.bodySmall, color = ColorTextMuted)
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Назад", tint = ColorText)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = ColorBg),
            )
        },
        bottomBar = {
            val selected = scheduleState.selectedSlot
            if (selected != null) {
                Surface(color = ColorSurface, shadowElevation = 8.dp) {
                    Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        Row(
                            Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment     = Alignment.CenterVertically,
                        ) {
                            Column {
                                Text("Выбранный слот", style = MaterialTheme.typography.labelSmall, color = ColorTextMuted)
                                Text(
                                    "${selected.startTime.take(5)} – ${selected.endTime.take(5)}",
                                    style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.W700, color = ColorText,
                                )
                            }
                            Surface(color = ColorPrimarySoft, shape = RoundedCornerShape(8.dp)) {
                                Text(
                                    "${selected.price.toInt()} ₽",
                                    color    = ColorPrimary,
                                    style    = MaterialTheme.typography.titleMedium,
                                    fontWeight = FontWeight.W700,
                                    modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                                )
                            }
                        }

                        bookingState.error?.let { err ->
                            Text(err, color = ColorDanger, style = MaterialTheme.typography.bodySmall)
                        }

                        StadiumButton(
                            text    = "Забронировать",
                            onClick = {
                                val slot = scheduleState.selectedSlot ?: return@StadiumButton
                                bookingViewModel.createBooking(
                                    fieldId   = fieldId,
                                    startTime = "${date}T${slot.startTime}",
                                    endTime   = "${date}T${slot.endTime}",
                                )
                            },
                            loading = bookingState.isLoading,
                        )
                    }
                }
            }
        },
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding)) {
            when {
                scheduleState.isLoading -> LoadingBox()
                scheduleState.error != null -> ErrorBox(scheduleState.error!!)
                else -> {
                    // Legend
                    Row(
                        Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 10.dp),
                        horizontalArrangement = Arrangement.spacedBy(16.dp),
                    ) {
                        LegendItem(color = ColorSlotAvailable, textColor = ColorPrimary, label = "Свободно")
                        LegendItem(color = ColorAccent.copy(alpha = 0.3f), textColor = ColorAccentDark, label = "Выбрано")
                        LegendItem(color = ColorSlotBooked, textColor = ColorTextMuted, label = "Занято")
                    }

                    if (scheduleState.slots.isEmpty()) {
                        Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                            Text("Нет доступных слотов", color = ColorTextMuted,
                                style = MaterialTheme.typography.bodyMedium)
                        }
                    } else {
                        LazyVerticalGrid(
                            columns               = GridCells.Fixed(3),
                            modifier              = Modifier.fillMaxSize().padding(horizontal = 12.dp),
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                            verticalArrangement   = Arrangement.spacedBy(8.dp),
                            contentPadding        = PaddingValues(bottom = 16.dp, top = 4.dp),
                        ) {
                            items(scheduleState.slots) { slot ->
                                SlotItem(
                                    slot       = slot,
                                    isSelected = scheduleState.selectedSlot == slot,
                                    onClick    = { if (slot.available) fieldViewModel.selectSlot(slot) },
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun SlotItem(slot: TimeSlot, isSelected: Boolean, onClick: () -> Unit) {
    val bg = when {
        isSelected     -> ColorAccent.copy(alpha = 0.25f)
        slot.available -> ColorSlotAvailable
        else           -> ColorSlotBooked
    }
    val textColor = when {
        isSelected     -> ColorAccentDark
        slot.available -> ColorPrimary
        else           -> ColorTextMuted
    }

    Box(
        modifier = Modifier
            .aspectRatio(1f)
            .clip(RoundedCornerShape(10.dp))
            .background(bg)
            .then(
                if (isSelected) Modifier.border(2.dp, ColorAccent, RoundedCornerShape(10.dp))
                else Modifier
            )
            .clickable(enabled = slot.available, onClick = onClick),
        contentAlignment = Alignment.Center,
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                slot.startTime.take(5),
                style     = MaterialTheme.typography.labelLarge,
                fontWeight = FontWeight.W700,
                color     = textColor,
                textAlign = TextAlign.Center,
            )
            Text(
                slot.endTime.take(5),
                style    = MaterialTheme.typography.labelSmall,
                color    = textColor.copy(alpha = 0.7f),
                textAlign = TextAlign.Center,
            )
        }
    }
}

@Composable
private fun LegendItem(color: androidx.compose.ui.graphics.Color, textColor: androidx.compose.ui.graphics.Color, label: String) {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(5.dp)) {
        Box(Modifier.size(12.dp).clip(RoundedCornerShape(3.dp)).background(color))
        Text(label, style = MaterialTheme.typography.labelSmall, color = ColorTextMuted)
    }
}
