package com.example.shopapp.ui.screens

import android.view.ViewGroup
import android.webkit.WebView
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import com.example.shopapp.webview.WebViewManager
import com.example.shopapp.utils.DeviceChecker
import kotlinx.coroutines.launch

@Composable
fun WebViewScreen(
    onError: (String) -> Unit,
    onWebViewCreated: (WebView) -> Unit
) {
    val context = LocalContext.current
    val lifecycle = LocalLifecycleOwner.current.lifecycle
    val scope = rememberCoroutineScope()
    
    var webView by remember { mutableStateOf<WebView?>(null) }
    var isLoading by remember { mutableStateOf(true) }
    
    val webViewManager = remember { WebViewManager(context) }
    // val deviceChecker = remember { DeviceChecker(context) }
    
    // Проверка условий для отображения WebView
    LaunchedEffect(Unit) {
        scope.launch {
            // Временно отключаем все проверки для тестирования
            /*
            // Проверяем наличие SIM-карты
            if (!deviceChecker.hasSimCard()) {
                onError("Для использования приложения необходима SIM-карта")
                return@launch
            }
            
            // Проверяем местоположение
            if (!deviceChecker.isInCountry("ME")) {
                onError("Приложение доступно только в Черногории")
                return@launch
            }
            
            // Проверяем доступность интернета
            if (!deviceChecker.isNetworkAvailable()) {
                onError("Нет соединения с интернетом")
                return@launch
            }
            */
        }
    }
    
    // Обработка жизненного цикла WebView
    DisposableEffect(lifecycle) {
        val observer = LifecycleEventObserver { _, event ->
            when (event) {
                Lifecycle.Event.ON_PAUSE -> {
                    webView?.onPause()
                }
                Lifecycle.Event.ON_RESUME -> {
                    webView?.onResume()
                }
                else -> {}
            }
        }
        
        lifecycle.addObserver(observer)
        
        onDispose {
            lifecycle.removeObserver(observer)
            webView?.destroy()
        }
    }
    
    Box(modifier = Modifier.fillMaxSize()) {
        // Отображение WebView
        AndroidView(
            factory = { context ->
                WebView(context).apply {
                    layoutParams = ViewGroup.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT
                    )
                    webView = this
                    
                    // Запрещаем создание скриншотов
                    setLayerType(android.view.View.LAYER_TYPE_HARDWARE, null)
                    
                    onWebViewCreated(this)
                }
            },
            modifier = Modifier.fillMaxSize(),
            update = { webView ->
                webViewManager.initWebView(
                    webView,
                    object : WebViewManager.WebViewCallback {
                        override fun onWebViewReady(webView: WebView) {
                            isLoading = false
                        }
                        
                        override fun onWebViewError(message: String) {
                            onError(message)
                            isLoading = false
                        }
                        
                        override fun onWebViewLoading(loading: Boolean) {
                            isLoading = loading
                        }
                        
                        override fun onWebViewUrlChanged(url: String) {
                            // Можно добавить дополнительную логику при изменении URL
                        }
                    }
                )
            }
        )
        
        // Индикатор загрузки
        if (isLoading) {
            CircularProgressIndicator(
                modifier = Modifier
                    .size(48.dp)
                    .align(Alignment.Center)
            )
        }
    }
} 