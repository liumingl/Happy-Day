//
//  ViewController.swift
//  Happy Day
//
//  Created by 铭刘 on 16/6/19.
//  Copyright © 2016年 铭刘. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Speech

class ViewController: UIViewController {
  
  @IBOutlet weak var helpLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func requestPermissions(_ sender: AnyObject) {
    requestPhotosPermissions()
  }
  
  func requestPhotosPermissions() {
    PHPhotoLibrary.requestAuthorization { [unowned self] authStatus
      in
      DispatchQueue.main.async {
        if authStatus == .authorized {
          self.requestRecordPermissions()
        } else {
          self.helpLabel.text = "Photos permission was declined; please enable it in settings then tap Continue again."
        }
      }
    }
  }
  
  func requestRecordPermissions() {
    AVAudioSession.sharedInstance().requestRecordPermission { (allowed) in
      DispatchQueue.main.async{
        if allowed {
          self.requestTranscribePermissions()
        }else {
          self.helpLabel.text = "Recording permission was declined; please enable it in settings then tap Continue again."
        }
      }
    }
  }
  
  func requestTranscribePermissions() {
    SFSpeechRecognizer.requestAuthorization { (authStatus) in
      DispatchQueue.main.async(execute: { 
        if authStatus == .authorized {
          self.authorizationComplete()
        }else {
          self.helpLabel.text = "Transcription permission was declined; please enable it in settings then tap Continue again."
        }
      })
    }
  }
  
  func authorizationComplete() {
    dismiss(animated: true)
  }
  
}
