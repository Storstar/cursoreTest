package com.example.shopapp.ui.viewmodels

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.shopapp.data.AppDatabase
import com.example.shopapp.model.Category
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

class CategoryViewModel(application: Application) : AndroidViewModel(application) {
    private val database = AppDatabase.getDatabase(application)
    private val categoryDao = database.categoryDao()

    val categories: Flow<List<Category>> = categoryDao.getAllCategories()

    init {
        // Добавим тестовые данные, если база пуста
        viewModelScope.launch {
            if (categories.first().isEmpty()) {
                insertSampleCategories()
            }
        }
    }

    private fun insertSampleCategories() {
        viewModelScope.launch {
            val sampleCategories = listOf(
                Category(
                    id = 1,
                    name = "Традиционные наборы",
                    description = "Профессиональные наборы для мытья окон традиционным методом",
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/traditional-sets.jpg"
                ),
                Category(
                    id = 2,
                    name = "Щетки для водяного метода",
                    description = "Щетки для мытья окон методом подачи воды",
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/water-fed-brushes.jpg"
                ),
                Category(
                    id = 3,
                    name = "Телескопические штанги",
                    description = "Телескопические штанги для мытья окон на высоте",
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/telescopic-poles.jpg"
                ),
                Category(
                    id = 4,
                    name = "Традиционные инструменты",
                    description = "Швабры, скребки и другие инструменты для мытья окон",
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/traditional-tools.jpg"
                ),
                Category(
                    id = 5,
                    name = "Наборы для мягкой мойки",
                    description = "Комплекты для мягкой мойки фасадов и окон",
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/soft-wash-sets.jpg"
                ),
                Category(
                    id = 6,
                    name = "Ткани и салфетки",
                    description = "Профессиональные ткани и салфетки для мытья стекол",
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/cloths-and-wipes.jpg"
                ),
                Category(
                    id = 7,
                    name = "Химические средства",
                    description = "Профессиональные средства для мытья окон и фасадов",
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/chemicals.jpg"
                ),
                Category(
                    id = 8,
                    name = "Аксессуары",
                    description = "Дополнительные аксессуары для профессиональной мойки окон",
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/accessories.jpg"
                )
            )
            sampleCategories.forEach { category ->
                categoryDao.insert(category)
            }
        }
    }

    suspend fun getCategory(id: Int): Category? {
        return categoryDao.getCategoryById(id)
    }
} 