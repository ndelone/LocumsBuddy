//
//  PhotoViewController.swift
//  LocumsBuddy2
//
//  Created by ND on 4/9/20.
//  Copyright © 2020 ND. All rights reserved.
//

import UIKit

class PhotoViewClass: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //Need to set imageURL and imageName
    var imageURL: URL?
    var imageName: String = ""
    var imagePicker: UIImagePickerController!
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //@IBOutlet weak var loadImageView: UIImageView!
    weak var loadImageView: UIImageView!
    override func viewWillAppear(_ animated: Bool) {
        loadButtonPressedDone(displayImage: loadImageView)
    }
    
    
    //MARK: - Save/load button pressed alert menu
    
    
    func saveButtonPressedDone() {
        
        let alert = UIAlertController(title: "Add Photo", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { (UIAlertAction) in
            self.selectImageFrom(.photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Take a photo", style: .default, handler: { (UIAlertAction) in
            self.selectImageFrom(.camera)
        }))
        
        if let imagePath = imageURL?.appendingPathComponent(imageName).path {
            if FileManager.default.fileExists(atPath: imagePath) {
                alert.addAction(UIAlertAction(title: "Delete photo", style: .default, handler: { (UIAlertAction) in
                    do {
                        try FileManager.default.removeItem(atPath: imagePath)
                        print("Removed old image")
                        self.loadImageView.image = UIImage(systemName: "photo")
                    } catch let removeError {
                        print("couldn't remove file at path", removeError)
                    }
                }))
            }
        }
                
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated:true, completion: nil)
    }
    
    func loadButtonPressedDone(displayImage: UIImageView) {
        if let imageToDisplay = loadImageFromDiskWith(fileName: imageName) {
            displayImage.image = imageToDisplay
        }
    }
    
    
    //MARK: - Save photo functions
    
    func saveImage(imageName: String, image: UIImage) {
        
        if let imagePath = imageURL?.appendingPathComponent(imageName).path {
            
            guard let data = image.jpegData(compressionQuality: 0.15) else { return }
            //        Checks if file exists, removes it if so.
            if FileManager.default.fileExists(atPath: imagePath) {
                do {
                    try FileManager.default.removeItem(atPath: imagePath)
                    print("Removed old image")
                } catch let removeError {
                    print("couldn't remove file at path", removeError)
                }
            }
            
            let imageURL = URL(fileURLWithPath: imagePath)
            do {
                try data.write(to: imageURL)
            } catch let error {
                print("error saving file with error", error)
            }
        }
        loadImageView.image = loadImageFromDiskWith(fileName: imageName)
    }
    
    
    //MARK: - Load image
    
    func loadImageFromDiskWith(fileName: String) -> UIImage? {
        if let dirPath = imageURL?.path {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image
        }
        return nil
    }
    
    
    //MARK: - Select image
    
    func selectImageFrom(_ source: ImageSource){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            print("Didn't get the photo")
            return dismiss(animated: true, completion: nil)
        }
        saveImage(imageName: imageName, image: image)
        return dismiss(animated: true, completion: nil)
    }
}
