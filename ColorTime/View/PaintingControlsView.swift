import UIKit

class PaintingControlsView : UIView {
  var paintingViewModel: PaintingViewModel!
  
  @IBOutlet var clearButton: UIView!
  @IBOutlet var undoButton: UIView!
  
  func load(_ paintingViewModel: PaintingViewModel) {
    self.paintingViewModel = paintingViewModel
    
    let undoTapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(undo(_:)))
    
    undoButton.addGestureRecognizer(undoTapRecognizer)
    
    let clearTapRecognizer = UITapGestureRecognizer(target: self,
                                               action: #selector(clear(_:)))
    
    clearButton.addGestureRecognizer(clearTapRecognizer)
  }

  @objc private func undo(_ sender: AnyObject?) {
    paintingViewModel.undoLastPoint()
  }
  
  @objc private func clear(_ sender: AnyObject?) {
//    paintingViewModel.clear()
  }
}
