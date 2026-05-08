package com.fieldbook.app.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp

@Composable
fun LoadingBox(modifier: Modifier = Modifier) {
    Box(modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        CircularProgressIndicator()
    }
}

@Composable
fun ErrorBox(message: String, onRetry: (() -> Unit)? = null) {
    Column(
        Modifier.fillMaxSize().padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(message, style = MaterialTheme.typography.bodyLarge, textAlign = TextAlign.Center,
            color = MaterialTheme.colorScheme.error)
        if (onRetry != null) {
            Spacer(Modifier.height(16.dp))
            Button(onClick = onRetry) { Text("Повторить") }
        }
    }
}

@Composable
fun FieldBookingButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    loading: Boolean = false
) {
    Button(
        onClick  = onClick,
        modifier = modifier.fillMaxWidth().height(52.dp),
        enabled  = enabled && !loading
    ) {
        if (loading) {
            CircularProgressIndicator(Modifier.size(20.dp), color = MaterialTheme.colorScheme.onPrimary, strokeWidth = 2.dp)
        } else {
            Text(text, style = MaterialTheme.typography.labelLarge)
        }
    }
}

@Composable
fun FieldBookingTextField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    modifier: Modifier = Modifier,
    isPassword: Boolean = false,
    isError: Boolean = false,
    errorMessage: String? = null
) {
    Column(modifier) {
        OutlinedTextField(
            value         = value,
            onValueChange = onValueChange,
            label         = { Text(label) },
            modifier      = Modifier.fillMaxWidth(),
            isError       = isError,
            singleLine    = true,
            visualTransformation = if (isPassword)
                androidx.compose.ui.text.input.PasswordVisualTransformation()
            else
                androidx.compose.ui.text.input.VisualTransformation.None
        )
        if (isError && errorMessage != null) {
            Text(errorMessage, color = MaterialTheme.colorScheme.error,
                style = MaterialTheme.typography.bodySmall, modifier = Modifier.padding(start = 16.dp, top = 4.dp))
        }
    }
}

@Composable
fun StatusChip(status: String) {
    val (containerColor, textColor, label) = when (status) {
        "CONFIRMED" -> Triple(MaterialTheme.colorScheme.primaryContainer, MaterialTheme.colorScheme.onPrimaryContainer, "Подтверждено")
        "CANCELLED" -> Triple(MaterialTheme.colorScheme.errorContainer,   MaterialTheme.colorScheme.onErrorContainer,   "Отменено")
        "COMPLETED" -> Triple(MaterialTheme.colorScheme.surfaceVariant,    MaterialTheme.colorScheme.onSurfaceVariant,    "Завершено")
        else        -> Triple(MaterialTheme.colorScheme.surfaceVariant,    MaterialTheme.colorScheme.onSurfaceVariant,    "Ожидание")
    }
    Surface(color = containerColor, shape = MaterialTheme.shapes.small) {
        Text(label, color = textColor, style = MaterialTheme.typography.labelSmall,
            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp))
    }
}
