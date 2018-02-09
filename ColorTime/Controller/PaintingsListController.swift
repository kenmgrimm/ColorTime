import UIKit

class PaintingsListController: UIViewController {
  @IBOutlet var collectionView: UICollectionView!
  
  private let collectionDataSource = PaintingDataSource()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.dataSource = collectionDataSource
    collectionView.delegate = self
    
    updateDataSource()
    
    //    store.fetchInterestingPhotos { (photoResult) -> Void in
    //      self.updateDataSource()
    //    }
  }
}

// Paintings list related
extension PaintingsListController : UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    let paintingCell = cell as! PaintingCollectionViewCell
    
    let painting = PaintingFileService().load()[indexPath.row]
    
    let imageView = paintingCell.imageView!
    
    imageView.image = PaintingsListController.imageFromFile(filePath: painting.originalImageURL)
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
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    switch segue.identifier {
//    case "showPhoto"?:
//      if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
//        let photo = photoDataSource.photos[selectedIndexPath.row]
//
//        let destinationVC = segue.destination as! PhotoInfoViewController
//        destinationVC.photo = photo
//        destinationVC.store = store
//      }
//    default:
//      preconditionFailure("Unexpected segue identifier")
//    }
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

// Camera processing / Photo-related
extension PaintingsListController {
  @IBAction func takePhoto(_ sender: AnyObject) {
    let sourceType: UIImagePickerControllerSourceType!
    
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      sourceType = .camera
    }
    else if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      sourceType = .photoLibrary
    }
    else {
      return
    }
    
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = sourceType
    imagePicker.delegate = self
    self.present(imagePicker, animated: true, completion: nil)
  }
  
  private static func imageFromFile(filePath: URL) -> UIImage? {
    do {
      let imageData = try Data(contentsOf: filePath)
      
      return UIImage(data: imageData)
    }
    catch {
      print("Error loading image : \(error)")
    }
    return nil
  }
  
  private func filterImage(_ image: UIImage) -> UIImage {
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
    
    return UIImage(cgImage: outputCiImage!)
  }
}

extension PaintingsListController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
    
    let newPainting = PaintingFileService().create()
    let filename = newPainting.originalImageURL
    
    let filteredImage = filterImage(pickedImage)
    
    print("\(#function) - Writing to \(filename)")
    if let data = UIImagePNGRepresentation(filteredImage) {
      try? data.write(to: filename)
    }
    
    PaintingFileService().save(newPainting)
    
    dismiss(animated:true, completion: nil)
    
    collectionView.reloadData()
  }
}
