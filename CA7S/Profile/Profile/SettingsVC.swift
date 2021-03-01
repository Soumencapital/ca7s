//
//  SettingsVC.swift
//  CA7S
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD


class SettingsVC: UIViewController {
    
    @IBOutlet weak var switchNotification: UISwitch!
    @IBOutlet weak var switchPrivateAccount: UISwitch!
    @IBOutlet weak var lblSelectedLang: UILabel!
    @IBOutlet weak var switichEconomicMode: UISwitch!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSelectLanguage: UILabel!
    @IBOutlet weak var lblNotification: UILabel!
    @IBOutlet weak var lblChangePassword: UILabel!
    @IBOutlet weak var lblPrivateAccount: UILabel!
    @IBOutlet weak var lblClearSearchHistory: UILabel!
    @IBOutlet weak var lblEconomicMode: UILabel!
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var view5: UIView!
    
    
    var strUserEmail = String()
    // when user change economic mode from musicPlayer
    var ifFromMusic = false
    @IBOutlet weak var naviagtionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        GetSettingStatusAPI()
        if ifFromMusic {
            naviagtionButton.setImage(UIImage(named: "btnBack"), for: .normal)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (UserDefaults.standard.string(forKey: Constant.AppLanguage)) == "English" {
            //            lblSelectedLang.text = NSLocalizedString("English", comment: "")
            lblSelectedLang.text = NSLocalizedString("English", comment: "")
        }else{
            //            lblSelectedLang.text = NSLocalizedString("Portuguese", comment: "")
            lblSelectedLang.text = NSLocalizedString("Portuguese", comment: "")
        }
        
        let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
        
        if strUID == nil{
            
            self.view2.isHidden = true
            self.view3.isHidden = true
            self.view4.isHidden = true
            self.view5.isHidden = true
        }
        self.switichEconomicMode.isOn = UserDefaults.standard.bool(forKey: Constant.USERDEFAULTS.economicMode)
        self.setLocalizationString()
    }
    
    func setLocalizationString(){
        self.lblTitle.text = NSLocalizedString("Settings", comment: "")
        self.lblSelectLanguage.text = NSLocalizedString("Select_Language", comment: "")
        self.lblNotification.text = NSLocalizedString("Notifications", comment: "")
        self.lblChangePassword.text = NSLocalizedString("Change_Password", comment: "")
        self.lblPrivateAccount.text = NSLocalizedString("Private_Account", comment: "")
        self.lblClearSearchHistory.text = NSLocalizedString("Clear_Search_History", comment: "")
        self.lblEconomicMode.text = NSLocalizedString("Economic mode", comment: "")
    }
    
    //MARK:- Button Actions
    
    @IBAction func ViewSelectLanguagePressed(_ sender: UIControl) {
        let alertController = UIAlertController(title:"", message: "", preferredStyle: .actionSheet)
        
        let actionEglish = UIAlertAction(title: NSLocalizedString("English", comment: ""), style: .default) { (action:UIAlertAction!) in
            self.changeLanguageAPI(lang: "English") // "en"
            
            let defaults = UserDefaults.standard
            defaults.set("English", forKey: Constant.AppLanguage)
            defaults.synchronize()
            
            L102Language.setAppleLAnguageTo(lang: "en")
            
            self.lblSelectedLang.text = NSLocalizedString("English", comment: "")
            self.setLocalizationString()
        }
        
        let actionPortugis = UIAlertAction(title: NSLocalizedString("Portuguese", comment: ""), style: .default) { (action:UIAlertAction!) in
            L102Language.setAppleLAnguageTo(lang: "pt")
            let defaults = UserDefaults.standard
            defaults.set("Portuguese", forKey: Constant.AppLanguage)
            defaults.synchronize()
            
            self.lblSelectedLang.text = NSLocalizedString("Portuguese", comment: "")
            
            self.setLocalizationString()
            self.changeLanguageAPI(lang: "Portuguese") // "pt"
        }
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action:UIAlertAction!) in
            
        }
        
        alertController.addAction(actionEglish)
        alertController.addAction(actionPortugis)
        alertController.addAction(actionCancel)
        self.present(alertController, animated: true, completion:nil)
    }
    
    @IBAction func switchNotificationPressed(_ sender: Any) {
        
        if switchNotification.isOn == true{
            switchNotificationAPI(isOn: "0")
        }else{
            switchNotificationAPI(isOn: "1")
        }
    }
    
    @IBAction func viewClearHistoryPressed(_ sender: Any) {
        // create the alert
        let alert = UIAlertController(title: "", message: NSLocalizedString("Are_you_sure_you_want_to_delete_search_history?", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.default, handler: { action in
            
            self.ClearSearchHistoryAPI()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func switchPrivateAccountPressed(_ sender: UISwitch) {
        if switchPrivateAccount.isOn == true{
            switchPrivateAccount.isOn = false
            print("switchPrivateAccountPressed \(switchPrivateAccount.isOn)")
            switchPrivacyAPI(isOn: "0")
            
        }else{
            switchPrivateAccount.isOn = true
            print("switchPrivateAccountPressed \(switchPrivateAccount.isOn)")
            switchPrivacyAPI(isOn: "1")
        }
    }
    @IBAction func switchPrivateAccountIsSelected(_ sender: UISwitch) {
        //        if switchPrivateAccount.isOn == true{
        //            switchPrivateAccount.isOn = false
        //            print("switchPrivateAccountIsSelected \(switchPrivateAccount.isOn)")
        //            switchPrivacyAPI(isOn: "0")
        //        }else{
        //            switchPrivateAccount.isOn = true
        //            print("switchPrivateAccountIsSelected \(switchPrivateAccount.isOn)")
        //            switchPrivacyAPI(isOn: "1")
        //        }
        
        
        let value = sender.isOn ? "1" : "0"
        
        
        
        switchPrivacyAPI(isOn: "\(value)")
        
    }
    @IBAction func viewChangePasswordPressed(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
        vc.strEmail = strUserEmail
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnMenuPressed(_ sender: Any) {
        if ifFromMusic {
            self.navigationController?.popViewController(animated: true)
        }else{
             self.sideMenuViewController?._presentLeftMenuViewController()
        }
       
    }
    @IBAction func changeEconomicMode(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: Constant.USERDEFAULTS.economicMode)
        
    }
    
    //MARK:- API Calling
    
    func GetSettingStatusAPI() {
        
        //            //SVProgressHUD.show()
        let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
        
        if strUID == nil{
            
        }else{
            
            let parameters: Parameters = [
                
                "user_id" : "\(strUID!)"
            ]
            
            if Connectivity.isConnectedToInternet() {
                
                print("Para",parameters)
                
                Alamofire.request(Constant.APIs.GET_SETTINGS_STATUS, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                    
                    //                SVProgressHUD.dismiss()
                    
                    print("******\n \n  \n \n \nGetSettingStatusAPI \n \(response) \n \n \n \n \n ********")
                    
                    if let data = response.result.value {
                        
                        if data["status"] == "success" {
                            
                            self.lblSelectedLang.text = NSLocalizedString(data["data"][0]["language_setting"].description, comment: "")
                            self.switchNotification.isOn = data["data"][0]["notification_setting"].boolValue
                            self.switchPrivateAccount.isOn = data["data"][0]["private_account"].boolValue
                            self.strUserEmail = data["data"][0]["email"].description
                            
                        }else{
                            
                            let strMsg = data["message"]
                            
                            self.displayAlertMessage(messageToDisplay: strMsg.string!)
                        }
                        
                    }else{
                        
                        self.displayAlertMessage(messageToDisplay: NSLocalizedString("Something_went_wrong", comment: ""))
                    }
                })
                
            }else{
                
                self.displayAlertMessageWithTitle(title: Constant.APIs.InternetConnectionTitle, alertMessage: Constant.APIs.InternetConnectionMessage)
            }
        }
    }
    
    func switchNotificationAPI(isOn: String) {
        
        if Connectivity.isConnectedToInternet() {
            
            //            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let parameters: Parameters = [
                
                "user_id" : "\(strUID!)",
                "notification_setting" : isOn
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.GET_SETTINGS_STATUS, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                //                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    print("******\n \n  \n \n \n switchNotificationAPI \n \(response) \n \n \n \n \n ********")
                    
                    if data["status"] == "success" {
                        
                        self.lblSelectedLang.text = NSLocalizedString(data["data"][0]["language_setting"].description, comment: "")
                        self.switchNotification.isOn = data["data"][0]["notification_setting"].boolValue
                        self.switchPrivateAccount.isOn = data["data"][0]["private_account"].boolValue
                        self.strUserEmail = data["data"][0]["email"].description
                        
                    }else{
                        
                        let strMsg = data["message"]
                        
                        self.displayAlertMessage(messageToDisplay: strMsg.string!)
                    }
                    
                }else{
                    
                    self.displayAlertMessage(messageToDisplay: NSLocalizedString("Something_went_wrong", comment: ""))
                }
            })
        }else{
            
            self.displayAlertMessageWithTitle(title: Constant.APIs.InternetConnectionTitle, alertMessage: Constant.APIs.InternetConnectionMessage)
        }
    }
    
    func switchPrivacyAPI(isOn: String) {
        
        if Connectivity.isConnectedToInternet() {
            
            //            //SVProgressHUD.show()
            
            
            var parameters: Parameters = [
                "private_account" : isOn
            ]
            
            if let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID) as? String {
                parameters["user_id"] = strUID
            }
            
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.GET_SETTINGS_STATUS, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                //                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                        print("**************switchPrivacyAPI \n \((response.result.value)!)***************")
                        
                        self.lblSelectedLang.text = NSLocalizedString(data["data"][0]["language_setting"].description, comment: "")
                        self.switchNotification.isOn = data["data"][0]["notification_setting"].boolValue
                        self.switchPrivateAccount.isOn = data["data"][0]["private_account"].boolValue
                        self.strUserEmail = data["data"][0]["email"].description
                        
                    }else{
                        
                        let strMsg = data["message"]
                        self.displayAlertMessage(messageToDisplay: strMsg.string!)
                    }
                }else{
                    
                    self.displayAlertMessage(messageToDisplay: NSLocalizedString("Something_went_wrong", comment: ""))
                }
            })
        }else{
            
            self.displayAlertMessageWithTitle(title: Constant.APIs.InternetConnectionTitle, alertMessage: Constant.APIs.InternetConnectionMessage)
        }
    }
    
    func changeLanguageAPI(lang: String) {
        let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
        if strUID == nil{
        }else{
            let parameters: Parameters = [
                "user_id" : "\(strUID!)",
                "language_setting" : lang
            ]
            
            print("Para",parameters)
            
            if Connectivity.isConnectedToInternet() {
                
                Alamofire.request(Constant.APIs.GET_SETTINGS_STATUS, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                    
                    //                SVProgressHUD.dismiss()
                    
                    if let data = response.result.value {
                        print("changeLanguageAPI \((response.result.value)!)")
                        if data["status"] == "success" {
                            
                            self.lblSelectedLang.text = NSLocalizedString(data["data"][0]["language_setting"].description, comment: "")
                            self.switchNotification.isOn = data["data"][0]["notification_setting"].boolValue
                            self.switchPrivateAccount.isOn = data["data"][0]["private_account"].boolValue
                            self.strUserEmail = data["data"][0]["email"].description
                            
                        }else{
                            
                            let strMsg = data["message"]
                            self.displayAlertMessage(messageToDisplay: strMsg.string!)
                        }
                    }else{
                        
                        self.displayAlertMessage(messageToDisplay: NSLocalizedString("Something_went_wrong", comment: ""))
                    }
                })
            }else{
                
                self.displayAlertMessageWithTitle(title: Constant.APIs.InternetConnectionTitle, alertMessage: Constant.APIs.InternetConnectionMessage)
            }
        }
    }
    
    func ClearSearchHistoryAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //            //SVProgressHUD.show()
            
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let parameters: Parameters = [
                
                "user_id" : "\(strUID!)"
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.CLEAR_ALL_SEARCH_HISTORY_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                //                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                    }else{
                        
                        let strMsg = data["message"]
                        self.displayAlertMessage(messageToDisplay: strMsg.string!)
                    }
                }else{
                    self.displayAlertMessage(messageToDisplay: NSLocalizedString("Something_went_wrong", comment: ""))
                }
            })
        }else{
            self.displayAlertMessageWithTitle(title: Constant.APIs.InternetConnectionTitle, alertMessage: Constant.APIs.InternetConnectionMessage)
        }
    }
}
