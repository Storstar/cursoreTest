import UIKit
import Foundation

class ImageOptimizer {
    static let shared = ImageOptimizer()
    
    private init() {}
    
    // Создать thumbnail из изображения
    func createThumbnail(from image: UIImage, maxSize: CGFloat = 200) -> UIImage? {
        let size = image.size
        let aspectRatio = size.width / size.height
        
        var newSize: CGSize
        if size.width > size.height {
            newSize = CGSize(width: maxSize, height: maxSize / aspectRatio)
        } else {
            newSize = CGSize(width: maxSize * aspectRatio, height: maxSize)
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // Оптимизировать изображение для сохранения (сжатие и уменьшение размера)
    func optimizeImage(_ image: UIImage, maxDimension: CGFloat = 1200, compressionQuality: CGFloat = 0.7) -> Data? {
        let size = image.size
        let aspectRatio = size.width / size.height
        
        var newSize: CGSize
        if size.width > size.height {
            if size.width > maxDimension {
                newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
            } else {
                newSize = size
            }
        } else {
            if size.height > maxDimension {
                newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
            } else {
                newSize = size
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: newSize))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        return resizedImage.jpegData(compressionQuality: compressionQuality)
    }
    
    // Создать thumbnail data для отображения в списках
    func createThumbnailData(from imageData: Data, maxSize: CGFloat = 200) -> Data? {
        guard let image = UIImage(data: imageData),
              let thumbnail = createThumbnail(from: image, maxSize: maxSize) else {
            return nil
        }
        return thumbnail.jpegData(compressionQuality: 0.8)
    }
}

