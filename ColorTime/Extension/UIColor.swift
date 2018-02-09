import UIKit

extension UIColor {
  convenience init(red: Int, green: Int, blue: Int) {
    assert(red >= 0 && red <= 255, "Invalid red component")
    assert(green >= 0 && green <= 255, "Invalid green component")
    assert(blue >= 0 && blue <= 255, "Invalid blue component")
    
    self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
  }
  
  convenience init(rgb: Int) {
    self.init(
      red: (rgb >> 16) & 0xFF,
      green: (rgb >> 8) & 0xFF,
      blue: rgb & 0xFF
    )
  }

  func rgb() -> Int? {
    var fRed : CGFloat = 0
    var fGreen : CGFloat = 0
    var fBlue : CGFloat = 0
    var fAlpha: CGFloat = 0
    if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
      let iRed = Int(fRed * 255.0)
      let iGreen = Int(fGreen * 255.0)
      let iBlue = Int(fBlue * 255.0)
      let iAlpha = Int(fAlpha * 255.0)
      
      //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
      let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
      return rgb
    } else {
      // Could not extract RGBA components:
      return nil
    }
  }
  
  class func color(withData data:Data) -> UIColor {
    return NSKeyedUnarchiver.unarchiveObject(with: data) as! UIColor
  }
  
  func encode() -> Data {
    return NSKeyedArchiver.archivedData(withRootObject: self)
  }
}
