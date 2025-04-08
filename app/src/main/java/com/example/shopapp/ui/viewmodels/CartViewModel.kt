package com.example.shopapp.ui.viewmodels

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.shopapp.data.AppDatabase
import com.example.shopapp.model.CartItem
import com.example.shopapp.model.Product
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.launch
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class CartViewModel(application: Application) : AndroidViewModel(application) {
    private val database = AppDatabase.getDatabase(application)
    private val cartDao = database.cartDao()
    private val productDao = database.productDao()

    // Use Flow from Room instead of MutableStateFlow
    val cartItems: Flow<List<CartItem>> = cartDao.getAllCartItems()

    val products: Flow<List<Product>> = productDao.getAllProducts()

    fun addToCart(product: Product) {
        viewModelScope.launch {
            val existingItem = cartDao.getCartItemByProductId(product.id)
            
            if (existingItem != null) {
                // Update quantity if item exists
                cartDao.updateCartItem(existingItem.copy(quantity = existingItem.quantity + 1))
            } else {
                // Add new item if it doesn't exist
                cartDao.insertCartItem(CartItem(productId = product.id, quantity = 1))
            }
        }
    }

    fun removeFromCart(cartItem: CartItem) {
        viewModelScope.launch {
            cartDao.deleteCartItem(cartItem)
        }
    }

    fun updateQuantity(cartItem: CartItem, newQuantity: Int) {
        if (newQuantity <= 0) {
            removeFromCart(cartItem)
            return
        }
        
        viewModelScope.launch {
            cartDao.updateCartItem(cartItem.copy(quantity = newQuantity))
        }
    }

    fun updateCartItemQuantity(productId: Int, newQuantity: Int) {
        viewModelScope.launch {
            val existingItem = cartDao.getCartItemByProductId(productId)
            if (existingItem != null) {
                if (newQuantity <= 0) {
                    removeFromCart(existingItem)
                } else {
                    cartDao.updateCartItem(existingItem.copy(quantity = newQuantity))
                }
            }
        }
    }

    fun clearCart() {
        viewModelScope.launch {
            cartDao.clearCart()
        }
    }
} 