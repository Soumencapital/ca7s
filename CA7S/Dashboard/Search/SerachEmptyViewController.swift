//
//  SerachEmptyViewController.swift
//  CA7S
//
//  Created by YOGESH BANSAL on 10/10/19.
//  Copyright © 2019 Bhargav. All rights reserved.
//

import UIKit

class SerachEmptyViewController: UIViewController {
    var onTryAgain: (()->Void)!
    @IBOutlet weak var noLable: UILabel?
    @IBOutlet weak var tryAgainButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
_ = self.view
        noLable?.text = NSLocalizedString("No Results", comment: "")
      
        // Do any additional setup after loading the view.
    }
    @IBAction func dismissSelf(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        if sender.tag != 1 {
            onTryAgain()
        }
        
    }
    

    
    
    
    override func viewDidAppear(_ animated: Bool) {
     
        super.viewDidAppear(animated)
        
    }
}
