package com.example.shopapp.webview

import android.content.Context
import android.content.SharedPreferences
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.webkit.CookieManager
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import com.example.shopapp.utils.FirebaseManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.*

class WebViewManager(private val context: Context) {
    private val sharedPreferences: SharedPreferences = context.getSharedPreferences("WebViewPrefs", Context.MODE_PRIVATE)
    private val firebaseManager: FirebaseManager = FirebaseManager(context)
    private val cookieManager: CookieManager = CookieManager.getInstance()
    private val coroutineScope = CoroutineScope(Dispatchers.Main)
    
    // Ключи для SharedPreferences
    private val KEY_LAST_URL = "last_url"
    private val KEY_FIREBASE_URL = "firebase_url"
    
    // Флаг для отслеживания состояния WebView
    private var isWebViewActive = false
    
    // Интерфейс для обратных вызовов
    interface WebViewCallback {
        fun onWebViewReady(webView: WebView)
        fun onWebViewError(message: String)
        fun onWebViewLoading(loading: Boolean)
        fun onWebViewUrlChanged(url: String)
    }
    
    // Инициализация WebView
    fun initWebView(webView: WebView, callback: WebViewCallback) {
        // Настройка WebView
        webView.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            databaseEnabled = true
            setSupportZoom(true)
            builtInZoomControls = true
            displayZoomControls = false
            useWideViewPort = true
            loadWithOverviewMode = true
        }
        
        // Настройка CookieManager
        cookieManager.setAcceptCookie(true)
        cookieManager.setAcceptThirdPartyCookies(webView, true)
        
        // Настройка WebViewClient
        webView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
                val url = request.url.toString()
                callback.onWebViewUrlChanged(url)
                return false
            }
            
            override fun onPageFinished(view: WebView, url: String) {
                super.onPageFinished(view, url)
                callback.onWebViewLoading(false)
                // Сохраняем URL после всех редиректов
                saveLastUrl(url)
            }
            
            override fun onReceivedError(
                view: WebView,
                request: WebResourceRequest,
                error: android.webkit.WebResourceError
            ) {
                super.onReceivedError(view, request, error)
                if (request.isForMainFrame) {
                    callback.onWebViewError("Ошибка загрузки страницы: ${error.description}")
                }
            }
        }
        
        // Проверка доступности интернета
        if (!isNetworkAvailable()) {
            callback.onWebViewError("Нет соединения с интернетом, проверьте подключение и перезапустите приложение")
            return
        }
        
        // Загрузка URL
        loadUrl(webView, callback)
    }
    
    // Загрузка URL
    private fun loadUrl(webView: WebView, callback: WebViewCallback) {
        // Проверяем, есть ли сохраненный URL
        val lastUrl = getLastUrl()
        if (lastUrl.isNotEmpty()) {
            // Загружаем сохраненный URL
            webView.loadUrl(lastUrl)
            isWebViewActive = true
            callback.onWebViewReady(webView)
            return
        }
        
        // Если нет сохраненного URL, проверяем Firebase
        coroutineScope.launch {
            try {
                val firebaseUrl = firebaseManager.getWebViewUrl()
                if (!firebaseUrl.isNullOrEmpty()) {
                    // Загружаем URL из Firebase
                    webView.loadUrl(firebaseUrl)
                    isWebViewActive = true
                    callback.onWebViewReady(webView)
                    // Сохраняем URL из Firebase
                    saveFirebaseUrl(firebaseUrl)
                } else {
                    // Если URL в Firebase пустой, показываем нативную часть
                    isWebViewActive = false
                    callback.onWebViewError("URL не найден")
                }
            } catch (e: Exception) {
                // В случае ошибки используем сохраненный URL из Firebase
                val savedUrl = getFirebaseUrl()
                if (savedUrl.isNotEmpty()) {
                    webView.loadUrl(savedUrl)
                    isWebViewActive = true
                    callback.onWebViewReady(webView)
                } else {
                    isWebViewActive = false
                    callback.onWebViewError("URL не найден")
                }
            }
        }
    }
    
    // Сохранение последнего URL
    private fun saveLastUrl(url: String) {
        sharedPreferences.edit().putString(KEY_LAST_URL, url).apply()
    }
    
    // Получение последнего URL
    private fun getLastUrl(): String {
        return sharedPreferences.getString(KEY_LAST_URL, "") ?: ""
    }
    
    // Сохранение URL из Firebase
    private fun saveFirebaseUrl(url: String) {
        sharedPreferences.edit().putString(KEY_FIREBASE_URL, url).apply()
    }
    
    // Получение URL из Firebase
    private fun getFirebaseUrl(): String {
        return sharedPreferences.getString(KEY_FIREBASE_URL, "") ?: ""
    }
    
    // Проверка доступности интернета
    private fun isNetworkAvailable(): Boolean {
        val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val network = connectivityManager.activeNetwork ?: return false
            val capabilities = connectivityManager.getNetworkCapabilities(network) ?: return false
            return capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
        } else {
            val networkInfo = connectivityManager.activeNetworkInfo
            return networkInfo != null && networkInfo.isConnected
        }
    }
    
    // Проверка, активен ли WebView
    fun isWebViewActive(): Boolean {
        return isWebViewActive
    }
    
    // Обработка кнопки "Назад"
    fun handleBackPress(webView: WebView): Boolean {
        if (webView.canGoBack()) {
            webView.goBack()
            return true
        }
        return false
    }
} 