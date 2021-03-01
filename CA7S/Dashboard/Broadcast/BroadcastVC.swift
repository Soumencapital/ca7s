//
//  BroadcastVC.swift
//  CA7S
//

import UIKit

class BroadcastVC: UIViewController {

    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var btnGoLive: UIButton!
    
    @IBOutlet weak var lblInstruction: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnMenu.addTarget(self, action:#selector(SSASideMenu.presentLeftMenuViewController), for: .touchUpInside)
        
        SetUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func SetUI() {
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        btnGoLive.layer.cornerRadius = btnGoLive.layer.frame.size.height / 2
        btnGoLive.clipsToBounds = true
    }

    //MARK:- Button Actions
    
    @IBAction func btnAddBroadcast(_ sender: Any){
        self.PushToController(StroyboardName: "Dashboard", "Broadcast_RequestVC") 
    }

    @IBAction func btnGoLive(_ sender: Any){
        self.PushToController(StroyboardName: "Dashboard", "Broadcast_JoinVC")
    }
}
