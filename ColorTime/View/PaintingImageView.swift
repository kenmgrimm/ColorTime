import UIKit

import PaintBucket

class PaintingImageView : UIImageView {
  var paintingViewModel: PaintingViewModel!
  
  init(_ paintingViewModel: PaintingViewModel) {
    super.init(frame: CGRect.zero)
    
    self.paintingViewModel = paintingViewModel
    self.contentMode = .scaleAspectFit
    
    // here setting in constructor, controller also sets...
    // Hack to size imageView correctly before correct image is loaded.  Spent a lot of time getting it to
    //  size after fetching but it always caused problems sizeing within the scrollView
    self.image = paintingViewModel.paintingImage.value ?? #imageLiteral(resourceName: "owls")

    sizeToFit()  // Size the imageView to fit the image
    
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
    
    paintingViewModel.paintingTouched(at: touchPoint)
  }

  private func touchToImageCoord(_ touchPoint: CGPoint) -> CGPoint {
    // This should be improved
    let zoomScale = (superview as! UIScrollView).zoomScale
    
    let x = image!.size.width * touchPoint.x * zoomScale / frame.size.width
    let y = image!.size.height * touchPoint.y * zoomScale / frame.size.height
    
    return CGPoint(x: x, y: y)
  }
}
