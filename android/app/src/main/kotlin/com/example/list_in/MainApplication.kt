package com.example.list_in
import android.app.Application

import com.yandex.mapkit.MapKitFactory

class MainApplication: Application() {
  override fun onCreate() {
    super.onCreate()
    MapKitFactory.setApiKey("ef81980f-c744-4ab9-91dd-fdd797e0a87c") // Your generated API key
  }
}