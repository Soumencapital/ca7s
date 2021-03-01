//
//  RegisterVC.swift
//  CA7S
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD


class RegisterVC: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var btnEmail: UIButton!
    @IBOutlet weak var btnPassword: UIButton!
    @IBOutlet weak var btnTermsAndCondition: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnShowPassword: UIButton!
    @IBOutlet weak var btnShowConfirmPassword: UIButton!
    @IBOutlet weak var btnAlreadyRegistered: UIButton!
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var viewPhone: UIView!
    @IBOutlet weak var lblTerms: FRHyperLabel!
    
    var strEmailVerified = String()
    var strmsgEmailVerified = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SetUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func SetUI() {
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        viewPhone.isHidden = true
        viewEmail.isHidden = false
        btnEmail.backgroundColor = Constant.ColorConstant.darkPink
        btnPassword.backgroundColor = Constant.ColorConstant.lightPink
        
        btnEmail.layer.cornerRadius = btnEmail.layer.frame.size.height / 2
        btnEmail.clipsToBounds = true
        btnPassword.layer.cornerRadius = btnPassword.layer.frame.size.height / 2
        btnPassword.clipsToBounds = true
        btnSignUp.layer.cornerRadius = btnSignUp.layer.frame.size.height / 2
        btnSignUp.clipsToBounds = true

        let attribute = [NSFontAttributeName: UIFont.systemFont(ofSize: 15.0)]
        lblTerms.attributedText = NSAttributedString.init(string: lblTerms.text!, attributes: attribute)
        //Step 2: Define a selection handler block
        
        let handler = {
            (hyperLabel: FRHyperLabel?, substring: String?) -> Void in
            
            if substring == "Termos de Serviç"{
                guard let url = URL(string: "https://www.ca7s.com/ca7s/terms_condition") else { return }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    // Fallback on earlier versions
                }
            }else{
                guard let url = URL(string: "https://www.ca7s.com/ca7s/privacy_policy") else { return }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    // Fallback on earlier versions
                }
            }
            
//            let controller = UIAlertController(title: substring, message: nil, preferredStyle: UIAlertControllerStyle.alert)
//            controller.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
//            self.present(controller, animated: true, completion: nil)
        }
        
        //Step 3: Add link substrings
        lblTerms.setLinksForSubstrings(["Terms of Service", "Privacy Policy"], withLinkHandler: handler)
        
        self.setLocalizationString()
    }
    
    //MARK:-
    //MARK:- Add Localization
    
    func setLocalizationString(){
        self.txtEmail.placeholder = NSLocalizedString("Email", comment: "")
        self.txtPassword.placeholder = NSLocalizedString("Password", comment: "")
        self.txtConfirmPassword.placeholder = NSLocalizedString("Confirm_Password", comment: "")
        btnAlreadyRegistered.setTitle(NSLocalizedString("Already_Registered?", comment: ""), for: .normal)
        self.lblTerms.text = NSLocalizedString("I_agree_to_the_CA7S_Terms_of_Services_and_Privacy_Policy", comment: "")
        
//        self.btnAlreadyRegistered.setTitle("Already_Registered?", for: .normal)
        self.btnSignIn.setTitle(NSLocalizedString("SIGN_IN_HERE", comment: ""), for: .normal)
        self.btnSignUp.setTitle(NSLocalizedString("Sign_Up", comment: ""), for: .normal)
        
    }
    
    //MARK:- Textfield Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtEmail{
            
            guard let text = txtEmail.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 32 // Bool
            
        }else if textField == txtPhone{
            
            guard let text = txtPhone.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 20 // Bool
            
        }else if textField == txtPassword{
            
            guard let text = txtPassword.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 12 // Bool
            
        }else{
            
            guard let text = txtConfirmPassword.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 12 // Bool
            
        }
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == txtEmail {
            UserVerificationAPI()
        }
    }
    
    //MARK:- Validations
    
    func Validation() {
        
        let providedEmailAddress = txtEmail.text
        let isEmailAddressValid = self.isValidEmailAddress(emailAddressString: providedEmailAddress!)
        
        if viewEmail.isHidden == true {
            
            if (txtPhone.text?.isEmpty)!{
                self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_phone_number", comment: ""))
            }else if (txtPhone.text?.count)! < 9 {
                self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_valid_phone_number", comment: ""))
            }
        }else if viewEmail.isHidden == false {
            
            if (txtEmail.text?.isEmpty)!{
                self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_email", comment: ""))
            }else if !isEmailAddressValid{
                self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_valid_email", comment: ""))
            }
        }
        
        if (txtPassword.text?.isEmpty)!{
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_password", comment: ""))
        }else if !self.isValidPassword(Password: txtPassword.text!){
            self.displayAlertMessageWithTitle(title: NSLocalizedString("Enter_Valid_Password", comment: ""), alertMessage: NSLocalizedString("Password_should_contain_Minimum_6_characters_and_maximum_12_and_should_have_at_least_1_Uppercase_Alphabet,_1_Lowercase_Alphabet,_1_Number_and_1_Special_Character", comment: ""))
        }else if (txtConfirmPassword.text?.isEmpty)!{
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_confirm_password", comment: ""))
        }else if txtPassword.text! != txtConfirmPassword.text! {
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Password_is_not_matched", comment: ""))
        }else if btnTermsAndCondition.currentImage == #imageLiteral(resourceName: "UncheckedBox") {
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_accept_Terms_and_condition", comment: ""))
        }else{
            if strEmailVerified == "YES"{
                RegistrationAPI()
            }else{
                self.displayAlertMessage(messageToDisplay: strmsgEmailVerified)
            }
            
        }
    }
    
    //MARK:- Button Actions

    @IBAction func btnEmail(_ sender: Any) {
        
        viewPhone.isHidden = true
        viewEmail.isHidden = false
        btnEmail.backgroundColor = Constant.ColorConstant.darkPink
        btnPassword.backgroundColor = Constant.ColorConstant.lightPink
        txtPassword.resignFirstResponder()
    }
    
    @IBAction func btnPhone(_ sender: Any) {
        
        viewPhone.isHidden = false
        viewEmail.isHidden = true
        btnEmail.backgroundColor = Constant.ColorConstant.lightPink
        btnPassword.backgroundColor = Constant.ColorConstant.darkPink
        txtEmail.resignFirstResponder()
    }
    
    @IBAction func btnShowPassword(_ sender: Any) {
        
        if btnShowPassword.currentImage == #imageLiteral(resourceName: "HidePassword") {
            txtPassword.isSecureTextEntry = false
            btnShowPassword.setImage(#imageLiteral(resourceName: "ShowPassword"), for: .normal)
        }else{
            txtPassword.isSecureTextEntry = true
            btnShowPassword.setImage(#imageLiteral(resourceName: "HidePassword"), for: .normal)
        }
    }
    
    @IBAction func btnShowConfirmPassword(_ sender: Any) {
        
        if btnShowConfirmPassword.currentImage == #imageLiteral(resourceName: "HidePassword") {
            txtConfirmPassword.isSecureTextEntry = false
            btnShowConfirmPassword.setImage(#imageLiteral(resourceName: "ShowPassword"), for: .normal)
        }else{
            txtConfirmPassword.isSecureTextEntry = true
            btnShowConfirmPassword.setImage(#imageLiteral(resourceName: "HidePassword"), for: .normal)
        }
    }
    
    @IBAction func btnTermsAndCondition(_ sender: Any) {
        
        if btnTermsAndCondition.currentImage == #imageLiteral(resourceName: "UncheckedBox") {
            btnTermsAndCondition.setImage(#imageLiteral(resourceName: "CheckedBox"), for: .normal)
        }else{
            btnTermsAndCondition.setImage(#imageLiteral(resourceName: "UncheckedBox"), for: .normal)
        }
    }
    
    @IBAction func btnSignUp(_ sender: Any) {
        Validation()
    }
    
    @IBAction func btnSignIn(_ sender: Any) {
        self.sideMenuViewController?.panGestureEnabled = false
        self.PushToController(StroyboardName: "Main", "LoginVC")
    }
    
    //MARK: API Calling 
    
    func RegistrationAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            
            let parameters: Parameters = [
                
                "email" : txtEmail.text!,
                "user_password" : txtPassword.text!
                
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.REGISTRATION_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {

                        let alertController = UIAlertController(title:"", message: data["note"].description, preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                            self.navigationController?.popViewController(animated: true)
                        }
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true, completion:nil)
                        
                        
//                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                        appDelegate.setMainTabBarControllerFor(self.navigationController!)
                        
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

    func UserVerificationAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
//            //SVProgressHUD.show()
            
            let parameters: Parameters = [
                "email" : txtEmail.text!
            ]
            
            print("Para",parameters)
            
            
            Alamofire.request(Constant.APIs.USEREMAIL_VERIFICATION_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in

//                SVProgressHUD.dismiss()

                if let data = response.result.value {

                    if data["status"] == "success" {
                        self.strEmailVerified = "YES"

                    }else{
                        
                        self.strEmailVerified = "NO"
                        
                        self.strmsgEmailVerified = data["message"].description

                        self.displayAlertMessage(messageToDisplay: self.strmsgEmailVerified)
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
