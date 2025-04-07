package com.example.shopapp.utils

import android.content.Context
import com.google.firebase.FirebaseApp
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

class FirebaseManager(private val context: Context) {
    private val firestore = FirebaseFirestore.getInstance()
    
    init {
        // Инициализируем Firebase, если еще не инициализирован
        if (FirebaseApp.getApps(context).isEmpty()) {
            FirebaseApp.initializeApp(context)
        }
    }
    
    suspend fun getWebViewUrl(): String? = suspendCancellableCoroutine { continuation ->
        firestore.collection("settings")
            .document("webview")
            .get()
            .addOnSuccessListener { document ->
                val url = document.getString("url")
                continuation.resume(url)
            }
            .addOnFailureListener { exception ->
                continuation.resumeWithException(exception)
            }
    }
} 