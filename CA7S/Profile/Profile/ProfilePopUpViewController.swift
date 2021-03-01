//
//  ProfilePopUpViewController.swift
//  CA7S
//


import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD


protocol popupDelegate {
    func cancelPressed(isCancled:Bool)
}

class ProfilePopUpViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    var delegate:popupDelegate?
    
    @IBOutlet var txtName:UITextField!
    @IBOutlet var txtUserName:UITextField!
    @IBOutlet var txtCity:UITextField!
    @IBOutlet var btnSubmit:UIButton!
    @IBOutlet var viewContaiber:UIView!
    
    var strUsernameVerified = String()
    var strmsgUsernameVerified = String()
    var strUsername = String()
    
    var arrCity = [[String:AnyObject]]()
    var arrCityName = NSMutableArray()
    var myPickerView : UIPickerView!
    
    var cityID:String?
    var selectedIndex:Int = 0
    
    var isUserNameIsValid: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let username: String = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.FULL_NAME  ) as? String ?? ""
        let fullname: String = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.FULL_NAME) as? String ?? ""
        
        if fullname == ""{
            txtName.text = username
        }else{
            txtName.text = username
//            txtUserName.text = fullname
        }
        
        
        GetCityListAPI()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.setLocalizationString()
    }
    
    func setLocalizationString(){
        
        self.btnSubmit.setTitle(NSLocalizedString("Submit", comment: ""), for: .normal)
        
        self.txtName.placeholder = NSLocalizedString("Your_name", comment: "")
        self.txtUserName.placeholder = NSLocalizedString("User_Name", comment: "")
        self.txtCity.placeholder = NSLocalizedString("City", comment: "")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSubmitPressed(_ sender:Any) {
        
        Validation()
    }
    
    @IBAction func btnCityPickerIsClicked(_ sender: Any) {
         self.pickUp(txtCity)
    }
    
    //MARK:- Custom Picker
    
    func pickUp(_ textField : UITextField){
        
        // UIPickerView
        self.myPickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.myPickerView.delegate = self
        self.myPickerView.dataSource = self
        txtCity.inputView = self.myPickerView
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 79/255, green: 90/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .plain, target: self, action: #selector(AddMusicVC.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(AddMusicVC.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        txtCity.inputAccessoryView = toolBar
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return arrCityName.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return arrCityName[row] as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedIndex = row
        self.txtCity.text = "\(arrCityName[row])"
    }
    
    func doneClick() {
        
        cityID = "\(String(describing: (arrCity[selectedIndex] as [String:Any])["id"]!))"
        txtCity.resignFirstResponder()
    }
    
    func cancelClick() {
        
        txtCity.resignFirstResponder()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtName{
            
            guard let text = txtName.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 32 // Bool
            
        }else if textField == txtUserName{
            
            guard let text = txtUserName.text else { return true }
            
            
            if string == " "{
                return false
            }
            
            let newLength = text.count + string.count - range.length
            return newLength <= 20 // Bool
            
            
            
            
            
//            if  newLength == 20 || newLength >= 20 {
//                return newLength <= 20 // Bool
//            }else{
//                self.UserVerificationAPI()
//                return true
//            }
            
        }else{
            
            guard let text = txtCity.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 16 // Bool
            
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == txtUserName {
            UserVerificationAPI()
        }
        
        if textField == txtCity{
            self.pickUp(txtCity)
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if textField == txtUserName {
//            UserVerificationAPI()
//        }
        
        if textField == txtCity{
            self.pickUp(txtCity)
        }
    }
    
    //MARK:- Validations
    
    func Validation() {
        
        if (txtName.text?.isEmpty)! {
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_your_name", comment: ""))
        }else if (txtUserName.text?.isEmpty)! {
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_your_username", comment: ""))
        }else if (txtCity.text?.isEmpty)! {
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_city", comment: ""))
        }else{
            
             if strUsernameVerified == "YES"{
                EditProfileAPI()
             }else{
                 self.displayAlertMessage(messageToDisplay: strmsgUsernameVerified)
            }
//            if strUsernameVerified == "YES"{
//                if strUsernameVerified == "YES"{
//                    EditProfileAPI()
//                }else{
//                    self.displayAlertMessage(messageToDisplay: strmsgUsernameVerified)
//                }
//            }else{
//                self.displayAlertMessage(messageToDisplay: strmsgUsernameVerified)
//            }
            
        }
    }
    
    //MARK:- API Calling
    
    func UserVerificationAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            
            let parameters: Parameters = [
                "user_name" : txtUserName.text!,
            ]
            
            print("Para",parameters)
            
            
            Alamofire.request(Constant.APIs.USER_VERIFICATION_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        self.strUsernameVerified = "YES"
                        
                    }else{
                        
                        self.strUsernameVerified = "NO"
                        
                        self.strmsgUsernameVerified = data["message"].description
                        
                        self.displayAlertMessage(messageToDisplay: self.strmsgUsernameVerified)
                    }
                    
                }else{
                    
                    self.displayAlertMessage(messageToDisplay: NSLocalizedString("Something_went_wrong", comment: ""))
                }
            })
        }else{
            
            self.displayAlertMessageWithTitle(title: Constant.APIs.InternetConnectionTitle, alertMessage: Constant.APIs.InternetConnectionMessage)
        }
    }

    func EditProfileAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
//            
//            if (UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_NAME)! as! String).isEmpty{
//                strUsername = txtUserName.text!
//            }else{
//                strUsername = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_NAME)! as! String
//            }
//            
            let parameters: Parameters = [
                "user_id" : "\(strUID!)",
                "full_name" : txtName.text!,
                "user_name" : txtUserName.text!,
                "email" : UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.EMAIL_ID)!,
                "user_city" : txtCity.text!,
                ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.EDIT_PROFILE_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        self.strUsernameVerified = "YES"
                        
                        if self.delegate != nil {
                            self.delegate?.cancelPressed(isCancled: false)
                        }
                        
                        
                        
                        UserDefaults.standard.set(self.txtName.text?.description, forKey: "FULLNAME")
                        UserDefaults.standard.set(self.txtUserName.text?.description, forKey: "USERNAME")
                        UserDefaults.standard.set(self.txtCity.text?.description, forKey: "CITY")
                        UserDefaults.standard.set(true, forKey: Constant.appConstants.IS_ACTIVATED)
                        UserDefaults.standard.synchronize()
                        
                        self.SidebarAPI()
                        
                    }else{
                        self.strUsernameVerified = "NO"
                        self.strmsgUsernameVerified = data["message"].description
                        self.displayAlertMessage(messageToDisplay: self.strmsgUsernameVerified)
                    }
                }else{
                    self.displayAlertMessage(messageToDisplay: NSLocalizedString("Something_went_wrong", comment: ""))
                }
            })
        }else{
            self.displayAlertMessageWithTitle(title: Constant.APIs.InternetConnectionTitle, alertMessage: Constant.APIs.InternetConnectionMessage)
        }
    }
    
    func GetCityListAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
//            //SVProgressHUD.show()
            
            Alamofire.request(Constant.APIs.GET_CITIES_API, method: .get, parameters: nil , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
//                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                        if let arrSearchResponse =  data["list"]["data"].arrayObject{
                            
                            if self.arrCity.count == 0 {
                                self.arrCity = arrSearchResponse as! [[String:AnyObject]]
                                
                                for i in 0..<self.arrCity.count {
                                    self.arrCityName.add((self.arrCity[i]["name"]?.description)!)
                                }
                                
                            } else {
                                
                            }
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
    
    func SidebarAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //            //SVProgressHUD.show()
            
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            var strDeviceToken = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.DEVICE_TOKEN)
            
            if strDeviceToken == nil{
                strDeviceToken = ""
            }else{
                strDeviceToken = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.DEVICE_TOKEN) as! String
            }
            
            let parameters: Parameters = [
                
                "user_id" : "\(strUID!)",
                "user_token" : "\(strDeviceToken!)"
            ]
            
            print("Para",parameters)
            
            
            Alamofire.request(Constant.APIs.SIDEBAR_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                //                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    print(data)
                    
                    
                    if data["status"] == "success" {
                        
                        UserDefaults.standard.set(data["data"][0]["full_name"].description, forKey: Constant.USERDEFAULTS.FULL_NAME)
                        UserDefaults.standard.set(data["data"][0]["user_name"].description, forKey: Constant.USERDEFAULTS.USER_NAME)
                        UserDefaults.standard.set(data["data"][0]["user_city"].description, forKey: Constant.USERDEFAULTS.USER_CITY)
                        UserDefaults.standard.set(data["data"][0]["profile_picture"].description, forKey: Constant.USERDEFAULTS.PROFILE_PICTURE)
                        UserDefaults.standard.synchronize()
                    }else{
                        
                    }
                }else{
                }
            })
        }else{
        }
    }

}
