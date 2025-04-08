package com.example.shopapp.ui.components

import androidx.compose.runtime.Composable
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.unit.Dp
import com.example.shopapp.model.Product

@Composable
fun CartAnimationWrapper(
    animatingProduct: Product?,
    startPosition: Offset,
    cartIconPosition: Offset,
    cartIconSize: Dp
) {
    if (animatingProduct != null) {
        SimpleCartAnimation(
            product = animatingProduct,
            startPosition = startPosition,
            targetPosition = cartIconPosition,
            targetSize = cartIconSize
        )
    }
} 