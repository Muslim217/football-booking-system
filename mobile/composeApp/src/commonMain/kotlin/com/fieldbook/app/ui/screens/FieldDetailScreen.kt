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
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import com.fieldbook.app.ui.components.ErrorBox
import com.fieldbook.app.ui.components.LoadingBox
import com.fieldbook.app.viewmodel.FieldViewModel
import kotlinx.datetime.Clock
import kotlinx.datetime.TimeZone
import kotlinx.datetime.todayIn
import org.koin.compose.viewmodel.koinViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FieldDetailScreen(
    fieldId: Long,
    onBack: () -> Unit,
    onSchedule: (String) -> Unit,
    viewModel: FieldViewModel = koinViewModel()
) {
    val uiState by viewModel.detailState.collectAsState()

    LaunchedEffect(fieldId) { viewModel.loadField(fieldId) }

    // Выбор даты
    var selectedDate by remember {
        mutableStateOf(
            Clock.System.todayIn(TimeZone.currentSystemDefault()).toString()
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(uiState.field?.name ?: "Площадка") },
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
            uiState.error != null -> ErrorBox(uiState.error!!)
            uiState.field != null -> {
                val field = uiState.field!!
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding)
                        .verticalScroll(rememberScrollState())
                ) {
                    // Фото
                    if (!field.photoUrl.isNullOrBlank()) {
                        AsyncImage(
                            model              = field.photoUrl,
                            contentDescription = field.name,
                            modifier           = Modifier.fillMaxWidth().height(220.dp),
                            contentScale       = ContentScale.Crop
                        )
                    }

                    Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        // Основная информация
                        Text(field.name, style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
                        Text(field.address, style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant)

                        // Цена
                        Card(colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer)) {
                            Row(
                                Modifier.fillMaxWidth().padding(16.dp),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment     = Alignment.CenterVertically
                            ) {
                                Text("Цена за час", style = MaterialTheme.typography.bodyMedium)
                                Text(
                                    "${field.pricePerHour.toInt()} ₽",
                                    style      = MaterialTheme.typography.titleLarge,
                                    fontWeight = FontWeight.Bold,
                                    color      = MaterialTheme.colorScheme.primary
                                )
                            }
                        }

                        // Описание
                        if (!field.description.isNullOrBlank()) {
                            Text("Описание", style = MaterialTheme.typography.titleSmall, fontWeight = FontWeight.Bold)
                            Text(field.description, style = MaterialTheme.typography.bodyMedium)
                        }

                        HorizontalDivider()

                        // Выбор даты для бронирования
                        Text("Забронировать", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)

                        // Простой выбор даты (±7 дней)
                        val today = Clock.System.todayIn(TimeZone.currentSystemDefault())
                        val dates = (0..6).map { today.plus(it, kotlinx.datetime.DateTimeUnit.DAY) }

                        androidx.compose.foundation.lazy.LazyRow(
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            items(dates.size) { i ->
                                val date = dates[i]
                                val dateStr = date.toString()
                                FilterChip(
                                    selected = selectedDate == dateStr,
                                    onClick  = { selectedDate = dateStr },
                                    label    = { Text("${date.dayOfMonth} ${monthShort(date.month.name)}") }
                                )
                            }
                        }

                        Button(
                            onClick  = { onSchedule(selectedDate) },
                            modifier = Modifier.fillMaxWidth().height(52.dp)
                        ) {
                            Text("Смотреть расписание на $selectedDate")
                        }
                    }
                }
            }
        }
    }
}

private fun monthShort(name: String) = when (name) {
    "JANUARY" -> "янв"; "FEBRUARY" -> "фев"; "MARCH"  -> "мар"
    "APRIL"   -> "апр"; "MAY"      -> "май"; "JUNE"   -> "июн"
    "JULY"    -> "июл"; "AUGUST"   -> "авг"; "SEPTEMBER" -> "сен"
    "OCTOBER" -> "окт"; "NOVEMBER" -> "ноя"; "DECEMBER"  -> "дек"
    else      -> name.take(3)
}
