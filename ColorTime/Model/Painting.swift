import UIKit

struct Painting : Codable {
  static let ColorUpdateNotification = "ColorUpdateNotification"

  let paintingId: Int
  var originalImageURL: URL

  private(set) var colorPaletteHistory = [Int]()
  var paintPointHistory = [PaintPoint]()
  
  init(paintingId: Int) {
    self.paintingId = paintingId
    self.originalImageURL = FileService.getDocumentsURL().appendingPathComponent("painting_\(paintingId).png")
  }
  
  mutating func addColorToPalette(_ color: UIColor) {
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
