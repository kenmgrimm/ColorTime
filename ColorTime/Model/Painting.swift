import UIKit

struct Painting : Codable {
  static let ColorUpdateNotification = "ColorUpdateNotification"

  let pageId: Int = 0
  private(set) var colorPaletteHistory : [Int]
  var paintPointHistory : [PaintPoint] = []
  
  mutating func addColorToPalette(_ color: UIColor) {
    guard let colorRgb = color.rgb() else { return }
    
    colorPaletteHistory = colorPaletteHistory.filter { (value: Int) in value != colorRgb }
    colorPaletteHistory.append(colorRgb)
  }
}
