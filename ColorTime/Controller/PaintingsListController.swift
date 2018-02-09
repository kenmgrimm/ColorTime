import UIKit

class PaintingsListController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
  
  @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
    
    let newPainting = Painting(colorPaletteHistory: [], paintPointHistory: [])
    let filename = newPainting.originalImageURL
    
    //  Filter Image
    let ciImage = CoreImage.CIImage(cgImage: pickedImage.cgImage!)
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
    let filteredImage = UIImage(cgImage: outputCiImage!)
    
    print("\(#function) - Writing to \(filename)")
    if let data = UIImagePNGRepresentation(filteredImage) {
      try? data.write(to: filename)
    }
    
    PaintingFileService().save(newPainting)
    
    dismiss(animated:true, completion: nil)
  }
}
