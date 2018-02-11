import UIKit

class PaletteHistoryDataSource : NSObject, UICollectionViewDataSource {
  var paintingViewModel: PaintingViewModel!
  
  init(_ paintingViewModel: PaintingViewModel) {
    self.paintingViewModel = paintingViewModel
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return paintingViewModel.colorPaletteHistory.value.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PaletteHistoryItemCell", for: indexPath)
    
    let color = UIColor(rgb: paintingViewModel.colorPaletteHistory.value[indexPath.item])
    cell.backgroundColor = color
    
    return cell
  }
}
