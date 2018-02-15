import UIKit

extension PaintingsListController : UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    let paintingCell = cell as! PaintingCollectionViewCell

//    Services.paintingService.delete()
//    Services.imageService.deleteImage(for: <#T##Painting#>)
//    return
    let painting = Services.paintingService.find(paintingId: indexPath.row)!
    print(#function + "Deleting \(painting.paintingId)")


    let paintingViewModel = PaintingViewModel(painting)
    
    paintingViewModel.paintingImage.bind { (image) in
      paintingCell.update(with: image)
    }
  }
}
