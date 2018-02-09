import UIKit

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
    print(gestureRecognizer.location(in: self))
  }
}
