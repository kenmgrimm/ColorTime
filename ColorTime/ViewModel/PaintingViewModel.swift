import Foundation

import UIKit

class PaintingViewModel {
  private var painting: Painting {
    didSet {
      self.colorPaletteHistory.value = painting.colorPaletteHistory.reversed()
    }
  }

  private(set) var colorPaletteHistory : Observable<[Int]>
  
  init(_ painting: Painting) {
    self.painting = painting
    
    self.colorPaletteHistory = Observable(painting.colorPaletteHistory.reversed())
    
    subscribeToNotifications()
  }
  
  deinit {
    unsubscribeFromNotifications()
  }
  
  func addColorToPalette(_ color: UIColor) {
    painting.addColorToPalette(color)
  }
  
  func selectColorFromPalette(at index: Int) {
    let colorRgb = self.colorPaletteHistory.value[index]
    painting.addColorToPalette(UIColor(rgb: colorRgb))
  }
  
  func addPaintingPoint(_ paintPoint : PaintPoint) {
    painting.paintPointHistory.append(paintPoint)
  }
  
  func undoLastPoint() -> PaintPoint? {
    if painting.paintPointHistory.count == 0 { return nil }
    
    return painting.paintPointHistory.remove(at: painting.paintPointHistory.count - 1)
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

