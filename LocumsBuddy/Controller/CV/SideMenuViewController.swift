//
//  SideMenuViewController.swift
//  LocumsBuddy2
//
//  Created by ND on 4/6/20.
//  Copyright © 2020 ND. All rights reserved.
//

import UIKit
import MessageUI

class SideMenuViewController: UITableViewController, MFMailComposeViewControllerDelegate, UITextFieldDelegate {
    var textField = UITextField()
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        guard let textFieldText = textField.text,
//            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
//                return false
//        }
//        let substringToReplace = textFieldText[rangeOfTextToReplace]
//        let count = textFieldText.count - substringToReplace.count + string.count
//        return count <= 5
//    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 1
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        textField.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            //weak var pvc = self.presentingViewController?.children[1] as? CVViewController
            chooseWaterMark()
        case 1:
            print("You selected 1")
            sendEmail()
        default:
            print("No selection")
        }
    }
    
    
    func chooseWaterMark(){
       // var textField = UITextField()

        let alert = UIAlertController(title: "What text would you like to watermark your CV?", message: "(The watermark will disappear after you return to the starting screen)", preferredStyle: .alert)
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("BaseCV.pdf")
        

        if FileManager.default.fileExists(atPath: documentURL.path) {
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "ABEM General ONLY"
                self.textField = alertTextField
            }
            let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                waterMark = NSString(string: self.textField.text!)
                print(waterMark)
                weak var pvc = self.presentingViewController?.children[1] as? CVViewController
                pvc?.loadDocument(documentURL: documentURL)
                self.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(action)
        } else {
            alert.title = "You need to upload a CV first!"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        print("Dismiss 2")
        
        dismiss(animated: true, completion: nil)
    }
    
    func sendEmail(){
        
        let manager = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            //mail.setToRecipients(["test@gmail.com"])
            mail.setSubject("CV attached for exclusive site presentation")
            mail.setMessageBody("Please find my attached CV, exclusively for single site presentation", isHTML: true)
            mail.mailComposeDelegate = self
            //add attachment
            weak var pvc = self.presentingViewController?.children[1] as? CVViewController
            pvc?.saveDocument(saveName: "CVToSend.pdf")
            print("Document saved")
            let filePath = manager.appendingPathComponent("CVToSend.pdf").path
            //if let filePath = Bundle.main.path(forResource: "Sample", ofType: "pdf") {
            if let data = NSData(contentsOfFile: filePath) {
                mail.addAttachmentData(data as Data, mimeType: "application/pdf" , fileName: "CVToSend.pdf")
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                } catch  {
                    print("Unable to delete file")
                }
                present(mail, animated: true, completion: nil)
            }
            else {
                print("Email cannot be sent")
                dismiss(animated: true, completion: nil)
            }
        }
    }
}

