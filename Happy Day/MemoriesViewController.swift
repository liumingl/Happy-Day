//
//  MemoriesViewController.swift
//  Happy Day
//
//  Created by 铭刘 on 16/6/19.
//  Copyright © 2016年 铭刘. All rights reserved.
//

import UIKit

class MemoriesViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  var memories = [URL]()
  

    override func viewDidLoad() {
        super.viewDidLoad()

        loadMemories()
      
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func loadMemories() {
    memories.removeAll()
    
    guard let files = try? FileManager.default().contentsOfDirectory(at: getDocumentsDirectory(), includingPropertiesForKeys: nil, options: []) else { return }
    
    for file in files {
      guard let filename = file.lastPathComponent else { continue }
      
      if filename.hasSuffix(".thumb") {
        let noExtension = filename.replacingOccurrences(of: ".thumb", with: "")
        
        if let memoryPath = try? getDocumentsDirectory().appendingPathComponent(noExtension) {
          memories.append(memoryPath)
        }
      }
    }
  }
  
  func addTapped(){
    let vc = UIImagePickerController()
    vc.modalPresentationStyle = .formSheet
    vc.delegate = self
    navigationController?.present(vc, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    dismiss(animated: true, completion: nil)
    
    if let possibleImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      saveNewMemory(image: possibleImage)
      loadMemories()
    }
  }
  
  func resizeImage(image: UIImage, to width: CGFloat) -> UIImage? {
    // calculate how much we need to bring the width down to match our target size
    let scale = width / image.size.width
    
    // bring the height down by the same amount so that the aspect ratio is preserved
    let height = image.size.height * scale
    
    // create a new image context we can draw into
    UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
    
    // draw the original image into the context
    image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
    
    // pull out the resized version
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    
    // end the context so UIKit can clean up
    UIGraphicsEndImageContext()
    
    // send it back to the caller
    return newImage
  }
  
  func saveNewMemory(image: UIImage) {
    // create a unique name for this memory
    let memoryName = "memory-\(Date().timeIntervalSince1970)"
    
    // use the unique name to create filenames for the full-size image and the thumbnail
    let imageName = memoryName + ".jpg"
    let thumbnailName = memoryName + ".thumb"
    
    do {
      // create a URL where we can write the JPEG to
      let imagePath = try getDocumentsDirectory().appendingPathComponent(imageName)
      
      // convert the UIImage into a JPEG data object
      if let jpegData = UIImageJPEGRepresentation(image, 80) {
        // write that data to the URL we created
        try jpegData.write(to: imagePath, options: [.atomicWrite])
      }
      
      // create thumbnail here
      if let thumbnail = resizeImage(image: image, to: 200) {
        let imagePath = try getDocumentsDirectory().appendingPathComponent(thumbnailName)
        
        if let jpegData = UIImageJPEGRepresentation(thumbnail, 80) {
          try jpegData.write(to: imagePath, options: [.atomicWrite])
        }
      }
      
    }catch {
      print("Failed to save to disk.")
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Memory", for: indexPath) as! MemoryCell
    
    let memory = memories[indexPath.row]
    let imageName = thumbnailURL(for: memory).path ?? ""
    let image = UIImage(contentsOfFile: imageName)
    cell.imageView.image = image
    
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,referenceSizeForHeaderInSection section: Int) -> CGSize {
    if section == 1 {
      return CGSize.zero
    } else {
      return CGSize(width: 0, height: 50)
    }
  }
  
  func getDocumentsDirectory() -> URL {
    let paths = FileManager.default().urlsForDirectory(.documentDirectory, inDomains: .userDomainMask)
    
    let documentsDirectory = paths[0]
    
    return documentsDirectory
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if section == 0 {
      return 0
    }else {
      return memories.count
    }
  }
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 2
  }
  
  func imageURL(for memory: URL) -> URL {
    return try! memory.appendingPathExtension("jpg")
  }
  
  func thumbnailURL(for memory: URL) -> URL {
    return try! memory.appendingPathExtension("thumb")
  }
  
  func audioURL(for memory: URL) -> URL {
    return try! memory.appendingPathExtension("m4a")
  }
  
  func transcriptionURL(for memory: URL) -> URL {
    return try! memory.appendingPathExtension("txt")
  }
  
}
