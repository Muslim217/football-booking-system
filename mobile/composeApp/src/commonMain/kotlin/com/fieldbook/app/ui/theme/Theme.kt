package com.fieldbook.app.ui.theme

import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

// ─── Stadium Calm — Color Tokens ─────────────────────────────────────────────
// Primary: football green
val ColorPrimary        = Color(0xFF1B6B2E)
val ColorPrimaryDark    = Color(0xFF145522)
val ColorPrimaryLight   = Color(0xFF2E8B46)
val ColorPrimarySoft    = Color(0xFFE8F5EC)
// Accent: amber (selected slot / prices)
val ColorAccent         = Color(0xFFF6B73C)
val ColorAccentDark     = Color(0xFFD4940A)
// Backgrounds
val ColorBg             = Color(0xFFF6F7F2)
val ColorSurface        = Color(0xFFFFFFFF)
val ColorSurfaceElevated= Color(0xFFFBFCF9)
// Text
val ColorText           = Color(0xFF172117)
val ColorTextMuted      = Color(0xFF667263)
val ColorTextInverse    = Color(0xFFFFFFFF)
// Utility
val ColorBorder         = Color(0xFFE4E7E1)
val ColorDanger         = Color(0xFFDC2626)
val ColorDangerSoft     = Color(0xFFFEE2E2)
val ColorWarning        = Color(0xFFD97706)
val ColorWarningSoft    = Color(0xFFFEF3C7)
val ColorInfo           = Color(0xFF2563EB)
val ColorInfoSoft       = Color(0xFFDBEAFE)
// Slot states
val ColorSlotAvailable  = Color(0xFFE8F5EC)
val ColorSlotSelected   = Color(0xFFF6B73C)
val ColorSlotBooked     = Color(0xFFF1F2EE)
val ColorSlotPast       = Color(0xFFF8F9F6)

// ─── Light Color Scheme ───────────────────────────────────────────────────────
private val LightColorScheme = lightColorScheme(
    primary              = ColorPrimary,
    onPrimary            = ColorTextInverse,
    primaryContainer     = ColorPrimarySoft,
    onPrimaryContainer   = ColorPrimaryDark,
    secondary            = ColorAccent,
    onSecondary          = ColorText,
    secondaryContainer   = Color(0xFFFFF8E8),
    onSecondaryContainer = ColorAccentDark,
    tertiary             = ColorInfo,
    onTertiary           = ColorTextInverse,
    background           = ColorBg,
    onBackground         = ColorText,
    surface              = ColorSurface,
    onSurface            = ColorText,
    surfaceVariant       = ColorSurfaceElevated,
    onSurfaceVariant     = ColorTextMuted,
    outline              = ColorBorder,
    error                = ColorDanger,
    onError              = ColorTextInverse,
    errorContainer       = ColorDangerSoft,
    onErrorContainer     = ColorDanger,
)

// ─── Typography ───────────────────────────────────────────────────────────────
// Satoshi / General Sans not available via Android font assets by default —
// using system default with matching weight/size scale
private val StadiumTypography = Typography(
    displayLarge = TextStyle(fontWeight = FontWeight.W700, fontSize = 32.sp, lineHeight = 38.sp),
    displayMedium = TextStyle(fontWeight = FontWeight.W700, fontSize = 26.sp, lineHeight = 32.sp),
    displaySmall = TextStyle(fontWeight = FontWeight.W700, fontSize = 22.sp, lineHeight = 28.sp),
    headlineLarge = TextStyle(fontWeight = FontWeight.W700, fontSize = 20.sp, lineHeight = 26.sp),
    headlineMedium = TextStyle(fontWeight = FontWeight.W600, fontSize = 18.sp, lineHeight = 24.sp),
    headlineSmall = TextStyle(fontWeight = FontWeight.W600, fontSize = 16.sp, lineHeight = 22.sp),
    titleLarge = TextStyle(fontWeight = FontWeight.W600, fontSize = 15.sp, lineHeight = 22.sp),
    titleMedium = TextStyle(fontWeight = FontWeight.W600, fontSize = 14.sp, lineHeight = 20.sp),
    titleSmall = TextStyle(fontWeight = FontWeight.W500, fontSize = 13.sp, lineHeight = 18.sp),
    bodyLarge = TextStyle(fontWeight = FontWeight.W400, fontSize = 15.sp, lineHeight = 22.sp),
    bodyMedium = TextStyle(fontWeight = FontWeight.W400, fontSize = 13.sp, lineHeight = 20.sp),
    bodySmall = TextStyle(fontWeight = FontWeight.W400, fontSize = 12.sp, lineHeight = 16.sp),
    labelLarge = TextStyle(fontWeight = FontWeight.W500, fontSize = 13.sp, lineHeight = 18.sp),
    labelMedium = TextStyle(fontWeight = FontWeight.W500, fontSize = 12.sp, lineHeight = 16.sp),
    labelSmall = TextStyle(fontWeight = FontWeight.W500, fontSize = 11.sp, lineHeight = 14.sp),
)

// ─── Theme ────────────────────────────────────────────────────────────────────
@Composable
fun FieldBookingTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = LightColorScheme,
        typography  = StadiumTypography,
        content     = content,
    )
}
