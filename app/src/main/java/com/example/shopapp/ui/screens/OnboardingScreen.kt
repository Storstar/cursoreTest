package com.example.shopapp.ui.screens

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.shopapp.R
import com.example.shopapp.model.OnboardingSlide
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext

@Composable
fun OnboardingScreen(
    onFinishOnboarding: () -> Unit
) {
    val slides = listOf(
        OnboardingSlide(
            title = "Welcome to WinApp",
            description = "Your one-stop shop for professional cleaning equipment",
            imageResId = R.drawable.onboarding1
        ),
        OnboardingSlide(
            title = "Wide Selection",
            description = "Browse through our extensive catalog of high-quality cleaning products",
            imageResId = R.drawable.onboarding2
        ),
        OnboardingSlide(
            title = "Fast Delivery",
            description = "Get your orders delivered quickly and safely",
            imageResId = R.drawable.onboarding3
        )
    )

    var currentPage by remember { mutableStateOf(0) }
    
    // Анимация масштабирования для изображения
    val scale by animateFloatAsState(
        targetValue = 1f,
        animationSpec = tween(
            durationMillis = 500,
            easing = FastOutSlowInEasing
        ),
        label = "scale"
    )

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF1A1A1A))
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Skip button
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp)
            ) {
                TextButton(
                    onClick = onFinishOnboarding,
                    modifier = Modifier.align(Alignment.TopEnd)
                ) {
                    Text(
                        text = "Skip",
                        color = Color.White
                    )
                }
            }
            
            // Content
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
            ) {
                OnboardingSlide(slide = slides[currentPage])
            }
            
            // Bottom section with dots and buttons
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Page dots
                Row(
                    modifier = Modifier.padding(bottom = 32.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    slides.forEachIndexed { index, _ ->
                        Box(
                            modifier = Modifier
                                .size(8.dp)
                                .clip(RoundedCornerShape(4.dp))
                                .background(
                                    if (index == currentPage) Color(0xFFFF5722)
                                    else Color.Gray
                                )
                        )
                    }
                }
                
                // Navigation buttons
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    if (currentPage > 0) {
                        Button(
                            onClick = { currentPage-- },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = Color(0xFF2A2A2A)
                            )
                        ) {
                            Text("Previous")
                        }
                    } else {
                        Spacer(modifier = Modifier.width(80.dp))
                    }
                    
                    Button(
                        onClick = {
                            if (currentPage < slides.size - 1) {
                                currentPage++
                            } else {
                                onFinishOnboarding()
                            }
                        },
                        colors = ButtonDefaults.buttonColors(
                            containerColor = Color(0xFFFF5722)
                        )
                    ) {
                        Text(
                            if (currentPage < slides.size - 1) "Next"
                            else "Get Started"
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun OnboardingSlide(slide: OnboardingSlide) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Image(
            painter = painterResource(id = slide.imageResId),
            contentDescription = slide.title,
            modifier = Modifier
                .size(300.dp)
                .padding(bottom = 32.dp),
            contentScale = ContentScale.Fit
        )
        
        Text(
            text = slide.title,
            color = Color.White,
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(bottom = 16.dp)
        )
        
        Text(
            text = slide.description,
            color = Color.Gray,
            fontSize = 16.sp,
            textAlign = TextAlign.Center
        )
    }
} 