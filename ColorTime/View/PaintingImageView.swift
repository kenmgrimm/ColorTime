import UIKit

import PaintBucket

class PaintingImageView : UIImageView {
  init() {
    super.init(frame: CGRect.zero)
    
    isUserInteractionEnabled = true
    
    let tapRecognizer = UITapGestureRecognizer(target: self,
                                               action: #selector(PaintingImageView.tap(_:)))

    addGestureRecognizer(tapRecognizer)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc func tap(_ gestureRecognizer: UIGestureRecognizer) {
    let touchPoint = gestureRecognizer.location(in: self)
    
    floodFill(at: touchPoint, color: UIColor.red)
  }

  func floodFill(at point: CGPoint, color: UIColor) {
    self.image = image!.pbk_imageByReplacingColorAt(Int(point.x), Int(point.y), withColor: color, tolerance: 200)
  }
  
//  func floodFill(at point: CGPoint) {
//    let newColor = paintingViewModel.currentPaletteColor()
//
//    let currentPixelColor = image!.getColorAt(Int(point.x), Int(point.y))
//
//    let paintPoint = PaintPoint(position: point, oldColor: currentPixelColor, newColor: newColor)
//    paintingViewModel.addPaintingPoint(paintPoint)
//
//    floodFill(at: point, color: newColor)
//  }
  
  private func debugDrawPoint(_ x: CGFloat, _ y: CGFloat) {
    //    print("debugDrawPoint: \(point.x), \(point.y)")
    
    guard let image = image else { return }
    
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
    
    self.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }

  private func touchToImageCoord(_ touchPoint: CGPoint) -> CGPoint {
    // This should be improved
    let zoomScale = (superview as! UIScrollView).zoomScale
    
    let x = image!.size.width * touchPoint.x * zoomScale / frame.size.width
    let y = image!.size.height * touchPoint.y * zoomScale / frame.size.height
    
    return CGPoint(x: x, y: y)
  }
}
