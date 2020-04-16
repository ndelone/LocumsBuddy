//
//  PhotoViewController.swift
//  LocumsBuddy2
//
//  Created by ND on 4/9/20.
//  Copyright © 2020 ND. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBOutlet weak var loadImageView: UIImageView!
    override func viewWillAppear(_ animated: Bool) {
        loadButtonPressedDone(displayImage: loadImageView)
    }
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        saveButtonPressedDone(sender)
    }
    
    var imageURL: URL?
    var imageName: String = ""
    var imagePicker: UIImagePickerController!
    enum ImageSource {
        case photoLibrary
        case camera
    }
    //Start of imported kit
    var selectedLicense : License? {
        didSet{
            if let savingPathString = selectedLicense?.savingPath {
                let fileManager = FileManager.default
                let documentsURL =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                imageURL = documentsURL.appendingPathComponent(savingPathString)
                imageName = selectedLicense!.licenseType + " Photo"
            }
        }
    }

    
    //MARK: - Save/load button pressed alert menu
    

    func saveButtonPressedDone(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Add Photo", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { (UIAlertAction) in
            self.selectImageFrom(.photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Take a photo", style: .default, handler: { (UIAlertAction) in
            self.selectImageFrom(.camera)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated:true, completion: nil)
    }
    
    func loadButtonPressedDone(displayImage: UIImageView) {
        //displayImage.image = loadImageFromDiskWith(fileName: imageName)
        if let imageToDisplay = loadImageFromDiskWith(fileName: imageName) {
            displayImage.image = imageToDisplay
        }
    }
    
    
    //MARK: - Save photo functions
    
    func saveImage(imageName: String, image: UIImage) {
        
        //guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        if let imagePath = imageURL?.appendingPathComponent(imageName).path {
            print("Path is: \(imagePath)")
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
        //let paths = [imageURL?.absoluteString]
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
