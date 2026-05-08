package com.fieldbook.app.di

import com.fieldbook.app.viewmodel.*
import org.koin.core.module.dsl.viewModelOf
import org.koin.dsl.module

val appModule = module {
    viewModelOf(::AuthViewModel)
    viewModelOf(::FieldViewModel)
    viewModelOf(::BookingViewModel)
    viewModelOf(::ProfileViewModel)
}
