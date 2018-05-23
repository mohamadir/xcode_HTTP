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
    
    var utfData: Data? {
        return self.data(using: .utf8)
    }
    
    var attributedHtmlString: NSAttributedString? {
        guard let data = self.utfData else {
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
        if let attributedText = html.attributedHtmlString {
            self.attributedText = attributedText
        }
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
        
        var htmlText: String = """
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
