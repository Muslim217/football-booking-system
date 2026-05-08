package com.fieldbook.app

import androidx.compose.runtime.remember
import androidx.compose.ui.window.ComposeUIViewController
import androidx.navigation.compose.rememberNavController
import com.fieldbook.app.navigation.AppNavGraph
import com.fieldbook.app.navigation.Screen
import com.fieldbook.app.ui.theme.FieldBookingTheme
import com.fieldbook.shared.di.repositoryModule
import com.fieldbook.shared.repository.AuthRepository
import com.fieldbook.shared.storage.NSUserDefaultsTokenStorage
import kotlinx.coroutines.runBlocking
import org.koin.compose.getKoin
import org.koin.core.context.startKoin

fun MainViewController() = ComposeUIViewController {
    FieldBookingTheme {
        val koin = getKoin()
        val authRepository = koin.get<AuthRepository>()
        val startDestination = remember {
            if (runBlocking { authRepository.isLoggedIn() }) Screen.FieldList.route
            else Screen.Login.route
        }
        val navController = rememberNavController()
        AppNavGraph(navController = navController, startDestination = startDestination)
    }
}

fun initKoin() {
    val tokenStorage = NSUserDefaultsTokenStorage()
    startKoin {
        modules(
            com.fieldbook.shared.di.networkModule(tokenStorage),
            repositoryModule,
            iosAppModule
        )
    }
}
