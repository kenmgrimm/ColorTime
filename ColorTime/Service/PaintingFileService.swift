import Foundation

protocol PaintingServiceProtocol {
  func load() -> [Painting]
  func save(_ painting: Painting)
}

class PaintingFileService : PaintingServiceProtocol {
  func load() -> [Painting] {
    let url = FileService.getDocumentsURL().appendingPathComponent("paintings.json")
    print("\(#function) - Loading: \(url.absoluteString)")
    
    let decoder = JSONDecoder()
    do {
      let data = try Data(contentsOf: url, options: [])
      
      return try decoder.decode([Painting].self, from: data)
    } catch {
      return [Painting(colorPaletteHistory: [], paintPointHistory: [])]
      //      fatalError(error.localizedDescription)
    }
  }
  
  func save(_ painting: Painting) {
    let url = FileService.getDocumentsURL().appendingPathComponent("paintings.json")
    print("\(#function) - Saving to: \(url.absoluteString)")
    
    let encoder = JSONEncoder()
    
    do {
      let data = try encoder.encode([painting])
      try data.write(to: url, options: [])
      
      NotificationCenter.default.post(name:
        Notification.Name(rawValue: Painting.ColorUpdateNotification), object: self, userInfo: ["painting": painting])
      
    } catch {
      fatalError(error.localizedDescription)
    }
  }
}

