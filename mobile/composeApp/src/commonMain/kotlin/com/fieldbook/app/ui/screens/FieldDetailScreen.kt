package com.fieldbook.app.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.fieldbook.app.ui.components.*
import com.fieldbook.app.ui.theme.*
import com.fieldbook.app.viewmodel.FieldViewModel
import kotlinx.datetime.Clock
import kotlinx.datetime.DateTimeUnit
import kotlinx.datetime.TimeZone
import kotlinx.datetime.plus
import kotlinx.datetime.todayIn
import org.koin.compose.viewmodel.koinViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FieldDetailScreen(
    fieldId: Long,
    onBack: () -> Unit,
    onSchedule: (String) -> Unit,
    viewModel: FieldViewModel = koinViewModel(),
) {
    val uiState by viewModel.detailState.collectAsState()
    LaunchedEffect(fieldId) { viewModel.loadField(fieldId) }

    var selectedDate by remember {
        mutableStateOf(Clock.System.todayIn(TimeZone.currentSystemDefault()).toString())
    }

    Scaffold(
        containerColor = ColorBg,
        topBar = {
            TopAppBar(
                title = {
                    Text(uiState.field?.name ?: "Площадка",
                        fontWeight = FontWeight.W700, color = ColorText)
                },
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
            uiState.error != null -> ErrorBox(uiState.error!!)
            uiState.field != null -> {
                val field = uiState.field!!
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding)
                        .verticalScroll(rememberScrollState()),
                ) {
                    // Pitch illustration
                    PitchCard(fieldType = field.fieldType, height = 180)

                    Column(
                        modifier = Modifier.padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(14.dp),
                    ) {
                        // Header
                        Row(
                            Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment     = Alignment.Top,
                        ) {
                            Column(modifier = Modifier.weight(1f)) {
                                Text(field.name, style = MaterialTheme.typography.headlineSmall,
                                    fontWeight = FontWeight.W700, color = ColorText)
                                if (!field.city.isNullOrBlank()) {
                                    Text(field.city, style = MaterialTheme.typography.bodySmall, color = ColorTextMuted)
                                }
                                Text(field.address, style = MaterialTheme.typography.bodySmall, color = ColorTextMuted)
                            }
                            Surface(
                                color = ColorPrimarySoft,
                                shape = RoundedCornerShape(10.dp),
                            ) {
                                Column(
                                    modifier = Modifier.padding(horizontal = 14.dp, vertical = 10.dp),
                                    horizontalAlignment = Alignment.CenterHorizontally,
                                ) {
                                    Text(
                                        "${field.pricePerHour.toInt()} ₽",
                                        style     = MaterialTheme.typography.titleLarge,
                                        fontWeight = FontWeight.W700,
                                        color     = ColorPrimary,
                                    )
                                    Text("за час", style = MaterialTheme.typography.bodySmall, color = ColorTextMuted)
                                }
                            }
                        }

                        // Type chip
                        Surface(color = ColorPrimarySoft, shape = RoundedCornerShape(6.dp)) {
                            Text(fieldTypeName(field.fieldType), color = ColorPrimary,
                                style = MaterialTheme.typography.labelMedium,
                                modifier = Modifier.padding(horizontal = 10.dp, vertical = 5.dp))
                        }

                        // Description
                        if (!field.description.isNullOrBlank()) {
                            Surface(color = ColorSurface, shape = RoundedCornerShape(14.dp), shadowElevation = 1.dp) {
                                Column(Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                                    Text("Описание", style = MaterialTheme.typography.labelLarge,
                                        fontWeight = FontWeight.W600, color = ColorTextMuted)
                                    Text(field.description, style = MaterialTheme.typography.bodyMedium, color = ColorText)
                                }
                            }
                        }

                        HorizontalDivider(color = ColorBorder)

                        // Date picker
                        Text("Выберите дату", style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.W700, color = ColorText)

                        val today = Clock.System.todayIn(TimeZone.currentSystemDefault())
                        val dates = (0..6).map { today.plus(it, DateTimeUnit.DAY) }

                        LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            items(dates.size) { i ->
                                val date    = dates[i]
                                val dateStr = date.toString()
                                val isSelected = selectedDate == dateStr
                                Surface(
                                    color  = if (isSelected) ColorPrimary else ColorSurface,
                                    shape  = RoundedCornerShape(10.dp),
                                    shadowElevation = if (isSelected) 0.dp else 1.dp,
                                    onClick = { selectedDate = dateStr },
                                ) {
                                    Column(
                                        modifier = Modifier.padding(horizontal = 14.dp, vertical = 10.dp),
                                        horizontalAlignment = Alignment.CenterHorizontally,
                                    ) {
                                        Text(
                                            "${date.dayOfMonth}",
                                            style     = MaterialTheme.typography.titleMedium,
                                            fontWeight = FontWeight.W700,
                                            color     = if (isSelected) ColorTextInverse else ColorText,
                                        )
                                        Text(
                                            monthShort(date.month.name),
                                            style = MaterialTheme.typography.bodySmall,
                                            color = if (isSelected) ColorTextInverse.copy(alpha = 0.8f) else ColorTextMuted,
                                        )
                                    }
                                }
                            }
                        }

                        StadiumButton(
                            text    = "Смотреть расписание",
                            onClick = { onSchedule(selectedDate) },
                        )
                        Spacer(Modifier.height(8.dp))
                    }
                }
            }
        }
    }
}

private fun monthShort(name: String) = when (name) {
    "JANUARY" -> "янв"; "FEBRUARY" -> "фев"; "MARCH"    -> "мар"
    "APRIL"   -> "апр"; "MAY"      -> "май"; "JUNE"     -> "июн"
    "JULY"    -> "июл"; "AUGUST"   -> "авг"; "SEPTEMBER" -> "сен"
    "OCTOBER" -> "окт"; "NOVEMBER" -> "ноя"; "DECEMBER"  -> "дек"
    else      -> name.take(3)
}
