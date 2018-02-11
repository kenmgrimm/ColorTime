import UIKit

class PaletteHistoryView : UICollectionView, UICollectionViewDelegate {
  var paintingViewModel: PaintingViewModel!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    self.delegate = self
  }

  func collectionView(_ collectionView: UICollectionView,
                      didSelectItemAt indexPath: IndexPath) {
    paintingViewModel.selectColorFromPalette(at: indexPath.item)
  }
}
