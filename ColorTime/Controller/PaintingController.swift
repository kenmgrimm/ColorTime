import UIKit

class PaintingController : UIViewController, UIGestureRecognizerDelegate {
  @IBOutlet var scrollView: UIScrollView!
  @IBOutlet var paletteTapRecognizer: UITapGestureRecognizer!
  
  var painting: Painting!
  
  private var imageView: UIImageView!

  @IBAction func done() {
    save()
    
    navigationController?.popViewController(animated: true)
    
    dismiss(animated: true, completion: nil)
  }

  @IBAction func paletteTap(_ gestureRecognizer : UITapGestureRecognizer ) {
    print(#function)
    paletteClicked(gestureRecognizer)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    scrollView.delegate = self

    imageView = createImageView()
    
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
  
  private func createImageView() -> UIImageView {
    let imageView = PaintingImageView()
    imageView.image = painting.image()
    imageView.contentMode = .scaleAspectFit
    
    imageView.sizeToFit()  // Size the imageView to fit the image
    
    return imageView
  }
  
  private func save() {
    Services.paintingService.saveDataAndImage(painting, imageView.image!)
  }
}

extension PaintingController : UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return scrollView.subviews[0]
  }
  
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
  }
}

// Palette control
extension PaintingController {
  func paletteClicked(_ tapGestureRecognizer: UITapGestureRecognizer) {
    guard tapGestureRecognizer.state == UIGestureRecognizerState.recognized,
      let paletteImageView = tapGestureRecognizer.view as! UIImageView?,
      let location = tapGestureRecognizer.location(in: tapGestureRecognizer.view) as CGPoint?
      else { return }
    
    let pixelColor = paletteImageView.image!.getPixelColor(
      atLocation: location,
      withFrameSize: paletteImageView.frame.size)
    
//    paintingViewModel.addColorToPalette(pixelColor)
    
    print("PaletteView: \(location.x), \(location.y): \(pixelColor)")
  }
}
