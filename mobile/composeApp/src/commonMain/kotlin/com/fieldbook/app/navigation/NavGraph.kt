package com.fieldbook.app.navigation

import androidx.compose.runtime.*
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.*
import androidx.navigation.navArgument
import com.fieldbook.app.ui.screens.*

sealed class Screen(val route: String) {
    data object Login        : Screen("login")
    data object Register     : Screen("register")
    data object FieldList    : Screen("fields")
    data object Profile      : Screen("profile")
    data object FieldDetail  : Screen("field/{fieldId}") {
        fun createRoute(fieldId: Long) = "field/$fieldId"
    }
    data object Schedule     : Screen("schedule/{fieldId}/{date}") {
        fun createRoute(fieldId: Long, date: String) = "schedule/$fieldId/$date"
    }
    data object MyBookings   : Screen("my-bookings")
}

@Composable
fun AppNavGraph(
    navController: NavHostController,
    startDestination: String
) {
    NavHost(navController = navController, startDestination = startDestination) {

        composable(Screen.Login.route) {
            LoginScreen(
                onLoginSuccess   = { navController.navigate(Screen.FieldList.route) { popUpTo(Screen.Login.route) { inclusive = true } } },
                onNavigateToRegister = { navController.navigate(Screen.Register.route) }
            )
        }

        composable(Screen.Register.route) {
            RegisterScreen(
                onRegisterSuccess = { navController.popBackStack() },
                onNavigateToLogin = { navController.popBackStack() }
            )
        }

        composable(Screen.FieldList.route) {
            FieldListScreen(
                onFieldClick   = { fieldId -> navController.navigate(Screen.FieldDetail.createRoute(fieldId)) },
                onProfileClick = { navController.navigate(Screen.Profile.route) },
                onBookingsClick = { navController.navigate(Screen.MyBookings.route) }
            )
        }

        composable(
            route = Screen.FieldDetail.route,
            arguments = listOf(navArgument("fieldId") { type = NavType.LongType })
        ) { backStack ->
            val fieldId = backStack.arguments?.getLong("fieldId") ?: return@composable
            FieldDetailScreen(
                fieldId    = fieldId,
                onBack     = { navController.popBackStack() },
                onSchedule = { date -> navController.navigate(Screen.Schedule.createRoute(fieldId, date)) }
            )
        }

        composable(
            route = Screen.Schedule.route,
            arguments = listOf(
                navArgument("fieldId") { type = NavType.LongType },
                navArgument("date")    { type = NavType.StringType }
            )
        ) { backStack ->
            val fieldId = backStack.arguments?.getLong("fieldId") ?: return@composable
            val date    = backStack.arguments?.getString("date")  ?: return@composable
            ScheduleScreen(
                fieldId  = fieldId,
                date     = date,
                onBack   = { navController.popBackStack() },
                onBooked = { navController.navigate(Screen.MyBookings.route) }
            )
        }

        composable(Screen.MyBookings.route) {
            MyBookingsScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.Profile.route) {
            ProfileScreen(
                onLogout = { navController.navigate(Screen.Login.route) { popUpTo(0) { inclusive = true } } },
                onBack   = { navController.popBackStack() }
            )
        }
    }
}
