import UIKit

class PaintingsListController: UIViewController {
  @IBOutlet var collectionView: UICollectionView!
  
  // Must hold strong reference to data source as the collectionView.dataSource is weak..
  private let collectionDataSource = PaintingDataSource()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.dataSource = collectionDataSource
    collectionView.delegate = self
    
    updateDataSource()
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
  
  private func updateDataSource() {
    //    store.fetchAllPhotos(completion: { (photoResult) in
    //      switch photoResult {
    //      case let .success(photos):
    //        self.photoDataSource.photos = photos
    //      case .failure:
    //        self.photoDataSource.photos.removeAll()
    //      }
    //      self.collectionView.reloadSections(IndexSet(integer: 0))
    //    })
  }
}

// Paintings list related
extension PaintingsListController : UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    let paintingCell = cell as! PaintingCollectionViewCell
    
    let painting = Services.paintingService.find(paintingId: indexPath.row)!
    
    paintingCell.update(with: UIImage(fileURL: painting.imageURL()))

//    let photo = photoDataSource.photos[indexPath.row]
//
//    store.fetchImage(for: photo, completion: { (result) -> Void in
//      guard let photoIndex = self.photoDataSource.photos.index(of: photo),
//        case let .success(image) = result
//        else {
//          return
//      }
//
//      let photoIndexPath = IndexPath(item: photoIndex, section: 0)
//
//      if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
//        cell.update(with: image)
//      }
//    })
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
    return image
    
    let ciImage = CoreImage.CIImage(cgImage: image.cgImage!)
    let filter = CIFilter(name: "CILineOverlay",
                          withInputParameters: [
                            "inputNRNoiseLevel": 0.27, // 0.07
                            "inputNRSharpness": 0.31, // 0.71
                            "inputEdgeIntensity": 1.0, // 1.0
                            "inputThreshold": 1, // 0.1
                            "inputContrast": 50.0 // 50
      ])
    
    filter?.setDefaults()
    filter?.setValue(ciImage, forKey: "inputImage")
    let context = CIContext(options:nil)
    let outputCiImage = context.createCGImage(filter!.outputImage!, from: filter!.outputImage!.extent)
    
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
    let filename = newPainting.imageURL()
    
    let filteredImage = filterImage(pickedImage)
    
    print("\(#function) - Writing to \(filename)")
    if let data = UIImagePNGRepresentation(filteredImage) {
      try? data.write(to: filename)
    }
    
    Services.paintingService.save(newPainting)
    
    dismiss(animated:true, completion: nil)
    
    collectionView.reloadData()
  }
}
