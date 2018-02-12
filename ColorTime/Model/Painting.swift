import UIKit

class Painting : Codable {
  static let ColorUpdateNotification = "ColorUpdateNotification"

  let paintingId: Int

  var colorPaletteHistory = [Int]()
  var paintPointHistory = [PaintPoint]()
  
  init(paintingId: Int) {
    self.paintingId = paintingId
  }
  
  func addColorToPalette(_ color: UIColor) {
    guard let colorRgb = color.rgb() else { return }
    
    colorPaletteHistory = colorPaletteHistory.filter { (value: Int) in value != colorRgb }
    colorPaletteHistory.append(colorRgb)
  }
}

extension Painting : Hashable {
  var hashValue: Int {
    return self.paintingId
  }
  
  static func ==(lhs: Painting, rhs: Painting) -> Bool {
    return lhs.paintingId == rhs.paintingId
  }
}
