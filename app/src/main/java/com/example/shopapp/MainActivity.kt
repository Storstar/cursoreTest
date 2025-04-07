package com.example.shopapp

import android.os.Bundle
import android.util.Log
import android.webkit.WebView
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.shopapp.ui.screens.CartScreen
import com.example.shopapp.ui.screens.ProductListScreen
import com.example.shopapp.ui.screens.WebViewScreen
import com.example.shopapp.ui.theme.ShopAppTheme
import com.example.shopapp.utils.FirebaseManager
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    private var webView: WebView? = null
    private val TAG = "MainActivity"
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        setContent {
            ShopAppTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    val navController = rememberNavController()
                    val context = LocalContext.current
                    val firebaseManager = remember { FirebaseManager(context) }
                    
                    var errorMessage by remember { mutableStateOf<String?>(null) }
                    var showWebView by remember { mutableStateOf(false) }
                    
                    // Проверяем наличие URL в Firebase
                    LaunchedEffect(Unit) {
                        try {
                            Log.d(TAG, "Получаем URL из Firebase...")
                            val url = firebaseManager.getWebViewUrl()
                            Log.d(TAG, "Получен URL из Firebase: $url")
                            showWebView = !url.isNullOrEmpty()
                            Log.d(TAG, "showWebView установлен в: $showWebView")
                            
                            if (url.isNullOrEmpty()) {
                                Log.d(TAG, "URL пустой или null, используем нативный режим")
                            }
                        } catch (e: Exception) {
                            Log.e(TAG, "Ошибка при получении URL из Firebase", e)
                            // В случае ошибки используем нативный режим
                            showWebView = false
                        }
                    }
                    
                    NavHost(navController = navController, startDestination = "main") {
                        composable("main") {
                            if (errorMessage != null) {
                                ErrorScreen(
                                    message = errorMessage!!,
                                    onBackPressed = {
                                        errorMessage = null
                                    }
                                )
                            } else if (showWebView) {
                                Log.d(TAG, "Отображаем WebView")
                                WebViewScreen(
                                    onError = { error ->
                                        Log.e(TAG, "Ошибка WebView: $error")
                                        errorMessage = error
                                    },
                                    onWebViewCreated = { webViewInstance ->
                                        Log.d(TAG, "WebView создан")
                                        webView = webViewInstance
                                    }
                                )
                            } else {
                                Log.d(TAG, "Отображаем нативный интерфейс магазина")
                                // Показываем нативный интерфейс магазина
                                ProductListScreen(
                                    onNavigateToCart = {
                                        navController.navigate("cart")
                                    }
                                )
                            }
                        }
                        
                        composable("cart") {
                            CartScreen(
                                onNavigateBack = {
                                    navController.popBackStack()
                                }
                            )
                        }
                    }
                }
            }
        }
    }
    
    override fun onBackPressed() {
        // Проверяем, может ли WebView вернуться назад
        if (webView?.canGoBack() == true) {
            webView?.goBack()
        } else {
            super.onBackPressed()
        }
    }
    
    @Composable
    fun ErrorScreen(
        message: String,
        onBackPressed: () -> Unit
    ) {
        Surface(
            modifier = Modifier.fillMaxSize(),
            color = MaterialTheme.colorScheme.background
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                Text(
                    text = message,
                    style = MaterialTheme.typography.bodyLarge,
                    color = MaterialTheme.colorScheme.error
                )
                Spacer(modifier = Modifier.height(16.dp))
                Button(onClick = onBackPressed) {
                    Text("Вернуться назад")
                }
            }
        }
    }
} 