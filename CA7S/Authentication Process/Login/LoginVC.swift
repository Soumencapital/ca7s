//
//  LoginVC.swift
//  CA7S
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnLoginWithFacebook: UIButton!
    @IBOutlet weak var btnShowPassword: UIButton!
    @IBOutlet weak var btnSignUpHere: UIButton!
    @IBOutlet weak var btnNewToCA7S: UIButton!
    
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var topLogoConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var objViewLoginDataY: NSLayoutConstraint!
    
    @IBOutlet weak var lblOr: UILabel!
    @IBOutlet weak var lblVersion: UILabel!
    
    var mode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        txtEmail.text = "satyam.redturtle@gmail.com"
        //        txtPassword.text = "testing@123"
        
        SetUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func SetUI() {
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        if view.frame.size.height == 568 {
            topLogoConstraints.constant = 30
            objViewLoginDataY.constant = 5
        }else{
            topLogoConstraints.constant = 70
            objViewLoginDataY.constant = 40
        }
        
        btnLogin.layer.cornerRadius = btnLogin.layer.frame.size.height / 2
        btnLogin.clipsToBounds = true
        
        
        btnLoginWithFacebook.layer.cornerRadius = btnLoginWithFacebook.layer.frame.size.height / 2
        btnLoginWithFacebook.clipsToBounds = true
        
        self.setLocalizationString()
    }
    
    func setLocalizationString(){
        self.txtEmail.placeholder = NSLocalizedString("Email", comment: "")
        self.txtPassword.placeholder = NSLocalizedString("Password", comment: "")
        
        self.btnForgotPassword.setTitle(NSLocalizedString("Forgot_Password", comment: ""), for: .normal)
        self.btnLogin.setTitle(NSLocalizedString("Login", comment: ""), for: .normal)
        self.lblOr.text = NSLocalizedString("OR", comment: "")
        
        self.btnLoginWithFacebook.setTitle(NSLocalizedString("Login_with_Facebook", comment: ""), for: .normal)
        self.btnNewToCA7S.setTitle(NSLocalizedString("New_to_CA7S?", comment: ""), for: .normal)
        //App_Color
        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
                                  NSForegroundColorAttributeName : UIColor.init(red: 120.0/255.0, green: 22.0/255.0, blue: 82.0/255.0, alpha: 1)] as [String : Any]
        let underlineAttributedString = NSAttributedString(string: (NSLocalizedString("SIGN_UP_HERE", comment: "")), attributes: underlineAttribute)
        self.btnSignUpHere.setAttributedTitle(underlineAttributedString, for: .normal)
        
        self.lblVersion.text = NSLocalizedString("GiCaLu_Tech_2019.All_rights_reserved", comment: "")
    }
    
    //MARK:- Textfield Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtEmail{
            
            guard let text = txtEmail.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 32 // Bool
            
        }else{
            
            guard let text = txtPassword.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 48 // Bool
        }
    }
    
    //MARK:- Validations
    
    func Validation() {
        
        let providedEmailAddress = txtEmail.text
        let isEmailAddressValid = self.isValidEmailAddress(emailAddressString: providedEmailAddress!)
        
        if (txtEmail.text?.isEmpty)!{
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_email", comment: ""))
        }else if !isEmailAddressValid{
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_valid_email", comment: ""))
        }else if (txtPassword.text?.isEmpty)!{
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_password", comment: ""))
        }else{
            LoginAPI()
        }
    }
    
    //MARK:- Button Action
    
    @IBAction func btnShowPassword(_ sender: Any) {
        
        if btnShowPassword.currentImage == #imageLiteral(resourceName: "HidePassword") {
            txtPassword.isSecureTextEntry = false
            btnShowPassword.setImage(#imageLiteral(resourceName: "ShowPassword"), for: .normal)
        }else{
            txtPassword.isSecureTextEntry = true
            btnShowPassword.setImage(#imageLiteral(resourceName: "HidePassword"), for: .normal)
        }
    }
    
    @IBAction func btnForgotPassword(_ sender: Any) {
        self.PushToController(StroyboardName: "Main", "ForgotPasswordVC")
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        Validation()
        //        self.PushToController(StroyboardName: "Dashboard", "Dashboard_TabbarVC")
    }
    
    @IBAction func btnLoginWithFacebook(_ sender: Any) {
        doFBLogin()
    }
    
    @IBAction func btnSignUp(_ sender: Any) {
        self.PushToController(StroyboardName: "Main", "RegisterVC")
    }
    
    @IBAction func btnBack(_ sender: Any){
        if mode == "musicPlayer"{
            self.navigationController?.popViewController(animated: true)
        }else{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.setMainTabBarControllerFor(self.navigationController!)
        }
    }
    
    func doFBLogin() {
        let login:FBSDKLoginManager = FBSDKLoginManager()
        login.logOut()
        login.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, error) in
            if (error != nil) {
                let token = FBSDKAccessToken.current()
                print("FB AccessToken:-\(token!)")
            } else if (result?.isCancelled)! {
                
            } else {
                if (FBSDKAccessToken.current() != nil) {
                    self.getUserProfileFromFB()
                }
            }
        }
    }
    
    func getUserProfileFromFB() {
        let para = NSMutableDictionary()
        para.setValue("id,name,birthday,email,gender,hometown", forKey: "fields")
        FBSDKGraphRequest.init(graphPath: "me", parameters: para as! [AnyHashable : Any]).start { (coonectio, result, error) in
            if error == nil {
                let parameters: Parameters = [
                    "social_id" : (result as! NSDictionary)["id"] as! String,
                    "email" : (result as! NSDictionary)["email"] as? String ?? ((result as! NSDictionary)["name"] as! String).replacingOccurrences(of: " ", with: "")+"@facebook.com",
                    "name" : (result as! NSDictionary)["name"] as! String,
                    "gender": (result as! NSDictionary)["gender"] as? String ?? "",
                    "user_name": ((result as! NSDictionary)["id"] as! String).replacingOccurrences(of: " ", with: "")+"@facebook.com"
                    //                    "user_name":((result as! NSDictionary)["name"] as! String).replacingOccurrences(of: " ", with: "")
                ]
                
    
                
                UserDefaults.standard.set(((result as! NSDictionary)["name"] as! String).replacingOccurrences(of: " ", with: "")+"@facebook.com", forKey: Constant.USERDEFAULTS.EMAIL_ID)
                UserDefaults.standard.set(((result as! NSDictionary)["name"] as! String), forKey: Constant.USERDEFAULTS.USER_NAME)
                UserDefaults.standard.synchronize()
                
                self.FBLoginAPI(parameters: parameters)
            }
        }
    }
    
    //MARK: Calling API
    
    func LoginAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            
            var strDeviceToken = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.DEVICE_TOKEN)
            
            if strDeviceToken == nil{
                strDeviceToken = ""
            }else{
                strDeviceToken = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.DEVICE_TOKEN) as! String
            }
            
            let parameters: Parameters = [
                "email" : txtEmail.text!,
                "user_password" : txtPassword.text!,
                "user_token" : "\(strDeviceToken!)"
                
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.LOGIN_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                        let defaults = UserDefaults.standard
                        defaults.set(true, forKey: Constant.appConstants.IS_LOGIN)
                        defaults.set(data["is_update"].boolValue, forKey: Constant.appConstants.IS_ACTIVATED)
                        defaults.set(self.txtEmail.text!, forKey: Constant.USERDEFAULTS.EMAIL_ID)
                        defaults.set(data["data"][0]["user_id"].int, forKey: Constant.USERDEFAULTS.USER_ID)
                        defaults.synchronize()
                        if self.mode == "musicPlayer"{
                            
                            self.navigationController?.popViewController(animated: true)
                            
                        }else{
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.setMainTabBarControllerFor(self.navigationController!)
                        }
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
    
    func FBLoginAPI(parameters:Parameters) {
        
        if Connectivity.isConnectedToInternet() {
            //SVProgressHUD.show()
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.FB_LOGIN_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                SVProgressHUD.dismiss()
                if let data = response.result.value {
                    if data["status"] == "success" {
                        let defaults = UserDefaults.standard
                        defaults.set(true, forKey: Constant.appConstants.IS_LOGIN)
                        defaults.set(data["is_update"].boolValue, forKey: Constant.appConstants.IS_ACTIVATED)
                        defaults.set(data["data"]["user_id"].description, forKey: Constant.USERDEFAULTS.USER_ID)
                        defaults.synchronize()
                        
                        if self.mode == "musicPlayer"{
                              self.navigationController?.popViewController(animated: true)
                        }else{
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.setMainTabBarControllerFor(self.navigationController!)
                        }
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
