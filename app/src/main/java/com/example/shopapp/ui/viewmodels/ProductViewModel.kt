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
        // Add sample data if database is empty
        viewModelScope.launch {
            if (products.first().isEmpty()) {
                insertSampleProducts()
            }
        }
    }

    fun insertSampleProducts() {
        viewModelScope.launch {
            val sampleProducts = listOf(
                // Traditional Sets (categoryId = 1)
                Product(
                    id = 1,
                    name = "Moerman Premium Window Cleaning Set",
                    description = "Professional window cleaning set",
                    price = 127.47,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/moerman-premium-set.jpg",
                    category = "Traditional Sets",
                    categoryId = 1,
                    details = "Complete set of professional window cleaning equipment, including all necessary tools for efficient work.",
                    specifications = "• Window washer\n• Squeegee\n• Telescopic pole\n• Belt\n• Bucket\n• Chemicals",
                    inStock = true
                ),
                Product(
                    id = 2,
                    name = "Super Combo Washer & Squeegee",
                    description = "Combined window cleaning set",
                    price = 228.94,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/super-combo-set.jpg",
                    category = "Traditional Sets",
                    categoryId = 1,
                    details = "Economical set for professional window cleaning, combining quality and affordability.",
                    specifications = "• Washer: 35 cm\n• Squeegee: 35 cm\n• Ergonomic design\n• Quick change attachments",
                    inStock = true
                ),
                Product(
                    id = 3,
                    name = "Unger ErgoTec Complete Set",
                    description = "Complete ErgoTec window cleaning set",
                    price = 345.99,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/unger-ergotec-set.jpg",
                    category = "Traditional Sets",
                    categoryId = 1,
                    details = "Professional ErgoTec window cleaning set, providing maximum comfort and efficiency.",
                    specifications = "• ErgoTec washer: 35 cm\n• ErgoTec squeegee: 35 cm\n• Telescopic pole\n• Safety belt",
                    inStock = true
                ),
                
                // Water-fed Brushes (categoryId = 2)
                Product(
                    id = 4,
                    name = "Gardiner Ultimate Flocked Brush 35 cm",
                    description = "Professional window cleaning brush",
                    price = 223.86,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/gardiner-flocked-brush.jpg",
                    category = "Water-fed Brushes",
                    categoryId = 2,
                    details = "High-quality brush with flocked surface for effective window cleaning using water-fed method.",
                    specifications = "• Length: 35 cm\n• Material: high-quality flock\n• Compatible with Gardiner systems\n• Effective dirt removal",
                    inStock = true
                ),
                Product(
                    id = 5,
                    name = "Unger HydraBrush 35 cm",
                    description = "Water-fed brush",
                    price = 189.99,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/unger-hydra-brush.jpg",
                    category = "Water-fed Brushes",
                    categoryId = 2,
                    details = "Professional brush for window cleaning using water-fed method, ensuring even water distribution.",
                    specifications = "• Length: 35 cm\n• Material: high-quality flock\n• Compatible with Unger systems\n• Effective dirt removal",
                    inStock = true
                ),
                Product(
                    id = 6,
                    name = "Moerman Excelerator Brush 35 cm",
                    description = "Water-fed brush",
                    price = 199.99,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/moerman-excelerator-brush.jpg",
                    category = "Water-fed Brushes",
                    categoryId = 2,
                    details = "Professional brush for window cleaning using water-fed method, ensuring effective cleaning.",
                    specifications = "• Length: 35 cm\n• Material: high-quality flock\n• Compatible with Moerman systems\n• Effective dirt removal",
                    inStock = true
                ),
                
                // Telescopic Poles (categoryId = 3)
                Product(
                    id = 7,
                    name = "Moerman Bi-Component Telescopic Pole",
                    description = "Telescopic pole for window cleaning",
                    price = 171.00,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/moerman-pole.jpg",
                    category = "Telescopic Poles",
                    categoryId = 3,
                    details = "Professional telescopic pole for high-rise window cleaning, ensuring safety and convenience.",
                    specifications = "• Length: 4-7 meters\n• Material: aluminum\n• Section locking\n• Ergonomic handle",
                    inStock = true
                ),
                Product(
                    id = 8,
                    name = "Unger Telescopic Pole 4-7m",
                    description = "Telescopic pole for window cleaning",
                    price = 189.99,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/unger-pole.jpg",
                    category = "Telescopic Poles",
                    categoryId = 3,
                    details = "Professional telescopic pole for high-rise window cleaning, ensuring safety and convenience.",
                    specifications = "• Length: 4-7 meters\n• Material: aluminum\n• Section locking\n• Ergonomic handle",
                    inStock = true
                ),
                Product(
                    id = 9,
                    name = "Gardiner SLX Telescopic Pole 4-7m",
                    description = "Telescopic pole for window cleaning",
                    price = 199.99,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/gardiner-pole.jpg",
                    category = "Telescopic Poles",
                    categoryId = 3,
                    details = "Professional telescopic pole for high-rise window cleaning, ensuring safety and convenience.",
                    specifications = "• Length: 4-7 meters\n• Material: aluminum\n• Section locking\n• Ergonomic handle",
                    inStock = true
                ),
                
                // Traditional Tools (categoryId = 4)
                Product(
                    id = 10,
                    name = "Unger Visa Versa Pro Squeegee & Washer",
                    description = "Washer and squeegee set for window cleaning",
                    price = 186.90,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/unger-versa.jpg",
                    category = "Traditional Tools",
                    categoryId = 4,
                    details = "Professional set for window cleaning, consisting of a washer and squeegee, ensuring effective cleaning.",
                    specifications = "• Washer: 35 cm\n• Squeegee: 35 cm\n• Ergonomic design\n• Quick change attachments",
                    inStock = true
                ),
                Product(
                    id = 11,
                    name = "Wagtail High Flyer Washer & Squeegee",
                    description = "Set for cleaning high windows",
                    price = 175.30,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/wagtail-highflyer.jpg",
                    category = "Traditional Tools",
                    categoryId = 4,
                    details = "Special set for cleaning high windows, ensuring safety and efficiency.",
                    specifications = "• Washer: 35 cm\n• Squeegee: 35 cm\n• Safety system\n• Compatible with telescopic poles",
                    inStock = true
                ),
                Product(
                    id = 12,
                    name = "Moerman Excelerator Ultimate Washer & Squeegee",
                    description = "Window cleaning set",
                    price = 234.73,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/moerman-excelerator.jpg",
                    category = "Traditional Tools",
                    categoryId = 4,
                    details = "Professional set for window cleaning, ensuring effective cleaning and comfort during work.",
                    specifications = "• Washer: 35 cm\n• Squeegee: 35 cm\n• Ergonomic design\n• Quick change attachments",
                    inStock = true
                ),
                
                // Soft Wash Sets (categoryId = 5)
                Product(
                    id = 13,
                    name = "Complete Softclean set with 11m pole",
                    description = "Complete soft wash set",
                    price = 5499.28,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/softclean-set.jpg",
                    category = "Soft Wash Sets",
                    categoryId = 5,
                    details = "Comprehensive set for professional soft washing of facades and windows, including all necessary components.",
                    specifications = "• Telescopic pole: 11 m\n• High-pressure pump\n• Filtration system\n• Set of brushes and attachments",
                    inStock = true
                ),
                Product(
                    id = 14,
                    name = "Softwash Basic Kit",
                    description = "Basic soft wash set",
                    price = 2499.99,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/softwash-basic.jpg",
                    category = "Soft Wash Sets",
                    categoryId = 5,
                    details = "Basic set for soft washing of facades and windows, perfect for beginners.",
                    specifications = "• Telescopic pole: 7 m\n• Medium-pressure pump\n• Basic filtration system\n• Set of brushes",
                    inStock = true
                ),
                Product(
                    id = 15,
                    name = "Softwash Professional Kit",
                    description = "Professional soft wash set",
                    price = 3999.99,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/softwash-pro.jpg",
                    category = "Soft Wash Sets",
                    categoryId = 5,
                    details = "Professional set for soft washing of facades and windows, ensuring maximum efficiency.",
                    specifications = "• Telescopic pole: 9 m\n• High-pressure pump\n• Advanced filtration system\n• Extended set of brushes and attachments",
                    inStock = true
                ),
                
                // Cloths and Wipes (categoryId = 6)
                Product(
                    id = 16,
                    name = "CleanPro Glass Cloth",
                    description = "Glass cleaning cloth",
                    price = 4.90,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/cleanpro-cloth.jpg",
                    category = "Cloths and Wipes",
                    categoryId = 6,
                    details = "Professional cloth for glass cleaning, ensuring flawless cleaning without streaks.",
                    specifications = "• Size: 40x40 cm\n• Material: microfiber\n• High absorbency\n• No streaks",
                    inStock = true
                ),
                Product(
                    id = 17,
                    name = "Unger ErgoTec Microfiber Cloth",
                    description = "Microfiber cloth for glass cleaning",
                    price = 5.99,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/unger-cloth.jpg",
                    category = "Cloths and Wipes",
                    categoryId = 6,
                    details = "Professional microfiber cloth for glass cleaning, ensuring flawless cleaning.",
                    specifications = "• Size: 40x40 cm\n• Material: microfiber\n• High absorbency\n• No streaks",
                    inStock = true
                ),
                Product(
                    id = 18,
                    name = "Moerman Microfiber Cloth Pack (5 pcs)",
                    description = "Set of microfiber cloths",
                    price = 19.99,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/moerman-cloth-pack.jpg",
                    category = "Cloths and Wipes",
                    categoryId = 6,
                    details = "Set of 5 microfiber cloths for glass cleaning, ensuring flawless cleaning.",
                    specifications = "• Size: 40x40 cm\n• Material: microfiber\n• High absorbency\n• No streaks",
                    inStock = true
                ),
                
                // Chemicals (categoryId = 7)
                Product(
                    id = 19,
                    name = "Unger Glass Cleaner Concentrate",
                    description = "Glass cleaning concentrate",
                    price = 24.99,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/unger-cleaner.jpg",
                    category = "Chemicals",
                    categoryId = 7,
                    details = "Professional concentrate for glass cleaning, ensuring flawless cleaning.",
                    specifications = "• Volume: 1 L\n• Dilution: 1:100\n• Ammonia-free\n• No streaks",
                    inStock = true
                ),
                Product(
                    id = 20,
                    name = "Moerman Glass Cleaner Ready to Use",
                    description = "Ready-to-use glass cleaner",
                    price = 14.99,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/moerman-cleaner.jpg",
                    category = "Chemicals",
                    categoryId = 7,
                    details = "Ready-to-use glass cleaner, ensuring flawless cleaning.",
                    specifications = "• Volume: 1 L\n• Ready to use\n• Ammonia-free\n• No streaks",
                    inStock = true
                ),
                Product(
                    id = 21,
                    name = "Softwash Chemical Kit",
                    description = "Set of chemicals for soft washing",
                    price = 149.99,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/softwash-chemicals.jpg",
                    category = "Chemicals",
                    categoryId = 7,
                    details = "Set of chemicals for soft washing of facades and windows, ensuring effective cleaning.",
                    specifications = "• Soft wash concentrate: 5 L\n• Neutralizer: 1 L\n• Usage instructions\n• Safety equipment",
                    inStock = true
                ),
                
                // Accessories (categoryId = 8)
                Product(
                    id = 22,
                    name = "Unger ErgoTec Belt",
                    description = "Tool belt",
                    price = 49.99,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/unger-belt.jpg",
                    category = "Accessories",
                    categoryId = 8,
                    details = "Professional tool belt, ensuring convenience and safety during work.",
                    specifications = "• Material: durable fabric\n• Adjustable size\n• Tool pockets\n• Velcro closure",
                    inStock = true
                ),
                Product(
                    id = 23,
                    name = "Moerman Bucket with Wringer",
                    description = "Bucket with wringer",
                    price = 39.99,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/moerman-bucket.jpg",
                    category = "Accessories",
                    categoryId = 8,
                    details = "Professional bucket with wringer for window washer, ensuring convenience during window cleaning.",
                    specifications = "• Volume: 12 L\n• Material: durable plastic\n• Built-in wringer\n• Carrying handle",
                    inStock = true
                ),
                Product(
                    id = 24,
                    name = "Gardiner Holster Set",
                    description = "Set of tool holders",
                    price = 29.99,
                    imageUrl = "https://winshop.me/wp-content/uploads/2023/05/gardiner-holster.jpg",
                    category = "Accessories",
                    categoryId = 8,
                    details = "Set of tool holders, ensuring convenience and safety during work.",
                    specifications = "• Washer holder\n• Squeegee holder\n• Telescopic pole holder\n• Material: durable fabric",
                    inStock = true
                )
            )
            sampleProducts.forEach { product ->
                productDao.insert(product)
            }
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

    suspend fun getProduct(id: Int): Product? {
        return productDao.getProductById(id)
    }
    
    fun getProductsByCategory(categoryId: Int): Flow<List<Product>> {
        return productDao.getProductsByCategory(categoryId)
    }
} 