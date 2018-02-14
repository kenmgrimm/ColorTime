import UIKit

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
