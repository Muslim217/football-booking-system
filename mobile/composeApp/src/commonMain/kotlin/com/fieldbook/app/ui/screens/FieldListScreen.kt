package com.fieldbook.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.fieldbook.app.ui.components.*
import com.fieldbook.app.ui.theme.*
import com.fieldbook.app.viewmodel.FieldViewModel
import com.fieldbook.shared.model.Field
import org.koin.compose.viewmodel.koinViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FieldListScreen(
    onFieldClick: (Long) -> Unit,
    onProfileClick: () -> Unit,
    onBookingsClick: () -> Unit,
    viewModel: FieldViewModel = koinViewModel(),
) {
    val uiState   by viewModel.listState.collectAsState()
    val listState = rememberLazyListState()

    val shouldLoadMore by remember {
        derivedStateOf {
            val lastVisible = listState.layoutInfo.visibleItemsInfo.lastOrNull()?.index ?: 0
            lastVisible >= uiState.fields.size - 3 && uiState.hasMore && !uiState.isLoading
        }
    }
    LaunchedEffect(shouldLoadMore) { if (shouldLoadMore) viewModel.loadFields() }

    Scaffold(
        containerColor = ColorBg,
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Stadium", fontWeight = FontWeight.W700, color = ColorText,
                            style = MaterialTheme.typography.titleLarge)
                        Text("Площадки", style = MaterialTheme.typography.bodySmall, color = ColorTextMuted)
                    }
                },
                actions = {
                    TextButton(onClick = onBookingsClick) {
                        Text("Брони", color = ColorPrimary, style = MaterialTheme.typography.labelLarge)
                    }
                    IconButton(onClick = onProfileClick) {
                        Surface(shape = RoundedCornerShape(20.dp), color = ColorPrimarySoft, modifier = Modifier.size(36.dp)) {
                            Box(contentAlignment = Alignment.Center) {
                                Icon(Icons.Default.Person, contentDescription = "Профиль", tint = ColorPrimary,
                                    modifier = Modifier.size(18.dp))
                            }
                        }
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = ColorBg),
            )
        },
    ) { padding ->
        when {
            uiState.isLoading && uiState.fields.isEmpty() -> LoadingBox(Modifier.padding(padding))
            uiState.error != null && uiState.fields.isEmpty() ->
                ErrorBox(uiState.error!!, onRetry = { viewModel.loadFields(refresh = true) })
            else -> {
                LazyColumn(
                    state               = listState,
                    modifier            = Modifier.fillMaxSize().padding(padding),
                    contentPadding      = PaddingValues(horizontal = 16.dp, vertical = 12.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp),
                ) {
                    items(uiState.fields, key = { it.id }) { field ->
                        FieldCard(field = field, onClick = { onFieldClick(field.id) })
                    }
                    if (uiState.isLoading) {
                        item {
                            Box(Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
                                CircularProgressIndicator(
                                    modifier    = Modifier.padding(16.dp).size(24.dp),
                                    color       = ColorPrimary,
                                    strokeWidth = 2.dp,
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
private fun FieldCard(field: Field, onClick: () -> Unit) {
    Surface(
        shape    = RoundedCornerShape(14.dp),
        color    = ColorSurface,
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shadowElevation = 2.dp,
    ) {
        Column {
            // Pitch illustration
            PitchCard(fieldType = field.fieldType, height = 120)

            Column(
                modifier = Modifier.padding(14.dp),
                verticalArrangement = Arrangement.spacedBy(6.dp),
            ) {
                Row(
                    Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment     = Alignment.Top,
                ) {
                    Text(field.name, style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.W700, color = ColorText, modifier = Modifier.weight(1f))
                    Text(
                        "${field.pricePerHour.toInt()} ₽/ч",
                        style     = MaterialTheme.typography.titleSmall,
                        fontWeight = FontWeight.W700,
                        color     = ColorPrimary,
                        modifier  = Modifier.padding(start = 8.dp),
                    )
                }

                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    if (!field.city.isNullOrBlank()) {
                        Text(field.city, style = MaterialTheme.typography.bodySmall, color = ColorTextMuted)
                        Text("·", color = ColorBorder, style = MaterialTheme.typography.bodySmall)
                    }
                    Text(field.address, style = MaterialTheme.typography.bodySmall, color = ColorTextMuted, maxLines = 1)
                }

                // Type chip
                Surface(
                    color = ColorPrimarySoft,
                    shape = RoundedCornerShape(6.dp),
                ) {
                    Text(
                        fieldTypeName(field.fieldType),
                        color    = ColorPrimary,
                        style    = MaterialTheme.typography.labelSmall,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                    )
                }
            }
        }
    }
}
