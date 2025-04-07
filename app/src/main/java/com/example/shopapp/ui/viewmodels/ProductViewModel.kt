package com.example.shopapp.ui.viewmodels

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.shopapp.data.AppDatabase
import com.example.shopapp.model.CartItem
import com.example.shopapp.model.Product
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

class ProductViewModel(application: Application) : AndroidViewModel(application) {
    private val database = AppDatabase.getDatabase(application)
    private val productDao = database.productDao()
    private val cartDao = database.cartDao()

    val products: Flow<List<Product>> = productDao.getAllProducts()

    init {
        // Добавим тестовые данные, если база пуста
        viewModelScope.launch {
            if (products.first().isEmpty()) {
                insertSampleProducts()
            }
        }
    }

    private suspend fun insertSampleProducts() {
        val sampleProducts = listOf(
            // Традиционные инструменты для мытья окон
            Product(
                name = "Slimline Brass squeegee",
                description = "Профессиональный скребок для мытья окон из латуни",
                price = 87.20,
                imageUrl = "",
                category = "Традиционные инструменты"
            ),
            Product(
                name = "IPC Pulex Brass Squeegee",
                description = "Латунный скребок IPC Pulex для профессиональной мойки окон",
                price = 52.90,
                imageUrl = "",
                category = "Традиционные инструменты"
            ),
            Product(
                name = "Moerman Alu Squeegee",
                description = "Алюминиевый скребок Moerman для эффективной мойки окон",
                price = 55.35,
                imageUrl = "",
                category = "Традиционные инструменты"
            ),
            Product(
                name = "Unger ErgoTec Ninja Squeegee",
                description = "Эргономичный скребок Unger ErgoTec Ninja для профессиональной мойки",
                price = 156.12,
                imageUrl = "",
                category = "Традиционные инструменты"
            ),
            Product(
                name = "IPC Pulex Alumax Window Squeegee",
                description = "Алюминиевый скребок IPC Pulex Alumax для мойки окон",
                price = 88.56,
                imageUrl = "",
                category = "Традиционные инструменты"
            ),
            
            // Водяные системы
            Product(
                name = "Gardiner Ultimate Flocked Brush 35 cm",
                description = "Щетка Gardiner Ultimate Flocked для водяной системы мойки окон",
                price = 223.86,
                imageUrl = "",
                category = "Водяные системы"
            ),
            Product(
                name = "CleanPro Glass Cloth",
                description = "Ткань для чистки стекла CleanPro",
                price = 4.90,
                imageUrl = "",
                category = "Аксессуары"
            ),
            
            // Комплекты
            Product(
                name = "Complete Softclean set with 11m pole",
                description = "Полный набор Softclean с 11-метровой штангой",
                price = 5499.28,
                imageUrl = "",
                category = "Комплекты"
            ),
            Product(
                name = "Moerman Premium Window Cleaning Set",
                description = "Премиальный набор для мойки окон Moerman",
                price = 127.47,
                imageUrl = "",
                category = "Комплекты"
            ),
            
            // Штанги
            Product(
                name = "Moerman Bi-Component Telescopic Pole",
                description = "Телескопическая штанга Moerman Bi-Component",
                price = 171.00,
                imageUrl = "",
                category = "Штанги"
            ),
            
            // Щетки
            Product(
                name = "Wagtail Pivot Control 35 cm Squeegee",
                description = "Скребок Wagtail Pivot Control 35 см с поворотным механизмом",
                price = 160.75,
                imageUrl = "",
                category = "Щетки"
            ),
            
            // Химия
            Product(
                name = "Ettore Master Brass Squeegee",
                description = "Латунный скребок Ettore Master для профессиональной мойки",
                price = 96.32,
                imageUrl = "",
                category = "Традиционные инструменты"
            )
        )
        sampleProducts.forEach { product ->
            productDao.insertProduct(product)
        }
    }

    fun addToCart(product: Product) {
        viewModelScope.launch {
            val existingItem = cartDao.getCartItemByProductId(product.id)
            if (existingItem != null) {
                cartDao.insertCartItem(existingItem.copy(quantity = existingItem.quantity + 1))
            } else {
                cartDao.insertCartItem(CartItem(productId = product.id, quantity = 1))
            }
        }
    }
} 