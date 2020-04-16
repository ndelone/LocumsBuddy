import UIKit
import PDFKit


public var waterMark: NSString = ""
class CVViewController: UIViewController, PDFDocumentDelegate {
    let manager = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    @IBOutlet weak var pdfView: PDFView?

    /// - Tag: SetDelegate
    
    override func viewDidDisappear(_ animated: Bool) {
        waterMark = ""
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteSentCV()
        print("Directory is \(Bundle.main.bundleURL)")
        
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("BaseCV.pdf")
        print(manager.path)

        //If opening PDF from other app, will replace current BaseCV
        if  shouldPushCV{
            guard let documentURL = appDelegateURL else {return}
            loadDocument(documentURL: documentURL)
            saveDocument(saveName: "BaseCV.pdf")
            print("Saved PDF opened by web")
            shouldPushCV = false
            //If a 'base' PDF exists that user has uploaded before, will be loaded.
        } else if FileManager.default.fileExists(atPath: documentURL.path) {
            loadDocument(documentURL: documentURL)
        } else {
            //No CV Selected, displays default message.
            if let documentURL = Bundle.main.url(forResource: "NothingHere", withExtension: "pdf") {
                
                
                // Create Attachment
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = UIImage(systemName:"square.and.arrow.up")
                // Set bound to reposition
                let imageOffsetY: CGFloat = 0.0
                imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
                // Create string with attachment
                let attachmentString = NSAttributedString(attachment: imageAttachment)
                // Initialize mutable string
                let iconString = NSMutableAttributedString(string: "")
                // Add image to mutable string
                iconString.append(attachmentString)
                
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 350, height: 300))
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
                label.center = CGPoint(x: 200, y: 385)
                
                let string = NSMutableAttributedString(string: "To upload a CV,\n\n 1) Open up your CV as a PDF (by emailing it to yourself, or opening it online) \n\n 2) Select the export icon   ")
                string.append(iconString)
                let secondString = NSMutableAttributedString(string: "\n\n 3) Select 'Copy to LocumsBuddy' or 'More' if that is not available. \n\n 4) Your CV should appear here.")
                string.append(secondString)
                label.attributedText = string
                label.sizeToFit()
                self.view.addSubview(label)
            }
        }
    }
    
    //MARK: - Data loading

    
    func loadDocument(documentURL : URL){
        if let document = PDFDocument(url: documentURL) {
            // Center document on gray background
            pdfView?.autoScales = true
            pdfView?.backgroundColor = UIColor.lightGray
            
            // 1. Set delegate
            document.delegate = self
            pdfView?.document = document
        }
    }
    
    func saveDocument(saveName: String){
        let manager = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print("Absolute string: \(manager.absoluteString)")
        pdfView?.document?.write(to: manager.appendingPathComponent(saveName))
    }
    
    func deleteSentCV(){
        let manager = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let watermarkedCV = manager.appendingPathComponent("CVToSend.PDF")
        print("Absolute string: \(watermarkedCV.absoluteString)")
        do {
            try FileManager.default.removeItem(at: watermarkedCV)
        } catch {
            print("Error deleting sent CV")
        }
    }
    
    // 2. Return your custom PDFPage class
    /// - Tag: ClassForPage
    func classForPage() -> AnyClass {
        return WatermarkPage.self
    }
}

class WatermarkPage: PDFPage{
    
    
    // 3. Override PDFPage custom draw
    /// - Tag: OverrideDraw
    override func draw(with box: PDFDisplayBox, to context: CGContext) {
        // Draw original content
        super.draw(with: box, to: context)
        
        // Draw rotated overlay string
        UIGraphicsPushContext(context)
        context.saveGState()
        
        let pageBounds = self.bounds(for: box)
        context.translateBy(x: 0.0, y: pageBounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.rotate(by: CGFloat.pi / 4.0)
        let string: NSString = waterMark//"Exclusive Presentation for Binghampton"
        let boundingRectangle = CGRect(origin: CGPoint(x: 200, y: 40), size: CGSize(width: 600, height: 200))
        let area:CGFloat = boundingRectangle.width * boundingRectangle.height
        let optimalFontSize = sqrt(area / CGFloat(string.length))
        
        
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 0.3),
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: optimalFontSize)
        ]
        string.draw(with: boundingRectangle, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        context.restoreGState()
        UIGraphicsPopContext()
    }
}



