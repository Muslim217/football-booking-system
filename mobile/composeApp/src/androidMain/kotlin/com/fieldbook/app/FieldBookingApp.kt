package com.fieldbook.app

import android.app.Application
import android.content.Context
import androidx.datastore.preferences.preferencesDataStore
import com.fieldbook.app.di.appModule
import com.fieldbook.shared.di.networkModule
import com.fieldbook.shared.di.repositoryModule
import com.fieldbook.shared.storage.DataStoreTokenStorage
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin

// DataStore через extension property
val Context.dataStore by preferencesDataStore(name = "field_booking_prefs")

class FieldBookingApp : Application() {

    override fun onCreate() {
        super.onCreate()

        val tokenStorage = DataStoreTokenStorage(applicationContext.dataStore)

        startKoin {
            androidContext(this@FieldBookingApp)
            modules(
                networkModule(tokenStorage),
                repositoryModule,
                appModule
            )
        }
    }
}
