package com.example.shopapp.ui.screens

import androidx.compose.animation.core.*
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Image
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.layout.positionInRoot
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import coil.compose.rememberAsyncImagePainter
import coil.request.ImageRequest
import com.example.shopapp.R
import com.example.shopapp.model.CartItem
import com.example.shopapp.model.Category
import com.example.shopapp.model.Product
import com.example.shopapp.ui.components.SimpleCartAnimation
import com.example.shopapp.ui.components.CartAnimationWrapper
import com.example.shopapp.ui.viewmodels.CategoryViewModel
import com.example.shopapp.ui.viewmodels.ProductViewModel
import com.example.shopapp.ui.viewmodels.CartViewModel
import kotlinx.coroutines.launch
import kotlin.math.roundToInt
import kotlinx.coroutines.delay

@Composable
private fun CartIconButton(
    cartItems: List<CartItem>,
    onClick: () -> Unit
) {
    val itemCount = cartItems.sumOf { it.quantity }
    
    Box {
        IconButton(onClick = onClick) {
            Icon(
                imageVector = Icons.Default.ShoppingCart,
                contentDescription = "Cart",
                tint = Color.White
            )
        }
        
        if (itemCount > 0) {
            Box(
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .offset(x = 10.dp, y = (-5).dp)
                    .size(20.dp)
                    .background(Color(0xFFFF5722), CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = if (itemCount > 99) "99+" else itemCount.toString(),
                    color = Color.White,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProductListScreen(
    products: List<Product>,
    cartItems: List<CartItem>,
    onAddToCart: (Product) -> Unit,
    onCartClick: () -> Unit,
    onProductClick: (Product) -> Unit,
    onBackClick: () -> Unit,
    onAboutStoreClick: () -> Unit
) {
    var searchQuery by remember { mutableStateOf("") }
    var selectedCategory by remember { mutableStateOf<String?>(null) }
    var showCategoryMenu by remember { mutableStateOf(false) }
    var cartIconSize by remember { mutableStateOf(0.dp) }
    var cartIconCoordinates by remember { mutableStateOf(Offset.Zero) }
    var animationStartPosition by remember { mutableStateOf(Offset.Zero) }
    var showAnimation by remember { mutableStateOf(false) }
    var animatedProduct by remember { mutableStateOf<Product?>(null) }
    
    // Get unique categories
    val categories = remember(products) {
        products.map { it.category }.distinct()
    }
    
    // Update cart icon size and position when coordinates change
    LaunchedEffect(cartIconCoordinates) {
        cartIconSize = 24.dp
    }
    
    // Filter products based on selected category and search query
    val filteredProducts = remember(products, selectedCategory, searchQuery) {
        products.filter { product ->
            val matchesCategory = selectedCategory == null || product.category == selectedCategory
            val matchesSearch = searchQuery.isEmpty() || 
                product.name.contains(searchQuery, ignoreCase = true) ||
                product.description.contains(searchQuery, ignoreCase = true)
            matchesCategory && matchesSearch
        }
    }
    
    Box(modifier = Modifier.fillMaxSize()) {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = { 
                        Text(
                            "WinApp",
                            color = Color(0xFFFF5722)
                        )
                    },
                    navigationIcon = {
                        IconButton(onClick = onBackClick) {
                            Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                        }
                    },
                    actions = {
                        // Cart icon with position tracking
                        Box(
                            modifier = Modifier
                                .onGloballyPositioned { coordinates ->
                                    cartIconCoordinates = coordinates.positionInRoot()
                                }
                        ) {
                            CartIconButton(
                                cartItems = cartItems,
                                onClick = onCartClick
                            )
                        }
                        
                        // About Store button
                        IconButton(onClick = onAboutStoreClick) {
                            Icon(
                                imageVector = Icons.Default.Info,
                                contentDescription = "About Store",
                                tint = Color.White
                            )
                        }
                    }
                )
            }
        ) { paddingValues ->
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues)
            ) {
                // Search bar
                TextField(
                    value = searchQuery,
                    onValueChange = { searchQuery = it },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    placeholder = { Text("Search products...") },
                    leadingIcon = {
                        Icon(
                            imageVector = Icons.Default.Search,
                            contentDescription = "Search",
                            tint = Color.Gray
                        )
                    },
                    colors = TextFieldDefaults.colors(
                        unfocusedContainerColor = Color(0xFF2A2A2A),
                        focusedContainerColor = Color(0xFF2A2A2A),
                        unfocusedTextColor = Color.White,
                        focusedTextColor = Color.White,
                        unfocusedPlaceholderColor = Color.Gray,
                        focusedPlaceholderColor = Color.Gray
                    ),
                    singleLine = true
                )
                
                // Category filter
                LazyRow(
                    contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    item {
                        CategoryChip(
                            name = "All",
                            isSelected = selectedCategory == null,
                            onClick = { selectedCategory = null }
                        )
                    }
                    
                    items(categories) { category ->
                        CategoryChip(
                            name = category,
                            isSelected = selectedCategory == category,
                            onClick = { selectedCategory = category }
                        )
                    }
                }
                
                // Product grid
                LazyVerticalGrid(
                    columns = GridCells.Fixed(2),
                    contentPadding = PaddingValues(16.dp),
                    horizontalArrangement = Arrangement.spacedBy(16.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp),
                    modifier = Modifier.fillMaxSize()
                ) {
                    items(filteredProducts) { product ->
                        ProductCard(
                            product = product,
                            onAddToCart = { product, position -> 
                                onAddToCart(product)
                                // Capture button position for animation
                                animationStartPosition = position
                                animatedProduct = product
                                showAnimation = true
                                
                                // Hide animation after it completes
                                kotlinx.coroutines.MainScope().launch {
                                    delay(1000)
                                    showAnimation = false
                                }
                            },
                            onClick = { onProductClick(product) }
                        )
                    }
                }
            }
        }
        
        // Animation is now outside the Scaffold to ensure it's above all other UI elements
        if (showAnimation && animatedProduct != null) {
            SimpleCartAnimation(
                product = animatedProduct!!,
                startPosition = animationStartPosition,
                targetPosition = cartIconCoordinates,
                targetSize = cartIconSize
            )
        }
    }
}

@Composable
fun CategoryChip(
    name: String,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    FilterChip(
        selected = isSelected,
        onClick = onClick,
        label = { Text(name, color = if (isSelected) Color.White else Color.Gray) },
        modifier = Modifier.padding(vertical = 4.dp),
        colors = FilterChipDefaults.filterChipColors(
            selectedContainerColor = Color(0xFFFF5722),
            containerColor = Color(0xFF2A2A2A),
            selectedLabelColor = Color.White,
            labelColor = Color.Gray
        )
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProductCard(
    product: Product,
    onAddToCart: (Product, Offset) -> Unit,
    onClick: () -> Unit
) {
    var buttonPosition by remember { mutableStateOf(Offset.Zero) }
    
    Card(
        modifier = Modifier
            .padding(8.dp)
            .fillMaxWidth()
            .clickable(onClick = onClick),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
        colors = CardDefaults.cardColors(
            containerColor = Color(0xFF2A2A2A)
        )
    ) {
        Column {
            // Product image
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(160.dp)
            ) {
                var isLoading by remember { mutableStateOf(true) }
                var isError by remember { mutableStateOf(false) }
                
                // Используем более простой подход к загрузке изображений
                val painter = rememberAsyncImagePainter(
                    model = product.imageUrl,
                    onLoading = { isLoading = true },
                    onSuccess = { isLoading = false },
                    onError = { 
                        isLoading = false
                        isError = true
                    }
                )
                
                Image(
                    painter = painter,
                    contentDescription = product.name,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
                
                if (isLoading) {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(Color(0xFF2A2A2A)),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(
                            color = Color(0xFFFF5722)
                        )
                    }
                }
                
                if (isError) {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(Color(0xFF2A2A2A)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.Image,
                            contentDescription = "Image error",
                            tint = Color.Gray,
                            modifier = Modifier.size(48.dp)
                        )
                    }
                }
                
                if (!product.inStock) {
                    Surface(
                        modifier = Modifier.align(Alignment.TopEnd),
                        color = MaterialTheme.colorScheme.error.copy(alpha = 0.8f)
                    ) {
                        Text(
                            text = "Out of Stock",
                            modifier = Modifier.padding(4.dp),
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onError
                        )
                    }
                }
            }

            // Product information
            Column(
                modifier = Modifier.padding(8.dp)
            ) {
                Text(
                    text = product.name,
                    style = MaterialTheme.typography.titleMedium,
                    color = Color.White,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
                
                Spacer(modifier = Modifier.height(4.dp))
                
                Text(
                    text = "₽${product.price}",
                    style = MaterialTheme.typography.titleSmall,
                    color = Color(0xFFFF5722)
                )
                
                Spacer(modifier = Modifier.height(8.dp))

                Button(
                    onClick = { onAddToCart(product, buttonPosition) },
                    enabled = product.inStock,
                    modifier = Modifier
                        .fillMaxWidth()
                        .onGloballyPositioned { coordinates ->
                            val position = coordinates.positionInRoot()
                            buttonPosition = position
                        },
                    colors = ButtonDefaults.buttonColors(
                        containerColor = Color(0xFFFF5722),
                        contentColor = Color.White,
                        disabledContainerColor = Color.Gray
                    )
                ) {
                    Text("Add to Cart")
                }
            }
        }
    }
} 