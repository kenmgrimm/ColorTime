import UIKit

class PaintingController : UIViewController, UIGestureRecognizerDelegate {
  @IBOutlet var scrollView: UIScrollView!

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    scrollView.delegate = self
    
    let imageView = PaintingImageView()
    imageView.image = #imageLiteral(resourceName: "owls")
    imageView.contentMode = .scaleAspectFit
    
    imageView.sizeToFit()  // Size the imageView to fit the image

    scrollView.flashScrollIndicators()

    scrollView.addSubview(imageView)

    scrollView.contentSize = imageView.frame.size
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Now that the scrollView's frame has been set we need to set the zoomScale
    let imageView = scrollView.subviews[0]

    let heightRatio = scrollView.frame.size.height / imageView.frame.size.height
    let widthRatio = scrollView.frame.size.width / imageView.frame.size.width
    let minZoom = min(heightRatio, widthRatio)
    
    scrollView.minimumZoomScale = minZoom
    scrollView.maximumZoomScale = 10.0
    scrollView.zoomScale = minZoom
    
    // Re-center (later)
    //    scrollView.contentOffset = CGPoint(x: -20, y: -20)
  }
}

extension PaintingController : UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return scrollView.subviews[0]
  }
  
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
  }
}
