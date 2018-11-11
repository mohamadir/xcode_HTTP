//
//  RolesViewController.swift
//  Snapgroup
//
//  Created by snapmac on 5/22/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import SwiftHTTP


extension String {
    
    var utfData2: Data? {
        return self.data(using: .utf8)
    }
    
    var attributedHtmlString2: NSAttributedString? {
        guard let data = self.utfData2 else {
            return nil
        }
        do {
            return try NSAttributedString(data: data,
                                          options: [
                                            .documentType: NSAttributedString.DocumentType.html,
                                            .characterEncoding: String.Encoding.utf8.rawValue
                ], documentAttributes: nil)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

extension UITextView {
    func setHtmlText(_ html: String) {
        let modifiedFont = NSString(format:"<span style=\"font-family: \(self.font!.fontName); font-size: \(self.font!.pointSize)\">%@</span>" as NSString, html)
        
        let attrStr = try! NSAttributedString(
            data: modifiedFont.data(using: String.Encoding.unicode.rawValue, allowLossyConversion: true)!,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil)
        
        self.attributedText = attrStr
    }
}

class RolesViewController: UIViewController {

   

    
    @IBOutlet weak var textview: UITextView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textview.isEditable = false
        
        var _: String = """
            <ul>
              <li>Coffee</li>
              <li>Tea</li>
              <li>Milk</li>
            </ul>
            """
        if MyVriables.currentGroup?.group_conditions != nil {
            textview.setHtmlText((MyVriables.currentGroup?.group_conditions!)!)
        }
        // Do any additional setup after loading the view.
    }

}
