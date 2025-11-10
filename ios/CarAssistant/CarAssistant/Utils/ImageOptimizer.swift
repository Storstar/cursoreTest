//
//  ImageOptimizer.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import UIKit
import SwiftUI

/// Утилита для оптимизации изображений и экономии памяти
final class ImageOptimizer {
    
    /// Создать thumbnail из данных изображения
    /// - Parameters:
    ///   - data: Данные изображения
    ///   - maxSize: Максимальный размер (ширина или высота)
    /// - Returns: Оптимизированное изображение
    static func createThumbnail(from data: Data, maxSize: CGFloat) -> UIImage? {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxSize
        ]
        
        guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            return nil
        }
        
        return UIImage(cgImage: thumbnail)
    }
    
    /// Создать thumbnail из UIImage
    /// - Parameters:
    ///   - image: Исходное изображение
    ///   - maxSize: Максимальный размер (ширина или высота)
    /// - Returns: Оптимизированное изображение
    static func createThumbnail(from image: UIImage, maxSize: CGFloat) -> UIImage? {
        let size = image.size
        let scale = min(maxSize / size.width, maxSize / size.height, 1.0)
        
        guard scale < 1.0 else {
            return image
        }
        
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        
        image.draw(in: CGRect(origin: .zero, size: scaledSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Оптимизировать изображение для отображения (downsampling)
    /// - Parameters:
    ///   - data: Данные изображения
    ///   - targetSize: Целевой размер для отображения
    /// - Returns: Оптимизированное изображение
    static func downsampleImage(data: Data, to targetSize: CGSize) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return nil
        }
        
        let maxDimensionInPixels = max(targetSize.width, targetSize.height) * UIScreen.main.scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: false,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
        
        return UIImage(cgImage: downsampledImage)
    }
    
    /// Сжать изображение для сохранения в Core Data
    /// - Parameters:
    ///   - image: Исходное изображение
    ///   - maxDimension: Максимальный размер (ширина или высота)
    ///   - compressionQuality: Качество сжатия (0.0 - 1.0)
    /// - Returns: Сжатые данные изображения
    static func compressImage(_ image: UIImage, maxDimension: CGFloat = 800, compressionQuality: CGFloat = 0.7) -> Data? {
        let size = image.size
        let scale = min(maxDimension / size.width, maxDimension / size.height, 1.0)
        
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        
        image.draw(in: CGRect(origin: .zero, size: scaledSize))
        guard let scaledImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        var imageData = scaledImage.jpegData(compressionQuality: compressionQuality)
        
        // Если изображение все еще слишком большое, сжимаем сильнее
        if let data = imageData, data.count > 500_000 {
            imageData = scaledImage.jpegData(compressionQuality: 0.5)
        }
        
        return imageData
    }
}

