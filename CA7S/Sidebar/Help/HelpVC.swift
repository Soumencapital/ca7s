//
//  HelpVC.swift
//  CA7S
//

import UIKit

class HelpVC: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnMenu.addTarget(self, action:#selector(SSASideMenu.presentLeftMenuViewController), for: .touchUpInside)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        CallWebView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setLocalizationString()
    }
    
    func setLocalizationString(){
        self.lblTitle.text = NSLocalizedString("Help", comment: "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func CallWebView() {
        
        if (UserDefaults.standard.string(forKey: Constant.AppLanguage)) == "English" {
            let url = NSURL (string: "https://www.ca7s.com/ca7s/public/help?lang=eng")
            
            let requestObj = URLRequest(url: url! as URL)
            webView.loadRequest(requestObj)
        }else{
            let url = NSURL (string: "https://www.ca7s.com/ca7s/public/help?lang=port")
            let requestObj = URLRequest(url: url! as URL)
            webView.loadRequest(requestObj)
        }
        
        
        
    }
}
