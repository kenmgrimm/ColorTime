import UIKit

class PaintingController : UIViewController  {
  @IBOutlet var scrollView: UIScrollView!
  @IBOutlet var paletteWheelView: PaletteWheelView!
  @IBOutlet var paletteHistoryView: PaletteHistoryView!
  @IBOutlet var paintingControlsView: PaintingControlsView!
  
  var painting: Painting!
  
  // Must hold strong reference to data source as the collectionView.dataSource is weak..
  private var paletteHistoryDataSource: PaletteHistoryDataSource!
  
  private var paintingViewModel: PaintingViewModel!
  
  private var imageView: UIImageView!

  @IBAction func done() {
    save()
    
    navigationController?.popViewController(animated: false)
    
    dismiss(animated: false, completion: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // General view setup
    scrollView.delegate = self
    
    scrollView.flashScrollIndicators()
    
    
    // View model / bindings and stuff
    paintingViewModel = PaintingViewModel(painting)
    
    paletteWheelView.paintingViewModel = paintingViewModel
    paintingControlsView.load(paintingViewModel)
    
    self.paletteHistoryDataSource = PaletteHistoryDataSource(paintingViewModel)
    paletteHistoryView.paintingViewModel = paintingViewModel
    paletteHistoryView.dataSource = self.paletteHistoryDataSource
    paintingViewModel.colorPaletteHistory.bindAndFire { [unowned self] ([Int]) in
      self.paletteHistoryView.reloadData()
    }
    
    self.imageView = createImageView(paintingViewModel)
    scrollView.addSubview(imageView)
    
    paintingViewModel.paintingImage.bind { [unowned self] (image) in
      self.imageView.image = image
    }

    scrollView.contentSize = imageView.frame.size
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
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
  
  private func createImageView(_ paintingViewModel: PaintingViewModel) -> PaintingImageView {
    let imageView = PaintingImageView(paintingViewModel)

    return imageView
  }
  
  private func save() {
    guard let image = paintingViewModel.paintingImage.value else { return }
    Services.paintingService.saveDataAndImage(painting, image)
  }
}

extension PaintingController : UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return scrollView.subviews[0]
  }
}

