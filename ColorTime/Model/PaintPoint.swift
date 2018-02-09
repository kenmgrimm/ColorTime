import UIKit

struct PaintPoint : Codable {
  let position : CGPoint
  let oldColor : UIColor
  let newColor : UIColor
  
  enum CodingKeys: String, CodingKey {
    case position
    case oldColor
    case newColor
  }
  
  init(position: CGPoint, oldColor: UIColor, newColor: UIColor) {
    self.position = position
    self.oldColor = oldColor
    self.newColor = newColor
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    position = try values.decode(CGPoint.self, forKey: .position)
    oldColor = try UIColor(rgb: values.decode(Int.self, forKey: .oldColor))
    newColor = try UIColor(rgb: values.decode(Int.self, forKey: .newColor))
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(position, forKey: .position)
    try container.encode(oldColor.rgb(), forKey: .oldColor)
    try container.encode(newColor.rgb(), forKey: .newColor)
  }
}
