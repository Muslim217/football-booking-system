package com.fieldbook.app.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import com.fieldbook.app.ui.components.LoadingBox
import com.fieldbook.app.ui.components.ErrorBox
import com.fieldbook.app.viewmodel.FieldViewModel
import com.fieldbook.shared.model.Field
import org.koin.compose.viewmodel.koinViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FieldListScreen(
    onFieldClick: (Long) -> Unit,
    onProfileClick: () -> Unit,
    onBookingsClick: () -> Unit,
    viewModel: FieldViewModel = koinViewModel()
) {
    val uiState by viewModel.listState.collectAsState()
    val listState = rememberLazyListState()

    // Подгрузка следующей страницы при достижении конца
    val shouldLoadMore by remember {
        derivedStateOf {
            val lastVisible = listState.layoutInfo.visibleItemsInfo.lastOrNull()?.index ?: 0
            lastVisible >= uiState.fields.size - 3 && uiState.hasMore && !uiState.isLoading
        }
    }
    LaunchedEffect(shouldLoadMore) {
        if (shouldLoadMore) viewModel.loadFields()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Площадки", fontWeight = FontWeight.Bold) },
                actions = {
                    TextButton(onClick = onBookingsClick) { Text("Мои брони") }
                    IconButton(onClick = onProfileClick) {
                        Icon(Icons.Default.Person, contentDescription = "Профиль")
                    }
                }
            )
        }
    ) { padding ->
        when {
            uiState.isLoading && uiState.fields.isEmpty() -> LoadingBox(Modifier.padding(padding))
            uiState.error != null && uiState.fields.isEmpty() ->
                ErrorBox(uiState.error!!, onRetry = { viewModel.loadFields(refresh = true) })
            else -> {
                LazyColumn(
                    state           = listState,
                    modifier        = Modifier.fillMaxSize().padding(padding),
                    contentPadding  = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(uiState.fields, key = { it.id }) { field ->
                        FieldCard(field = field, onClick = { onFieldClick(field.id) })
                    }
                    if (uiState.isLoading) {
                        item {
                            Box(Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
                                CircularProgressIndicator(Modifier.padding(16.dp))
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
    Card(
        modifier  = Modifier.fillMaxWidth().clickable(onClick = onClick),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column {
            // Фото площадки
            if (!field.photoUrl.isNullOrBlank()) {
                AsyncImage(
                    model             = field.photoUrl,
                    contentDescription = field.name,
                    modifier          = Modifier.fillMaxWidth().height(160.dp),
                    contentScale      = ContentScale.Crop
                )
            } else {
                Surface(
                    modifier = Modifier.fillMaxWidth().height(100.dp),
                    color    = MaterialTheme.colorScheme.primaryContainer
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Text(fieldTypeEmoji(field.fieldType),
                            style = MaterialTheme.typography.displaySmall)
                    }
                }
            }

            Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(field.name,  style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
                Text(field.address, style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant, maxLines = 1)
                Row(
                    Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment     = Alignment.CenterVertically
                ) {
                    AssistChip(
                        onClick = {},
                        label   = { Text(fieldTypeLabel(field.fieldType), style = MaterialTheme.typography.labelSmall) }
                    )
                    Text(
                        "${field.pricePerHour.toInt()} ₽/час",
                        style     = MaterialTheme.typography.titleSmall,
                        fontWeight = FontWeight.Bold,
                        color     = MaterialTheme.colorScheme.primary
                    )
                }
            }
        }
    }
}

private fun fieldTypeEmoji(type: String) = when (type) {
    "FOOTBALL"   -> "⚽"
    "BASKETBALL" -> "🏀"
    "VOLLEYBALL" -> "🏐"
    "TENNIS"     -> "🎾"
    "PADEL"      -> "🏓"
    "HOCKEY"     -> "🏒"
    else         -> "🏟️"
}

private fun fieldTypeLabel(type: String) = when (type) {
    "FOOTBALL"   -> "Футбол"
    "BASKETBALL" -> "Баскетбол"
    "VOLLEYBALL" -> "Волейбол"
    "TENNIS"     -> "Теннис"
    "PADEL"      -> "Падел"
    "HOCKEY"     -> "Хоккей"
    "INDOOR"     -> "Крытый"
    "OUTDOOR"    -> "Открытый"
    else         -> type
}
