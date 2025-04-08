package com.example.shopapp

import android.os.Bundle
import android.util.Log
import android.webkit.WebView
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.example.shopapp.model.Product
import com.example.shopapp.ui.screens.*
import com.example.shopapp.ui.theme.ShopAppTheme
import com.example.shopapp.ui.viewmodels.CartViewModel
import com.example.shopapp.ui.viewmodels.ProductViewModel
import com.example.shopapp.utils.FirebaseManager
import com.example.shopapp.utils.CountryChecker
import kotlinx.coroutines.launch
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.viewinterop.AndroidView

class MainActivity : ComponentActivity() {
    private var webView: WebView? = null
    private val TAG = "MainActivity"
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        setContent {
            val darkColorScheme = darkColorScheme(
                primary = Color(0xFFFF5722),
                secondary = Color(0xFFFF5722),
                tertiary = Color(0xFFFF5722),
                background = Color(0xFF1A1A1A),
                surface = Color(0xFF2A2A2A),
                onPrimary = Color.White,
                onSecondary = Color.White,
                onTertiary = Color.White,
                onBackground = Color.White,
                onSurface = Color.White
            )

            MaterialTheme(
                colorScheme = darkColorScheme,
                typography = MaterialTheme.typography
            ) {
                val navController = rememberNavController()
                val context = LocalContext.current
                val firebaseManager = remember { FirebaseManager(context) }
                val countryChecker = remember { CountryChecker(context) }
                
                var errorMessage by remember { mutableStateOf<String?>(null) }
                var showWebView by remember { mutableStateOf(false) }
                var showOnboarding by remember { mutableStateOf(true) }
                
                // Initialize ViewModel
                val productViewModel: ProductViewModel = viewModel()
                val cartViewModel: CartViewModel = viewModel()
                
                // Check country and URL in Firebase
                LaunchedEffect(Unit) {
                    try {
                        val isInCNG = countryChecker.isCountryInCNG()
                        Log.d(TAG, "Country check result: isInCNG = $isInCNG")
                        
                        if (isInCNG) {
                            Log.d(TAG, "Country is in CNG, checking Firebase URL...")
                            val url = firebaseManager.getWebViewUrl()
                            Log.d(TAG, "Received URL from Firebase: $url")
                            showWebView = !url.isNullOrEmpty()
                            Log.d(TAG, "showWebView set to: $showWebView")
                            
                            if (showWebView) {
                                Log.d(TAG, "Navigating to WebView immediately")
                                navController.navigate("webview") {
                                    popUpTo("onboarding") { inclusive = true }
                                }
                            }
                        } else {
                            Log.d(TAG, "Country is not in CNG, using native mode")
                            showWebView = false
                        }
                        
                        if (!showWebView) {
                            Log.d(TAG, "Using native mode, loading sample data")
                            productViewModel.insertSampleProducts()
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Error during initialization", e)
                        showWebView = false
                        productViewModel.insertSampleProducts()
                    }
                }
                
                NavHost(navController = navController, startDestination = "onboarding") {
                    composable("onboarding") {
                        OnboardingScreen(
                            onFinishOnboarding = {
                                showOnboarding = false
                                if (showWebView) {
                                    navController.navigate("webview") {
                                        popUpTo("onboarding") { inclusive = true }
                                    }
                                } else {
                                    navController.navigate("productList") {
                                        popUpTo("onboarding") { inclusive = true }
                                    }
                                }
                            }
                        )
                    }
                    
                    composable("webview") {
                        var webViewUrl by remember { mutableStateOf<String?>(null) }
                        
                        LaunchedEffect(Unit) {
                            try {
                                Log.d(TAG, "Loading WebView URL...")
                                webViewUrl = firebaseManager.getWebViewUrl()
                                Log.d(TAG, "WebView URL loaded: $webViewUrl")
                            } catch (e: Exception) {
                                Log.e(TAG, "Error loading WebView URL", e)
                            }
                        }
                        
                        if (webViewUrl != null) {
                            Log.d(TAG, "Displaying WebView with URL: $webViewUrl")
                            Box(modifier = Modifier.fillMaxSize()) {
                                AndroidView(
                                    factory = { context ->
                                        WebView(context).apply {
                                            webView = this
                                            settings.javaScriptEnabled = true
                                            settings.domStorageEnabled = true
                                            settings.setSupportZoom(true)
                                            
                                            // Запрещаем создание скриншотов
                                            setLayerType(android.view.View.LAYER_TYPE_HARDWARE, null)
                                            
                                            loadUrl(webViewUrl!!)
                                            Log.d(TAG, "WebView created and URL loaded")
                                        }
                                    },
                                    modifier = Modifier.fillMaxSize()
                                )
                            }
                        } else {
                            Log.e(TAG, "WebView URL is null, showing error screen")
                            ErrorScreen(
                                message = "Failed to load web content",
                                onBackPressed = { navController.popBackStack() }
                            )
                        }
                    }
                    
                    composable("productList") {
                        val products by productViewModel.products.collectAsState(initial = emptyList())
                        val cartItems by cartViewModel.cartItems.collectAsState(initial = emptyList())
                        
                        ProductListScreen(
                            products = products,
                            cartItems = cartItems,
                            onAddToCart = { product -> 
                                cartViewModel.addToCart(product)
                            },
                            onCartClick = { navController.navigate("cart") },
                            onProductClick = { product ->
                                navController.navigate("product/${product.id}")
                            },
                            onBackClick = { navController.popBackStack() },
                            onAboutStoreClick = { navController.navigate("aboutStore") }
                        )
                    }
                    
                    composable("cart") {
                        val products by productViewModel.products.collectAsState(initial = emptyList())
                        CartScreen(
                            cartViewModel = cartViewModel,
                            products = products,
                            onNavigateBack = { navController.popBackStack() }
                        )
                    }
                    
                    composable(
                        route = "product/{productId}",
                        arguments = listOf(
                            navArgument("productId") { type = NavType.StringType }
                        )
                    ) { backStackEntry ->
                        val productId = backStackEntry.arguments?.getString("productId")
                        var product by remember { mutableStateOf<Product?>(null) }
                        
                        LaunchedEffect(productId) {
                            try {
                                val id = productId?.toIntOrNull()
                                if (id != null) {
                                    product = productViewModel.getProduct(id)
                                }
                            } catch (e: Exception) {
                                Log.e(TAG, "Error loading product", e)
                            }
                        }
                        
                        if (product != null) {
                            ProductDetailScreen(
                                product = product!!,
                                cartViewModel = cartViewModel,
                                onNavigateBack = { navController.popBackStack() }
                            )
                        } else {
                            ErrorScreen(
                                message = "Product not found",
                                onBackPressed = { navController.popBackStack() }
                            )
                        }
                    }
                    
                    composable("aboutStore") {
                        AboutStoreScreen(
                            onNavigateBack = { navController.popBackStack() }
                        )
                    }
                }
            }
        }
    }
    
    override fun onBackPressed() {
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
                    Text("Go Back")
                }
            }
        }
    }
}