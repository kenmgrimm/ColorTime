import UIKit

struct Painting : Codable {
  static let ColorUpdateNotification = "ColorUpdateNotification"

  let pageId: Int = 0
  let originalImageURL = FileService.getDocumentsURL().appendingPathComponent("painting_0.png")

  private(set) var colorPaletteHistory : [Int]
  var paintPointHistory : [PaintPoint] = []
  
  mutating func addColorToPalette(_ color: UIColor) {
    guard let colorRgb = color.rgb() else { return }
    
    colorPaletteHistory = colorPaletteHistory.filter { (value: Int) in value != colorRgb }
    colorPaletteHistory.append(colorRgb)
  }
}
