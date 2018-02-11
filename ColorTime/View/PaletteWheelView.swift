import UIKit

class PaletteWheelView : UIImageView {
  var paintingViewModel: PaintingViewModel!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    let tapRecognizer = UITapGestureRecognizer(target: self,
                                               action: #selector(PaletteWheelView.tap(_:)))
    
    addGestureRecognizer(tapRecognizer)
  }
  
  @objc func tap(_ recognizer: UITapGestureRecognizer) {
    guard recognizer.state == UIGestureRecognizerState.recognized,
      let paletteImageView = recognizer.view as! UIImageView?,
      let location = recognizer.location(in: recognizer.view) as CGPoint?
    else { return }
    
    let pixelColor = paletteImageView.image!.getPixelColor(
      atLocation: location,
      withFrameSize: paletteImageView.frame.size)
    
    paintingViewModel.addColorToPalette(pixelColor)
    
    print("PaletteView: \(location.x), \(location.y): \(pixelColor)")
  }
}
