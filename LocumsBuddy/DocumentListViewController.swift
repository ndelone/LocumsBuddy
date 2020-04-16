//
//  DocumentListViewController.swift
//  LocumsBuddy
//
//  Created by ND on 4/13/20.
//  Copyright © 2020 ND. All rights reserved.
//

import UIKit
import RealmSwift
import WebKit
import PDFKit
import MessageUI

class DocumentListViewController: UIViewController, PDFDocumentDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pdfView: PDFView?
    private let webView = WKWebView()
    private let spinner = UIActivityIndicatorView()
    let realm = try! Realm()
    private var pdfFile: String?
    var documentsDirectoryURL : URL?
    let documentURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first)!
    lazy var defaultPath = (documentURL.appendingPathComponent("CredentialingList.pdf"))
    let group = DispatchGroup()
    
    @IBAction func emailButtonPressed(_ sender: UIBarButtonItem) {
        sendEmail()
        print("Email button pressed")
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Generat a list of licenses
        var documentString = ""
        // generateLists()
        //Iterate through list, adding data to document
        documentString += iterateStateList(stateList : generateLists())
        documentString += iterateNationalList()
        //Generate HTML file
        makeHtml(stringHTML: documentString)
        //Save as PDF
        //Display

            self.makeWebView()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
            self.activityIndicator.stopAnimating()
            if let document = PDFDocument(url: self.defaultPath) {
                // Center document on gray background
                self.pdfView?.autoScales = true
                self.pdfView?.backgroundColor = UIColor.lightGray

                // 1. Set delegate
                document.delegate = self
                self.pdfView?.document = document
            }
        }

        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.webView.load(URLRequest(url: documentsDirectoryURL!))
    }
    override func viewDidAppear(_ animated: Bool) {
        //        self.webView.load(URLRequest(url: documentURL!))
    }
    
    
    func generateLists() -> Results<State>{
        let stateList = realm.objects(LicenseRepository.self).first?.stateChoiceList.filter("shouldAppearInPicker == %@",false).sorted(byKeyPath: "name", ascending: true)
        print(stateList)
        return stateList!
    }
    
    func iterateStateList(stateList : Results<State>) -> String{
        var stateLicenseString = "<h1>State Licenses</h1>"
        for state in stateList{
            //validate states as having data
            for license in state.licenseList{
                stateLicenseString += licenseStringAddition(license: license, stateName: "\(state.name) State")
            }
        }
        return stateLicenseString
    }
    
    func licenseStringAddition(license : License, stateName : String) -> String{
        var string = ""
        if let licenseNumber = license.licenseNumber, let issueDate = license.issueDate, let expirationDate = license.expirationDate {
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMMM dd, yyyy"
            let expirationDateString = dateFormatterPrint.string(from: expirationDate)
            let issueDateString = dateFormatterPrint.string(from: issueDate)
            //if so, add to a html string
            string += "<h2>\(stateName) \(license.licenseType) License</h2>License number: \(licenseNumber)<br />License issued: \(issueDateString)<br />License expires: \(expirationDateString)<br />"
            let imagePath = getLicenseImagePath(selectedLicense: license)
            print(imagePath)
            if (FileManager.default.fileExists(atPath: imagePath.path)) {
                print("file exists!")
                string += "<p><img src=\"\(imagePath)\" width=\"360\" height=\"240\"></p>"
            }
        }
        return string
    }
    
    
    func iterateNationalList() -> String{
        var nationalLicenseString = "<h1>National Licenses</h1>"
        if let nationalList = realm.objects(LicenseRepository.self).first?.nationalLicenseList{
            for license in nationalList {
                nationalLicenseString += licenseStringAddition(license: license, stateName: "")
            }
        }
        return nationalLicenseString
    }
    
    func makeHtml(stringHTML : String){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        documentsDirectoryURL = documentsDirectory?.appendingPathComponent("sample.html")
        do {
            try stringHTML.write(to: documentsDirectoryURL!, atomically: false, encoding: .utf8)
        } catch {
            print("Error saving string")
        }
    }
    
    
    func makeWebView(){
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.navigationDelegate = self
        self.webView.isHidden = true
        self.view.addSubview(self.webView)
        
        //
        
        let viewDict: [String: AnyObject] = [
            "webView": self.webView,
            "top": self.topLayoutGuide
        ]
        let layouts = [
            "H:|[webView]|",
            "V:[top][webView]|"
        ]
        for layout in layouts {
            let constraints = NSLayoutConstraint.constraints(withVisualFormat: layout, options: [], metrics: nil, views: viewDict)
            self.view.addConstraints(constraints)
        }
    }
    
}

extension DocumentListViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        NSLog("didFinishNavigation")
        
        //         Sometimes, this delegate is called before the image is loaded. Thus we give it a bit more time.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let path = self.createPDF(formatter: webView.viewPrintFormatter(), filename: "CredentialingList")
            print("PDF location: \(path)")
            self.pdfFile = path
        }
    }
    
    func getLicenseImagePath(selectedLicense : License) -> URL{
        let savingPathString = selectedLicense.savingPath
        let fileManager = FileManager.default
        let documentsURL =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageURL = documentsURL.appendingPathComponent(savingPathString)
        let imageName = selectedLicense.licenseType + " Photo"
        let imagePath = imageURL.appendingPathComponent(imageName)
        return imagePath
    }
    
    
    func createPDF(formatter: UIViewPrintFormatter, filename: String) -> String {
        // 2. Assign print formatter to UIPrintPageRenderer
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(formatter, startingAtPageAt: 0)
        
        // 3. Assign paperRect and printableRect
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        let printable = page.insetBy(dx: 0, dy: 0)
        
        render.setValue(NSValue(cgRect: page), forKey: "paperRect")
        render.setValue(NSValue(cgRect: printable), forKey: "printableRect")
        
        // 4. Create PDF context and draw
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData,  CGRect(x: 0, y: 0, width: 595.2, height: 841.8), nil)
        
        for i in 1...render.numberOfPages {
            
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: i - 1, in: bounds)
        }
        
        UIGraphicsEndPDFContext()
        
        // 5. Save PDF file
        var documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let defaultPath = (documentURL?.appendingPathComponent("\(filename).pdf").path)!
        
        DispatchQueue.main.async {
            pdfData.write(toFile: defaultPath, atomically: true)
        }
        
        return defaultPath
    }
}

//MARK: - Email

extension DocumentListViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    func sendEmail(){
        print(defaultPath.path)
        let manager = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.setSubject("CV attached for exclusive site presentation")
            mail.setMessageBody("Please find my attached CV, exclusively for single site presentation", isHTML: true)
            mail.mailComposeDelegate = self
            //add attachment
            let filePath = defaultPath.path
            //if let filePath = Bundle.main.path(forResource: "Sample", ofType: "pdf") {
            if let data = NSData(contentsOfFile: filePath) {
                mail.addAttachmentData(data as Data, mimeType: "application/pdf" , fileName: "CredentialingList.pdf")
                present(mail, animated: true, completion: nil)
            }
            else {
                print("Email cannot be sent")
                dismiss(animated: true, completion: nil)
            }
        }
    }
}
