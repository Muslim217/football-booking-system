package com.fieldbook.shared.di

import com.fieldbook.shared.api.*
import com.fieldbook.shared.repository.*
import com.fieldbook.shared.storage.TokenStorage
import org.koin.core.module.Module
import org.koin.dsl.module

/**
 * BASE_URL меняй под своё окружение:
 *  - локальная разработка Android эмулятор: http://10.0.2.2:8080
 *  - реальное устройство в сети: http://192.168.x.x:8080
 *  - прод: https://api.yourdomain.com
 */
const val BASE_URL = "http://10.0.2.2:8080"

fun networkModule(tokenStorage: TokenStorage): Module = module {
    single { createHttpClient(tokenStorage, BASE_URL) }
    single { AuthApi(get()) }
    single { FieldApi(get()) }
    single { BookingApi(get()) }
    single { UserApi(get()) }
}

val repositoryModule = module {
    single { AuthRepository(get(), get()) }
    single { FieldRepository(get()) }
    single { BookingRepository(get()) }
    single { UserRepository(get()) }
}
