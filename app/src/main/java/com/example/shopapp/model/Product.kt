package com.example.shopapp.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "products")
data class Product(
    @PrimaryKey
    val id: Int,
    val name: String,
    val description: String,
    val price: Double,
    val imageUrl: String,
    val category: String,
    val categoryId: Int,
    val details: String,
    val specifications: String,
    val inStock: Boolean
) 