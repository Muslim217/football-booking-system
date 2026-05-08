package com.fieldbook.app

import com.fieldbook.app.viewmodel.*
import org.koin.core.module.dsl.factoryOf
import org.koin.dsl.module

// На iOS ViewModel создаются как factory (нет ViewModelScope как на Android)
val iosAppModule = module {
    factoryOf(::AuthViewModel)
    factoryOf(::FieldViewModel)
    factoryOf(::BookingViewModel)
    factoryOf(::ProfileViewModel)
}
