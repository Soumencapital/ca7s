//
//  TermsAndConditionVC.swift
//  CA7S
//

import UIKit

class TermsAndConditionVC: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var screen_id: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnMenu.addTarget(self, action:#selector(SSASideMenu.presentLeftMenuViewController), for: .touchUpInside)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        CallWebView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if screen_id == 0{
            self.setLocalizationString(str: NSLocalizedString("T&S", comment: ""))
        }else{
            self.setLocalizationString(str: NSLocalizedString("Privacy_policy", comment: ""))
        }
    }
    
    func setLocalizationString(str: String){
        self.lblTitle.text = str as String
        //NSLocalizedString("T&S", comment: "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func CallWebView() {
        
        var url = NSURL()
        
        if screen_id == 0{
            
            if (UserDefaults.standard.string(forKey: Constant.AppLanguage)) == "English" {
                    url = NSURL (string: "https://www.ca7s.com/ca7s/terms_condition?lang=eng")!
            }else{
                url = NSURL (string: "https://www.ca7s.com/ca7s/terms_condition?lang=port")!
            }
        }else{
            
            
            if (UserDefaults.standard.string(forKey: Constant.AppLanguage)) == "English" {
                    url = NSURL (string: "https://www.ca7s.com/ca7s/privacy_policy?lang=eng")!
            }else{
                url = NSURL (string: "https://www.ca7s.com/ca7s/privacy_policy?lang=port")!
            }
        }
        
//        let url = NSURL (string: "https://www.ca7s.com/ca7s/terms_condition")
        let requestObj = URLRequest(url: url as URL)
        webView.loadRequest(requestObj)
        
    }
}
