//
//  ForgotPasswordVC.swift
//  CA7S
//


import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD
import Localize_Swift


class ForgotPasswordVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var txtEmail: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        SetuI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func SetuI() {
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        btnSubmit.layer.cornerRadius = btnSubmit.layer.frame.size.height / 2
        btnSubmit.clipsToBounds = true
        
        self.setLocalizationString()
    }
    
    //MARK:-
    //MARK:- Add Localization
    
    func setLocalizationString(){
        lblHeader.text = NSLocalizedString("Forgot_Password", comment: "")
        self.txtEmail.placeholder = NSLocalizedString("Email", comment: "")
        self.btnSubmit.setTitle(NSLocalizedString("Submit", comment: ""), for: .normal)
        
    }
    
    //MARK:- Textfield Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = txtEmail.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 32 // Bool
         
    }
    
    //MARK:- Validation
    
    func Validation() {
        let providedEmailAddress = txtEmail.text
        let isEmailAddressValid = self.isValidEmailAddress(emailAddressString: providedEmailAddress!)
        
        if (txtEmail.text?.isEmpty)!{
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_email", comment: ""))
        }else if !isEmailAddressValid{
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_valid_email", comment: ""))
        }else{
            ForgotPasswordAPI()
        }
    }
    
    //MARK:- Button Action
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSubmit(_ sender: UIButton){
        Validation()
    }
    
    //MARK:- API Calling

    func ForgotPasswordAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            
            let parameters: Parameters = [
                
                "email" : txtEmail.text!
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.FORGOT_PASSWORD_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                        let alertController = UIAlertController(title:"", message: data["message"].description, preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                            self.navigationController?.popViewController(animated: true)
                        }
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true, completion:nil)
                        
                    }else{
                        
                        let strMsg = data["message"]
                        
                        self.displayAlertMessage(messageToDisplay: NSLocalizedString(strMsg.string!, comment: ""))
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
