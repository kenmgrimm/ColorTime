import UIKit

protocol ImageServiceProtocol {
  func image(for painting: Painting) -> UIImage?
  func saveImage(for painting: Painting, image: UIImage)
}

class ImageFileService : ImageServiceProtocol {
  let cache = NSCache<NSString, UIImage>()
  
  func image(for painting: Painting) -> UIImage? {
    var image = fetchImageFromCache(painting: painting)
    
    if image == nil {
      image = UIImage(fileURL: imageURL(for: painting))
      
      if let image = image {
        cacheImage(painting: painting, image: image)
      }
    }

    return image
  }
  
  func deleteImage(for painting: Painting) {
    do {
      try FileManager.default.removeItem(at: imageURL(for: painting))
    }
    catch {
      
    }
  }
  
  func saveImage(for painting: Painting, image: UIImage) {
    if let data = UIImagePNGRepresentation(image) {
      try? data.write(to: imageURL(for: painting))
    }
    
    cacheImage(painting: painting, image: image)
  }
  
  private func cacheImage(painting: Painting, image: UIImage) {
    let cacheKey = imageKey(for: painting)

    cache.setObject(image, forKey: cacheKey)
  }
  
  private func fetchImageFromCache(painting: Painting) -> UIImage? {
    let cacheKey = imageKey(for: painting)

    return cache.object(forKey: cacheKey)
  }
  
  private func imageKey(for painting: Painting) -> NSString {
    return "painting_\(painting.paintingId)" as NSString
  }
  
  private func imageURL(for painting: Painting) -> URL {
    return FileService.getDocumentsURL().appendingPathComponent("painting_\(painting.paintingId).png")
  }
}
