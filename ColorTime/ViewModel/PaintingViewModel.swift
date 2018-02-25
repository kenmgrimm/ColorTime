import Foundation
import UIKit

import PaintBucket

enum FetchImageResult {
  case success(UIImage)
  case failure(ImageError)
}

enum ImageError : Error {
  case fetchImageError
}


class PaintingViewModel {
  private let FLOOD_TOLERANCE = 4000
  
  private var painting: Painting {
    didSet {
      updateColorPaletteHistory()
    }
  }
  
  let paintingImage: Observable<UIImage?>

  private(set) var colorPaletteHistory : Observable<[Int]>
  
  init(_ painting: Painting) {
    self.painting = painting
    
    self.colorPaletteHistory = Observable(painting.colorPaletteHistory.reversed())
    self.paintingImage = Observable(#imageLiteral(resourceName: "owls"))
    
    fetchImage(completion: { (imageResult) in
      guard case let .success(image) = imageResult else { return }
      
      self.paintingImage.value = image
    })
    
    subscribeToNotifications()
  }
  
  deinit {
    unsubscribeFromNotifications()
  }
  
  func addColorToPalette(_ color: UIColor) {
    painting.addColorToPalette(color)
    updateColorPaletteHistory()
  }
  
  func selectColorFromPalette(at index: Int) {
    let colorRgb = self.colorPaletteHistory.value[index]
    painting.addColorToPalette(UIColor(rgb: colorRgb))
    updateColorPaletteHistory()
  }
  
  func paintingTouched(at point: CGPoint) {
    floodFill(at: point)
  }
  
  private func updateColorPaletteHistory() {
    self.colorPaletteHistory.value = painting.colorPaletteHistory.reversed()
  }
  
  private func addPaintingPoint(_ paintPoint : PaintPoint) {
    painting.paintPointHistory.append(paintPoint)
  }

  
  public func fetchImage(completion: @escaping (FetchImageResult) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async { // async
      guard let image = Services.imageService.image(for: self.painting) else { return }  // Slow operation
      
      OperationQueue.main.addOperation {  // On fetch image completion, run completion handler on _main_ thread (update UI)
        completion(.success(image))
      }
    }
  }

// Image processing / floodfill
  private func floodFill(at point: CGPoint, color: UIColor) {
    guard let image = self.paintingImage.value else { return }
    
    self.paintingImage.value = image.pbk_imageByReplacingColorAt(Int(point.x), Int(point.y), withColor: color, tolerance: FLOOD_TOLERANCE)
  }
  
  // Don't fill if a line (darker color) is clicked
  private func tooDark(_ color: UIColor) -> Bool {
    let darknessThreshold: CGFloat = 0.3

    let rgb = color.cgColor.components![0..<3]
    
    // All 3 rgb channels are below the darkness threshold
    return rgb.filter({ (value: CGFloat) in
      return value < darknessThreshold
    }).count == 3
  }

  private func floodFill(at point: CGPoint) {
    guard let image = self.paintingImage.value else { return }
    let currentPixelColor = image.getColorAt(Int(point.x), Int(point.y))
    
    guard !tooDark(currentPixelColor) else { return }

    let newColor = currentPaletteColor()
    
    let paintPoint = PaintPoint(position: point, oldColor: currentPixelColor, newColor: newColor)
    addPaintingPoint(paintPoint)
    
    floodFill(at: point, color: newColor)
  }
  
  // Draw click point for debugging purposes
  private func debugDrawPoint(_ x: CGFloat, _ y: CGFloat) {
    guard let image = self.paintingImage.value else { return }
    
    UIGraphicsBeginImageContext(image.size)
    image.draw(at: CGPoint.zero)

    let context = UIGraphicsGetCurrentContext()!
    
    context.setLineWidth(1.0)
    context.setStrokeColor(UIColor.blue.cgColor)
    context.addEllipse(in: CGRect(x: x, y: y, width: 3, height: 3))
    context.drawPath(using: .fill)
    
    self.paintingImage.value = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
  }

  func undoLastPoint() {
    guard let lastPoint = painting.paintPointHistory.last else { return }
    
    floodFill(at: lastPoint.position, color: lastPoint.oldColor)
    
    painting.paintPointHistory.remove(at: painting.paintPointHistory.count - 1)
  }
  
  private func subscribeToNotifications() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(colorsUpdated(_:)),
                                           name: NSNotification.Name(rawValue: Painting.ColorUpdateNotification),
                                           object: nil)
  }
  
  private func unsubscribeFromNotifications() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc private func colorsUpdated(_ notification: NSNotification) {
    guard let userInfo = notification.userInfo,
      let newPainting = userInfo["painting"] as! Painting?
      else { return }
    
    self.painting = newPainting
  }
  
  func currentPaletteColor() -> UIColor {
    var currentColor = painting.colorPaletteHistory.last
    if currentColor == nil {
      currentColor = UIColor.brown.rgb()
    }
    return UIColor(rgb: currentColor!)
  }
}

