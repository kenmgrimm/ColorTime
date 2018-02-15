import Foundation

class FileService {
  static func getDocumentsURL() -> URL {
    if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
      return url
    } else {
      fatalError("Could not retrieve documents directory")
    }
  }
  
  static func getDataURL(filePath: String) -> URL? {
    let path = URL(fileURLWithPath: "\(Bundle.main.bundlePath)/Data/\(filePath)")

    return path
  }
}
