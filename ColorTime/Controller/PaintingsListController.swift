import UIKit

class PaintingsListController: UIViewController {
  @IBOutlet var collectionView: UICollectionView!
  
  // Must hold strong reference to data source as the collectionView.dataSource is weak..
  private let collectionDataSource = PaintingDataSource()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.dataSource = collectionDataSource
    collectionView.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    collectionView.reloadData()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "painting"?:
      if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
        let painting = Services.paintingService.find(paintingId: selectedIndexPath.row)
        
        let destNavController = segue.destination as! UINavigationController
        let paintingController = destNavController.topViewController as! PaintingController
        
        paintingController.painting = painting
      }
    default:
      preconditionFailure("Unexpected segue identifier")
    }
  }
}

// Paintings list related
extension PaintingsListController : UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    print(#function)
    let paintingCell = cell as! PaintingCollectionViewCell
    
    let painting = Services.paintingService.find(paintingId: indexPath.row)!
    let paintingViewModel = PaintingViewModel(painting)
    
    paintingViewModel.paintingImage.bind { (image) in
      paintingCell.update(with: image)
    }
  }
}

// Camera processing / Photo-related
extension PaintingsListController {
  @IBAction func takePhoto(_ sender: AnyObject) {
    guard let sourceType = firstSourceTypeAvailable() else {
      print("No photo sources available")
      return
    }
    
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = sourceType
    imagePicker.delegate = self
    self.present(imagePicker, animated: true, completion: nil)
  }
  
  private func firstSourceTypeAvailable() -> UIImagePickerControllerSourceType? {
    let sourceTypes: [UIImagePickerControllerSourceType] = [.camera, .photoLibrary]
    
    return sourceTypes.first(where: { (sourceType) -> Bool  in
      return UIImagePickerController.isSourceTypeAvailable(sourceType)
    })
  }
  
  private func filterImage(_ image: UIImage) -> UIImage {
//    return image
    
    var ciImage = CoreImage.CIImage(cgImage: image.cgImage!)
    var filter = CIFilter(name: "CILineOverlay",
                          withInputParameters: [
                            "inputImage": ciImage,
                            "inputNRNoiseLevel": 0.07, // 0.07
                            "inputNRSharpness": 0.31, // 0.71
                            "inputEdgeIntensity": 0.5, // 1.0
                            "inputThreshold": 0.1, // 0.1
                            "inputContrast": 10.0 // 50
    ])

    filter?.setDefaults()
    let context = CIContext(options:nil)
    var outputCiImage = context.createCGImage(filter!.outputImage!, from: filter!.outputImage!.extent)
    ciImage = CoreImage.CIImage(cgImage: outputCiImage!)

    
//    var filter = CIFilter(name: "CIColorPosterize",
//                           withInputParameters: [
//                            "inputImage": ciImage
//    ])
//
//    var outputCiImage = context.createCGImage(filter!.outputImage!, from: filter!.outputImage!.extent)
//    ciImage = CoreImage.CIImage(cgImage: outputCiImage!)
//
//
    let ciWhite = CIColor(red: 1, green: 1, blue: 1)
    filter = CIFilter(name: "CIColorMonochrome",
                           withInputParameters: [
                            "inputImage": ciImage,
                            "inputIntensity": 1,
                            "inputColor": ciWhite
    ])

    outputCiImage = context.createCGImage(filter!.outputImage!, from: filter!.outputImage!.extent)
//
    
    
    let outputImage = UIImage(cgImage: outputCiImage!)
    
    // Doesn't seem to work!?!?!?!?!
    let opaqueImage = outputImage.withAlpha(1)!
    
    return opaqueImage
  }
}

extension PaintingsListController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
    
    let newPainting = Services.paintingService.create()
    
    let filteredImage = filterImage(pickedImage)
    
    Services.paintingService.saveDataAndImage(newPainting, filteredImage)
    
    dismiss(animated:true, completion: nil)
    
    collectionView.reloadData()
  }
}
