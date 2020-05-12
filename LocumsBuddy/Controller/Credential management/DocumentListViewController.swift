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
    let pictureWidth = 200
    let pictureHeight = 200
    
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
        documentString += iterateEmployerList()
        documentString += iterateHealthList()
        documentString += iterateCMEList()
        //Generate HTML file
        makeHtml(stringHTML: documentString)
        //Save as PDF
        //Display
        
        self.makeWebView()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0){
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
        let stateList = realm.objects(LicenseRepository.self).first?.stateChoiceList.filter("name != %@ &&  shouldAppearInPicker == %@","National",false).sorted(byKeyPath: "name", ascending: true)
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
            string += "<h2>\(stateName) \(license.name) License</h2>License number: \(licenseNumber)<br />License issued: \(issueDateString)<br />License expires: \(expirationDateString)<br />"
            let imagePath = getLicenseImagePath(selectedLicense: license)
            print(imagePath)
            if (FileManager.default.fileExists(atPath: imagePath.path)) {
                print("file exists!")
                string += "<p><img src=\"\(imagePath)\" width=\"\(pictureWidth)\" height=\"\(pictureHeight)\"></p>"
            }
        }
        return string
    }
    
    
    func iterateNationalList() -> String{
        var nationalLicenseString = "<h1>National Licenses</h1>"
        guard let nationalLicenses = (realm.objects(State.self).filter("name == %@","National").first?.licenseList) else {return nationalLicenseString}
        for license in nationalLicenses {
            nationalLicenseString += licenseStringAddition(license: license, stateName: "")
        }
        
        return nationalLicenseString
    }
    
    func iterateEmployerList() -> String {
        var employerString = "<h1>Previous Employers</h1>"
        guard let employerList = realm.objects(LicenseRepository.self).first?.employerList else { return "" }
        for employer in employerList{
            if let startDate = employer.startDate, let endDate = employer.endDate{
                employerString += "<p>Employer name: \(employer.name!)<br />Position: \(employer.position)<br />Start date: \(formatDate(startDate))<br />End date: \(formatDate(endDate))<br />Chairperson: \(employer.departmentChair)<br />Address: \(employer.address)<br />Contact number: \(employer.phone)<br />\(employer.comment != "" ? "Comments: \(employer.comment)" : "")</p>"
            }
        }
        return employerString
    }
    
    func iterateHealthList() -> String{
        var healthString = "<h1>Health Clearance Documents</h1>"
        guard let healthList = realm.objects(LicenseRepository.self).first?.healthList else { return "" }
        for document in healthList{
            let imageURL = getHealthDocumentPath(selectedDocument: document)
            print(imageURL)
            healthString += "<p>Document name: \(document.name)<br />Comments: \(document.comment!)"
            if (FileManager.default.fileExists(atPath: imageURL.path)) {
                print("file exists!")
                healthString += "<p><img src=\"\(imageURL)\" width=\"\(pictureWidth)\" height=\"\(pictureHeight)\"></p>"
            }
        }
        return healthString
    }
    
    
    func iterateCMEList() -> String{
        var cmeString = "<h1>CME</h1>"
        guard let cmeList = realm.objects(LicenseRepository.self).first?.cmeList else { return "" }
        for cme in cmeList{
            let imageURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("CME/\(cme.name).jpeg")
            print(imageURL)
            cmeString += "<p>CME Name: \(cme.name)<br />Comments: \(cme.comment)<br />Issue date: \(formatDate(cme.issueDate ?? Date()))<br />Credits: \(cme.creditAmount) \(cme.creditType) credits."
            if (FileManager.default.fileExists(atPath: imageURL.path)) {
                cmeString += "<p><img src=\"\(imageURL)\" width=\"\(pictureWidth)\" height=\"\(pictureHeight)\"></p>"
            }
        }
        return cmeString
    }
    
    func formatDate(_ date : Date) -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMMM dd, yyyy"
        let formattedDateString = dateFormatterPrint.string(from: date)
        return formattedDateString
    }
    
    
    //MARK: - HTML construction
    
    
    
    
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
 //       let savingPathString = selectedLicense.savingPath
//        let fileManager = FileManager.default
//        let documentsURL =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let imageurl = documentsURL.appendingPathComponent(savingPathString)
//        let imageName = "\(selectedLicense.name).jpeg"
//        let imagePath = imageurl.appendingPathComponent(imageName)
        let imageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(selectedLicense.savingPath)/\(selectedLicense.name).jpeg")
        return imageURL
    }
    
    func getHealthDocumentPath(selectedDocument: HealthDocument) -> URL{
        let fileManager = FileManager.default
        let documentsURL =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        var imageURL = documentsURL.appendingPathComponent("Health")
        let imageName = "\(selectedDocument.name).jpeg"
        imageURL = imageURL.appendingPathComponent(imageName)
        return imageURL
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
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
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
