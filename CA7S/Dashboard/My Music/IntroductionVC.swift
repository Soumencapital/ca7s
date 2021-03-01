//
//  IntroductionVC.swift
//  CA7S
//
//  Created by Mansi MacBook Air on 01/08/18.
//  Copyright © 2018 NP. All rights reserved.
//

import UIKit

class IntroductionVC: UIViewController {

    //OUTLETS
    
    @IBOutlet weak var lblDetails: UILabel!
    
    //MARK:-
    //MARK:- ViewController LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblDetails.backgroundColor = UIColor.red
        
        self.view.backgroundColor = UIColor.clear
        self.view.isOpaque = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
