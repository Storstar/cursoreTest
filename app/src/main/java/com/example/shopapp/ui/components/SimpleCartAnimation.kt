package com.example.shopapp.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import coil.compose.rememberAsyncImagePainter
import coil.request.ImageRequest
import com.example.shopapp.model.Product
import kotlin.math.roundToInt

@Composable
fun SimpleCartAnimation(
    product: Product,
    startPosition: Offset,
    targetPosition: Offset,
    targetSize: androidx.compose.ui.unit.Dp
) {
    var isVisible by remember { mutableStateOf(true) }
    
    // Scale animation - start larger and shrink to target size
    val scale by animateFloatAsState(
        targetValue = 0.3f,
        animationSpec = tween(
            durationMillis = 1000,
            easing = FastOutSlowInEasing
        ),
        finishedListener = {
            isVisible = false
        }
    )
    
    // Position animation
    val offsetX by animateFloatAsState(
        targetValue = targetPosition.x - startPosition.x,
        animationSpec = tween(
            durationMillis = 1000,
            easing = FastOutSlowInEasing
        )
    )
    
    val offsetY by animateFloatAsState(
        targetValue = targetPosition.y - startPosition.y,
        animationSpec = tween(
            durationMillis = 1000,
            easing = FastOutSlowInEasing
        )
    )
    
    // Glow effect
    val glowAlpha by animateFloatAsState(
        targetValue = 0f,
        animationSpec = tween(
            durationMillis = 1000,
            easing = FastOutSlowInEasing
        )
    )
    
    // Rotation animation
    val rotation by animateFloatAsState(
        targetValue = 360f,
        animationSpec = tween(
            durationMillis = 1000,
            easing = FastOutSlowInEasing
        )
    )
    
    if (isVisible) {
        Box(
            modifier = Modifier
                .offset { IntOffset((startPosition.x + offsetX).roundToInt(), (startPosition.y + offsetY).roundToInt()) }
                .size(width = targetSize * 2, height = targetSize * 2) // Make it larger
                .scale(scale)
                .background(
                    color = Color(0xFFFF5722).copy(alpha = 0.3f + glowAlpha), // Orange glow
                    shape = CircleShape
                )
                .padding(4.dp)
                .clip(CircleShape)
                .graphicsLayer {
                    this.shadowElevation = 16f
                    this.rotationZ = rotation
                }
        ) {
            Image(
                painter = rememberAsyncImagePainter(
                    ImageRequest.Builder(LocalContext.current)
                        .data(data = product.imageUrl)
                        .build()
                ),
                contentDescription = "Animated product",
                modifier = Modifier.fillMaxSize(),
                contentScale = ContentScale.Crop
            )
        }
    }
} 