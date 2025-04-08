package com.example.shopapp.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material.icons.filled.Schedule
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.shopapp.R

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AboutStoreScreen(
    onNavigateBack: () -> Unit
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("About Store") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(
                            imageVector = Icons.Default.ArrowBack,
                            contentDescription = "Back"
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = Color(0xFFFF5722),
                    titleContentColor = Color.White
                )
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(Color(0xFF1A1A1A))
                .padding(paddingValues)
                .padding(16.dp)
                .verticalScroll(rememberScrollState()),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Store logo
            Text(
                text = "WinApp",
                color = Color(0xFFFF5722),
                fontSize = 48.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(vertical = 24.dp)
            )
            
            // Store image
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(200.dp)
                    .clip(RoundedCornerShape(16.dp))
                    .background(Color(0xFF2A2A2A)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "Store Photo",
                    color = Color.Gray
                )
            }
            
            Spacer(modifier = Modifier.height(24.dp))
            
            // Store description
            Text(
                text = "WinApp - your trusted assistant in the world of professional window and facade cleaning",
                color = Color.White,
                fontSize = 18.sp,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(bottom = 16.dp)
            )
            
            Text(
                text = "We offer a wide range of professional equipment for window cleaning, photovoltaic panels, facades, and other smooth surfaces. As professionals with experience, we know exactly what you might need. Whether you are a professional or want to clean the windows in your home, you will find all the necessary tools in our store.",
                color = Color.Gray,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(bottom = 24.dp)
            )
            
            // Contact information
            InfoRow(
                icon = Icons.Default.LocationOn,
                title = "Warehouse Address",
                content = "WinApp\nul. Kasztelańska 27\n30-116 Kraków"
            )
            
            InfoRow(
                icon = Icons.Default.Phone,
                title = "Phone",
                content = "+48 513 583 221\ninfo@winshop.pl"
            )
            
            InfoRow(
                icon = Icons.Default.Schedule,
                title = "Working Hours",
                content = "Mon-Fri: 8:00 - 16:00 (GMT +1)"
            )
            
            Spacer(modifier = Modifier.height(24.dp))
            
            // Contact button
            Button(
                onClick = { /* TODO: Implement contact action */ },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 32.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFFFF5722)
                )
            ) {
                Text("Contact Us")
            }
            
            Spacer(modifier = Modifier.height(32.dp))
        }
    }
}

@Composable
fun InfoRow(
    icon: ImageVector,
    title: String,
    content: String
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        verticalAlignment = Alignment.Top
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = Color(0xFFFF5722),
            modifier = Modifier.padding(end = 16.dp)
        )
        
        Column {
            Text(
                text = title,
                color = Color.White,
                fontWeight = FontWeight.Bold
            )
            
            Text(
                text = content,
                color = Color.Gray,
                modifier = Modifier.padding(top = 4.dp)
            )
        }
    }
} 