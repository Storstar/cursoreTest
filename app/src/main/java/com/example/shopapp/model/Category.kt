package com.example.shopapp.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "categories")
data class Category(
    @PrimaryKey
    val id: Int,
    val name: String,
    val description: String,
    val imageUrl: String
) 