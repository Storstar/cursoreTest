package com.example.shopapp.utils

import android.content.Context
import android.telephony.TelephonyManager
import android.util.Log
import java.util.*

class CountryChecker(private val context: Context) {
    private val TAG = "CountryChecker"
    private val cngCountries = setOf(
        "RU", // Россия
        "BY", // Беларусь
        "KZ", // Казахстан
        "KG", // Киргизия
        "TJ", // Таджикистан
        "UZ", // Узбекистан
        "AZ", // Азербайджан
        "AM", // Армения
        "MD"  // Молдова
    )

    fun isCountryInCNG(): Boolean {
        try {
            // Получаем код страны из TelephonyManager
            val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            val countryCode = telephonyManager.networkCountryIso.uppercase(Locale.getDefault())
            Log.d(TAG, "Detected country code from TelephonyManager: $countryCode")
            
            // Если код страны не определен, пробуем получить из Locale
            if (countryCode.isEmpty()) {
                val localeCountryCode = Locale.getDefault().country.uppercase(Locale.getDefault())
                Log.d(TAG, "Country code from TelephonyManager is empty, using Locale: $localeCountryCode")
                return cngCountries.contains(localeCountryCode)
            }
            
            // Проверяем, находится ли страна в списке СНГ
            val isInCNG = cngCountries.contains(countryCode)
            Log.d(TAG, "Is country in CNG: $isInCNG (country code: $countryCode)")
            return isInCNG
        } catch (e: Exception) {
            Log.e(TAG, "Error detecting country", e)
            
            // В случае ошибки пробуем получить страну из Locale
            try {
                val localeCountryCode = Locale.getDefault().country.uppercase(Locale.getDefault())
                Log.d(TAG, "Error occurred, using Locale as fallback: $localeCountryCode")
                return cngCountries.contains(localeCountryCode)
            } catch (e: Exception) {
                Log.e(TAG, "Error getting country from Locale", e)
                return false
            }
        }
    }
} 