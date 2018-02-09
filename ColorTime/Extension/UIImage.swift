import UIKit

extension UIImage {
  
  convenience init?(fileURL: URL) {
    do {
      let imageData = try Data(contentsOf: fileURL)
      
      self.init(data: imageData)
    }
    catch {
      print("Error loading image : \(error)")
      return nil
    }
  }
  
  // Not sure why yet but this method works on the palette but not the full image.
  //   getColorAt that I put into PaintBucket works on the full image but is incorrect for the palette
  func getPixelColor(atLocation location: CGPoint, withFrameSize size: CGSize) -> UIColor {
    let x: CGFloat = (self.size.width) * location.x / size.width
    let y: CGFloat = (self.size.height) * location.y / size.height

    let pixelPoint: CGPoint = CGPoint(x: x, y: y)
    
    let pixelData = self.cgImage!.dataProvider!.data
    let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
    
    let pixelIndex: Int = ((Int(self.size.width) * Int(pixelPoint.y)) + Int(pixelPoint.x)) * 4
    
    let r = CGFloat(data[pixelIndex]) / CGFloat(255.0)
    let g = CGFloat(data[pixelIndex+1]) / CGFloat(255.0)
    let b = CGFloat(data[pixelIndex+2]) / CGFloat(255.0)
    let a = CGFloat(data[pixelIndex+3]) / CGFloat(255.0)
    
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }

  func updateAlpha(_ alpha: CGFloat) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    draw(at: .zero, blendMode: .normal, alpha: alpha)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
}
