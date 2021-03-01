//
//  ChangePasswordVC.swift
//  CA7S
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD

class ChangePasswordVC: UIViewController {

    @IBOutlet weak var txtOldPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    @IBOutlet weak var btnSubmit: UIButton!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    var strEmail = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setLocalizationString()
    }
    
    func setLocalizationString(){
        self.lblTitle.text = NSLocalizedString("Change_Password", comment: "")
        
        self.btnSubmit.setTitle(NSLocalizedString("Submit", comment: ""), for: .normal)
        
        self.txtOldPassword.placeholder = NSLocalizedString("Old_Password", comment: "")
        self.txtNewPassword.placeholder = NSLocalizedString("New_Password", comment: "")
        self.txtConfirmPassword.placeholder = NSLocalizedString("Confirm_Password", comment: "")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func Validation() {
        
        if (txtOldPassword.text?.isEmpty)!{
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_old_password", comment: ""))
        }else if !(self.isValidPassword(Password: txtOldPassword.text!)){
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_valid_old_password", comment: ""))
        }else if (txtNewPassword.text?.isEmpty)!{
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_new_password", comment: ""))
        }else if !(self.isValidPassword(Password: txtNewPassword.text!)){
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_valid_new_password", comment: ""))
        }else if (txtConfirmPassword.text?.isEmpty)!{
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_confirm_password", comment: ""))
        }else if !(self.isValidPassword(Password: txtConfirmPassword.text!)){
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_valid_confirm_password", comment: ""))
        }else if txtNewPassword.text != txtConfirmPassword.text{
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Your_confirm_password_not_matched_with_new_password", comment: ""))
        }else{
            ChangePasswordAPI()
        }
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSubmitPressed(_ sender: Any) {
        Validation()
    }
    
    //MARK:- API Calling
    
    func ChangePasswordAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            
            let parameters: Parameters = [
                
                "email" : strEmail,
                "current_password" : txtOldPassword.text!,
                "new_password" : txtNewPassword.text!,
                "confirm_password" : txtConfirmPassword.text!
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.CHANGE_PASSWORD, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        self.navigationController?.popViewController(animated: true)
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
