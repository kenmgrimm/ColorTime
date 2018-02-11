import UIKit

class PaintingDataSource: NSObject, UICollectionViewDataSource {
  var paintings = [Painting]()
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return Services.paintingService.all().count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PaintingCollectionViewCell", for: indexPath)

    return cell
  }
}
