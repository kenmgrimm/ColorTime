import UIKit

import PaintBucket

class PaintingImageView : UIImageView {
  var paintingViewModel: PaintingViewModel!
  
  init(_ paintingViewModel: PaintingViewModel) {
    super.init(frame: CGRect.zero)
    
    self.paintingViewModel = paintingViewModel
    self.contentMode = .scaleAspectFit

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
    let zoomScale = (superview as! UIScrollView).zoomScale
    
    let x = image!.size.width * touchPoint.x * zoomScale / frame.size.width
    let y = image!.size.height * touchPoint.y * zoomScale / frame.size.height
    
    return CGPoint(x: x, y: y)
  }
}
