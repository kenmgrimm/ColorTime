import Foundation
import UIKit

import PaintBucket

class PaintingViewModel {
  private var painting: Painting {
    didSet {
      updateColorPaletteHistory()
    }
  }
  
  var paintingImage: Observable<UIImage>

  private(set) var colorPaletteHistory : Observable<[Int]>
  
  init(_ painting: Painting) {
    self.painting = painting
    
    self.colorPaletteHistory = Observable(painting.colorPaletteHistory.reversed())
    self.paintingImage = Observable(Services.paintingService.image(painting))
    
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

  private func floodFill(at point: CGPoint, color: UIColor) {
    self.paintingImage.value = self.paintingImage.value.pbk_imageByReplacingColorAt(Int(point.x), Int(point.y), withColor: color, tolerance: 300)
  }
  
  private func floodFill(at point: CGPoint) {
    let newColor = currentPaletteColor()
    
    let currentPixelColor = self.paintingImage.value.getColorAt(Int(point.x), Int(point.y))
    
    let paintPoint = PaintPoint(position: point, oldColor: currentPixelColor, newColor: newColor)
    addPaintingPoint(paintPoint)
    
    floodFill(at: point, color: newColor)
  }
  
  private func debugDrawPoint(_ x: CGFloat, _ y: CGFloat) {
    let image = self.paintingImage.value
    
    UIGraphicsBeginImageContext(image.size)
    image.draw(at: CGPoint.zero)
    
    // In case need to draw painting as overlay on top of base image
    //      self.image?.draw(in: frame)
    //      self.image?.draw(at: <#T##CGPoint#>, blendMode: <#T##CGBlendMode#>, alpha: <#T##CGFloat#>)
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

