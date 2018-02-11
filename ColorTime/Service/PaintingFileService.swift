import Foundation

protocol PaintingServiceProtocol {
  func all() -> Set<Painting>
  func find(paintingId: Int) -> Painting?
  func save(_ painting: Painting)
}

class PaintingFileService : PaintingServiceProtocol {
  func create() -> Painting {
    let highestPaintingId = all().sorted(by: { (a, b) -> Bool in
      a.paintingId < b.paintingId
    }).last?.paintingId ?? -1
    
    return Painting(paintingId: highestPaintingId + 1)
  }
  
  func all() -> Set<Painting> {
    let url = FileService.getDocumentsURL().appendingPathComponent("paintings.json")
    print("\(#function) - Loading: \(url.absoluteString)")
    
    let decoder = JSONDecoder()
    do {
      let data = try Data(contentsOf: url, options: [])
      
      return try Set(decoder.decode([Painting].self, from: data))
    } catch  {
      print(#function + " - paintings data file not found or corrupt")
    }
    
    return Set<Painting>()
  }
  
  func find(paintingId: Int) -> Painting? {
    return all().first(where: { (painting) -> Bool in
      painting.paintingId == paintingId
    })
  }
  
  func save(_ painting: Painting) {
    let url = FileService.getDocumentsURL().appendingPathComponent("paintings.json")
    print("\(#function) - Saving to: \(url.absoluteString)")
    
    let encoder = JSONEncoder()
    
    var paintings = all()
    
    paintings.update(with: painting)
    
    do {
      let data = try encoder.encode(paintings)
      try data.write(to: url, options: [])
      
      NotificationCenter.default.post(name:
        Notification.Name(rawValue: Painting.ColorUpdateNotification), object: self, userInfo: ["painting": painting])
      
    } catch {
      fatalError(error.localizedDescription)
    }
  }
}

