package com.fieldbook.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.*
import androidx.navigation.compose.rememberNavController
import com.fieldbook.app.navigation.AppNavGraph
import com.fieldbook.app.navigation.Screen
import com.fieldbook.app.ui.theme.FieldBookingTheme
import com.fieldbook.shared.repository.AuthRepository
import kotlinx.coroutines.runBlocking
import org.koin.android.ext.android.inject

class MainActivity : ComponentActivity() {

    private val authRepository: AuthRepository by inject()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Определяем стартовый экран по наличию токена
        val startDestination = if (runBlocking { authRepository.isLoggedIn() }) {
            Screen.FieldList.route
        } else {
            Screen.Login.route
        }

        setContent {
            FieldBookingTheme {
                val navController = rememberNavController()
                AppNavGraph(navController = navController, startDestination = startDestination)
            }
        }
    }
}
