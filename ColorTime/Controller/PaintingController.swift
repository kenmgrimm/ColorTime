import UIKit

class PaintingController : UIViewController, UIScrollViewDelegate {
  @IBOutlet var scrollView: UIScrollView!
  
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return scrollView.subviews[0]
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    scrollView.delegate = self
    scrollView.contentMode = .scaleAspectFit
    
    let imageView = UIImageView()
    imageView.image = #imageLiteral(resourceName: "owls")
    imageView.contentMode = .scaleAspectFit
    imageView.sizeToFit()  // Size the imageView to fit the image

    scrollView.flashScrollIndicators()
    
    scrollView.minimumZoomScale = scrollView.frame.size.width / imageView.frame.size.width;
    scrollView.zoomScale = scrollView.minimumZoomScale
    scrollView.maximumZoomScale = 10.0
    
    scrollView.addSubview(imageView)
    scrollView.contentSize = imageView.frame.size
  }
}

