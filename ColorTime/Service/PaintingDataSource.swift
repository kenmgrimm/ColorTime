import UIKit

class PaintingDataSource: NSObject, UICollectionViewDataSource {
  var paintings = [Painting]()
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    print(#function)
    print(PaintingFileService().load().count)
    return PaintingFileService().load().count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PaintingCollectionViewCell", for: indexPath)
    print(#function)
    return cell
  }
}
