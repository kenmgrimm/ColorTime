import UIKit

class PaintingController : UIViewController, UIGestureRecognizerDelegate {
  @IBOutlet var scrollView: UIScrollView!
  @IBOutlet var paletteWheelView: PaletteWheelView!
  @IBOutlet var paletteHistoryView: PaletteHistoryView!
  
  var painting: Painting!
  
  // Must hold strong reference to data source as the collectionView.dataSource is weak..
  private var paletteHistoryDataSource: PaletteHistoryDataSource!
  
  private var paintingViewModel: PaintingViewModel!
  
  private var imageView: UIImageView!

  @IBAction func done() {
    save()
    
    navigationController?.popViewController(animated: true)
    
    dismiss(animated: true, completion: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // View model / bindings and stuff
    paintingViewModel = PaintingViewModel(painting)
    paletteWheelView.paintingViewModel = paintingViewModel
    
    self.paletteHistoryDataSource = PaletteHistoryDataSource(paintingViewModel)
    paletteHistoryView.paintingViewModel = paintingViewModel
    paletteHistoryView.dataSource = self.paletteHistoryDataSource
    paintingViewModel.colorPaletteHistory.bindAndFire { [unowned self] ([Int]) in
      self.paletteHistoryView.reloadData()
    }
    

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
}

