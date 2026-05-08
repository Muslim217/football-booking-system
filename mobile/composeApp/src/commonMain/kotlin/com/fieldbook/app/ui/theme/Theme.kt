package com.fieldbook.app.ui.theme

import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

// ─── Цветовая палитра ─────────────────────────────────────────────────────────
val Green600  = Color(0xFF2E7D32)
val Green400  = Color(0xFF4CAF50)
val Green100  = Color(0xFFC8E6C9)
val Amber500  = Color(0xFFFFC107)
val Gray50    = Color(0xFFFAFAFA)
val Gray200   = Color(0xFFEEEEEE)
val Gray700   = Color(0xFF616161)
val ErrorRed  = Color(0xFFD32F2F)

private val LightColorScheme = lightColorScheme(
    primary         = Green600,
    onPrimary       = Color.White,
    primaryContainer = Green100,
    onPrimaryContainer = Green600,
    secondary       = Amber500,
    onSecondary     = Color.Black,
    background      = Gray50,
    onBackground    = Color(0xFF1C1B1F),
    surface         = Color.White,
    onSurface       = Color(0xFF1C1B1F),
    surfaceVariant  = Gray200,
    error           = ErrorRed,
    onError         = Color.White,
)

@Composable
fun FieldBookingTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = LightColorScheme,
        typography  = Typography(),
        content     = content
    )
}
