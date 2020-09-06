//
//  PhotoViewController.swift
//  LocumsBuddy2
//
//  Created by ND on 4/9/20.
//  Copyright © 2020 ND. All rights reserved.
//

import UIKit
import ZoomImageView

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
                //If photo already exists, allow deletion or viewing.
                alert.addAction(UIAlertAction(title: "View photo", style: .default, handler: { (UIAlertAction) in
                    if let image = UIImage(contentsOfFile: imagePath) {
                        self.popUpPicture(image: image)
                    }
                }))
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
    
    
    //Method for zooming
    

    
    //Method to view popup of image
    
    func popUpPicture(image: UIImage) {
        let viewImage = UIScrollView()
        viewImage.alpha=0.0
        let viewImageController = UIViewController()
        viewImageController.view.backgroundColor = UIColor.white
        let imageView = ZoomImageView(image: image)
        viewImage.addSubview(imageView)
        
        viewImageController.view.addSubview(imageView)
        imageView.bindFrameToSuperviewBounds()
//        self.navigationController?.pushViewController(viewImageController, animated: true)
        self.present(viewImageController, animated: true, completion: nil)
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

extension UIView {
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
        
    }
}
