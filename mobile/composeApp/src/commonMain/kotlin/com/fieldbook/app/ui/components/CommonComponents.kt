package com.fieldbook.app.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.fieldbook.app.ui.theme.*

// ─── Loading / Error ─────────────────────────────────────────────────────────

@Composable
fun LoadingBox(modifier: Modifier = Modifier) {
    Box(modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        CircularProgressIndicator(color = ColorPrimary, strokeWidth = 2.5.dp)
    }
}

@Composable
fun ErrorBox(message: String, onRetry: (() -> Unit)? = null) {
    Column(
        Modifier.fillMaxSize().padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Surface(
            color = ColorDangerSoft,
            shape = RoundedCornerShape(14.dp),
        ) {
            Text(
                message,
                style     = MaterialTheme.typography.bodyMedium,
                textAlign = TextAlign.Center,
                color     = ColorDanger,
                modifier  = Modifier.padding(16.dp),
            )
        }
        if (onRetry != null) {
            Spacer(Modifier.height(16.dp))
            StadiumButton(text = "Повторить", onClick = onRetry)
        }
    }
}

// ─── Primary Button ───────────────────────────────────────────────────────────

@Composable
fun StadiumButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    loading: Boolean = false,
) {
    Button(
        onClick  = onClick,
        modifier = modifier
            .fillMaxWidth()
            .height(52.dp),
        enabled  = enabled && !loading,
        shape    = RoundedCornerShape(14.dp),
        colors   = ButtonDefaults.buttonColors(
            containerColor         = ColorPrimary,
            contentColor           = ColorTextInverse,
            disabledContainerColor = ColorBorder,
            disabledContentColor   = ColorTextMuted,
        ),
    ) {
        if (loading) {
            CircularProgressIndicator(
                modifier    = Modifier.size(20.dp),
                color       = ColorTextInverse,
                strokeWidth = 2.dp,
            )
        } else {
            Text(text, style = MaterialTheme.typography.titleMedium)
        }
    }
}

// Legacy alias
@Composable
fun FieldBookingButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    loading: Boolean = false,
) = StadiumButton(text, onClick, modifier, enabled, loading)

// ─── Text Field ───────────────────────────────────────────────────────────────

@Composable
fun StadiumTextField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    modifier: Modifier = Modifier,
    isPassword: Boolean = false,
    isError: Boolean = false,
    errorMessage: String? = null,
    placeholder: String = "",
) {
    Column(modifier) {
        OutlinedTextField(
            value         = value,
            onValueChange = onValueChange,
            label         = { Text(label, style = MaterialTheme.typography.bodyMedium) },
            placeholder   = if (placeholder.isNotEmpty()) {{ Text(placeholder, color = ColorTextMuted) }} else null,
            modifier      = Modifier.fillMaxWidth(),
            isError       = isError,
            singleLine    = true,
            shape         = RoundedCornerShape(10.dp),
            colors        = OutlinedTextFieldDefaults.colors(
                focusedBorderColor   = ColorPrimary,
                unfocusedBorderColor = ColorBorder,
                focusedLabelColor    = ColorPrimary,
                unfocusedLabelColor  = ColorTextMuted,
                errorBorderColor     = ColorDanger,
                errorLabelColor      = ColorDanger,
            ),
            visualTransformation = if (isPassword) PasswordVisualTransformation()
                                   else            VisualTransformation.None,
        )
        if (isError && !errorMessage.isNullOrEmpty()) {
            Text(
                errorMessage,
                color    = ColorDanger,
                style    = MaterialTheme.typography.bodySmall,
                modifier = Modifier.padding(start = 12.dp, top = 4.dp),
            )
        }
    }
}

// Legacy alias
@Composable
fun FieldBookingTextField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    modifier: Modifier = Modifier,
    isPassword: Boolean = false,
    isError: Boolean = false,
    errorMessage: String? = null,
) = StadiumTextField(value, onValueChange, label, modifier, isPassword, isError, errorMessage)

// ─── Status Badge ─────────────────────────────────────────────────────────────

@Composable
fun StatusChip(status: String) {
    val (bg, fg, label) = when (status.uppercase()) {
        "CONFIRMED" -> Triple(ColorPrimarySoft,    ColorPrimary,  "Подтверждено")
        "CANCELLED" -> Triple(ColorDangerSoft,     ColorDanger,   "Отменено")
        "COMPLETED" -> Triple(ColorBorder,         ColorTextMuted,"Завершено")
        "PENDING"   -> Triple(ColorWarningSoft,    ColorWarning,  "Ожидание")
        else        -> Triple(ColorBorder,         ColorTextMuted, status)
    }
    Surface(
        color = bg,
        shape = RoundedCornerShape(6.dp),
    ) {
        Text(
            label,
            color    = fg,
            style    = MaterialTheme.typography.labelSmall,
            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
        )
    }
}

// ─── Pitch Illustration ───────────────────────────────────────────────────────

@Composable
fun PitchCard(
    fieldType: String,
    modifier: Modifier = Modifier,
    height: Int = 140,
) {
    val gradient = when (fieldType.uppercase()) {
        "BASKETBALL" -> Brush.linearGradient(listOf(Color(0xFFC0722A), Color(0xFF9C5A1C)))
        "TENNIS"     -> Brush.linearGradient(listOf(Color(0xFF2563A8), Color(0xFF1A4A8A)))
        "VOLLEYBALL" -> Brush.linearGradient(listOf(Color(0xFFD97706), Color(0xFFB45309)))
        else         -> Brush.linearGradient(listOf(Color(0xFF1B6B2E), Color(0xFF0F3D18)))
    }
    Box(
        modifier
            .fillMaxWidth()
            .height(height.dp)
            .clip(RoundedCornerShape(topStart = 14.dp, topEnd = 14.dp))
            .background(gradient),
        contentAlignment = Alignment.Center,
    ) {
        // Centre circle
        Box(
            Modifier
                .size(56.dp)
                .clip(RoundedCornerShape(28.dp))
                .background(Color.Transparent),
        )
        // Centre line (horizontal)
        Box(
            Modifier
                .fillMaxWidth()
                .height(1.5.dp)
                .background(Color.White.copy(alpha = 0.18f)),
        )
    }
}

// ─── Field Type Label ─────────────────────────────────────────────────────────

fun fieldTypeName(type: String): String = when (type.uppercase()) {
    "FOOTBALL"   -> "Футбол"
    "BASKETBALL" -> "Баскетбол"
    "VOLLEYBALL" -> "Волейбол"
    "TENNIS"     -> "Теннис"
    "PADEL"      -> "Падел"
    "HOCKEY"     -> "Хоккей"
    else         -> type
}
