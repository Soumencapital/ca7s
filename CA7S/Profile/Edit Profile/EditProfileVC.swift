//
//  EditProfileVC.swift
//  CA7S
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD
import Photos

class EditProfileVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var imgProfilePicture: UIImageView!
    
    @IBOutlet weak var btnChangePicture: UIButton!
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var btnFemale: UIButton!
    
    @IBOutlet weak var txtYourName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtMonth: txtPadding!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var txtYear: UITextField!
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblDOB: UILabel!
    
    var strUserGender = String()
    
    var myPickerView : UIPickerView!
    var datePicker : UIDatePicker!
    
    var arrCity = [[String:AnyObject]]()
    var arrCityName = NSMutableArray()
    var myPickerViewCity : UIPickerView!
    
    var cityID:String?
    var selectedIndex:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SetUI()
        GetProfileAPI()
        GetCityListAPI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.SetUI()
    }
    
    func SetUI() {
        
        btnChangePicture.setTitle(NSLocalizedString("Change_Photo", comment: ""), for: .normal)
        
        txtYourName.placeholder = NSLocalizedString("Your_name", comment: "")
        txtEmail.placeholder = NSLocalizedString("Email", comment: "")
        txtPhoneNumber.placeholder = NSLocalizedString("Phone", comment: "")
        txtCity.placeholder = NSLocalizedString("City", comment: "")
        txtMonth.placeholder = NSLocalizedString("Birthdate", comment: "")
        lblHeader.text = NSLocalizedString("EDIT_PROFILE", comment: "")
        lblGender.text = NSLocalizedString("Gender: ", comment: "")
        lblDOB.text = NSLocalizedString("Date_of_Birth", comment: "")
        
        btnMale.setTitle(NSLocalizedString("Male", comment: ""), for: .normal)
        btnFemale.setTitle(NSLocalizedString("Female", comment: ""), for: .normal)
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        strUserGender = "Male"
        self.btnMale.setImage(#imageLiteral(resourceName: "CheckedBox"), for: .normal)
        self.btnFemale.setImage(#imageLiteral(resourceName: "UncheckedBox"), for: .normal)
        
        imgProfilePicture.layer.cornerRadius = imgProfilePicture.layer.frame.size.height / 2
        imgProfilePicture.clipsToBounds = true
    }
    
    //MARK:- Custom Picker
    
    func pickUpCity(_ textField : UITextField){
        
        // UIPickerView
        self.myPickerViewCity = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.myPickerViewCity.delegate = self
        self.myPickerViewCity.dataSource = self
        self.txtCity.inputView = self.myPickerViewCity
        
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 79/255, green: 90/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .plain, target: self, action: #selector(doneClick1))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(cancelClickCity))
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
    
    func doneClick1() {
        
        cityID = "\(String(describing: (arrCity[selectedIndex] as [String:Any])["id"]!))"
        txtCity.resignFirstResponder()
    }
    
    func cancelClickCity() {
        
        txtCity.resignFirstResponder()
    }
    
    
    //MARK:- Date Picker
    
    func pickUp(_ textField : UITextField){
        
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.datePickerMode = UIDatePickerMode.date
        var components = DateComponents()
        components.year = -93
        let minDate = Calendar.current.date(byAdding: components, to: Date())
        components.year = -3
        let maxDate = Calendar.current.date(byAdding: components, to: Date())
        
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        txtMonth.inputView = self.datePicker
        
        if (UserDefaults.standard.string(forKey: Constant.AppLanguage)) == "English" {
            datePicker.locale = Locale.init(identifier: "en")
        }else{
            datePicker.locale = Locale.init(identifier: "pt")
        }
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .plain, target: self, action: #selector(EditProfileVC.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(EditProfileVC.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        txtMonth.inputAccessoryView = toolBar
    }
    
    func doneClick() {
        
        let dateFormatter1 = DateFormatter()
        
        dateFormatter1.dateStyle = .medium
        dateFormatter1.timeStyle = .none
        
        txtMonth.text = dateFormatter1.string(from: datePicker.date)
        txtMonth.resignFirstResponder()
    }
    
    func cancelClick() {
        txtMonth.resignFirstResponder()
    }
    
    //MARK:- TextFiled Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == txtMonth{
            self.pickUp(txtMonth)
        }
        
        if textField == txtCity{
            self.pickUpCity(txtCity)
        }
    }
    
    //MARK:- Image Picker
    
    func PickUpImage() {
        
        let alert = UIAlertController(title: "", message: NSLocalizedString("Please_Select_an_Option", comment: ""), preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default , handler:{ (UIAlertAction)in
            
            self.openCamera()
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Gallery", comment: ""), style: .default , handler:{ (UIAlertAction)in
            PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus)in
                switch status{
                case .denied:
                    break
                case .authorized:
                    self.gallery()
                    break
                default:
                    break
                }
            })
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: UIAlertActionStyle.cancel, handler:{ (UIAlertAction)in
            
        }))
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            
            let controller = alert.popoverPresentationController
            
            controller?.sourceView = self.view
            controller?.sourceRect = CGRect(x:self.view.frame.size.width/2, y: self.view.frame.size.height/2,width: 315,height: 230)
            controller?.permittedArrowDirections = UIPopoverArrowDirection.up
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openCamera(){
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
            
        }
    }
    
    func gallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let img = UIImagePickerController()
            img.delegate = self
            img.sourceType = UIImagePickerControllerSourceType.photoLibrary
            img.allowsEditing = false
            
            self.present(img, animated: true, completion: nil)
        }
    }
    
    func alertCameraAccessNeeded() {
        let settingsAppURL = URL(string: UIApplicationOpenSettingsURLString)!
        
        let alert = UIAlertController(
            title: "Need Camera Access",
            message: "Camera access is required to make full use of this app.",
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            
            imgProfilePicture.image = image
            ProfilePictureAPI()
            
        }else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imgProfilePicture.image = image
            ProfilePictureAPI()
        }
        else{
            
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Validations
    
    func Validation() {
        
        //        let providedEmailAddress = txtEmail.text
        //        let isEmailAddressValid = self.isValidEmailAddress(emailAddressString: providedEmailAddress!)
        
        if (txtYourName.text?.isEmpty)!{
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_your_name", comment: ""))
        }
            //        else if (txtEmail.text?.isEmpty)!{
            //            self.displayAlertMessage(messageToDisplay: "Please enter email")
            //        }else if !isEmailAddressValid{
            //            self.displayAlertMessage(messageToDisplay: "Please enter valid email")
            //        }
        else if (txtPhoneNumber.text?.isEmpty)!{
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_phone_number", comment: ""))
        }else if (txtCity.text?.isEmpty)!{
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_city", comment: ""))
        }else if (txtMonth.text?.isEmpty)!{
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_month", comment: ""))
        }else if (txtDate.text?.isEmpty)!{
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_date", comment: ""))
        }else if (txtYear.text?.isEmpty)!{
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_year", comment: ""))
        }else{
            
        }
    }
    
    //MARK:- Textfield Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if textField == txtYourName{
            
            guard let text = txtYourName.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 32 // Bool
            
        }else if textField == txtEmail{
            
            guard let text = txtEmail.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 48 // Bool
            
            
        }else if textField == txtPhoneNumber{
            
            guard let text = txtPhoneNumber.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 16 // Bool
            
        }else if textField == txtCity{
            
            guard let text = txtCity.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 16 // Bool
            
        }else if textField == txtDate{
            
            guard let text = txtDate.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 2 // Bool
            
        }else if textField == txtMonth{
            
            guard let text = txtMonth.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 16 // Bool
            
        }else{
            
            guard let text = txtYear.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 4 // Bool
            
        }
    }
    
    //MARK:- Button Actions
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSave(_ sender: Any) {
        
        if (txtYourName.text?.isEmpty)! {
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_your_name", comment: ""))
//        }else if (txtEmail.text?.isEmpty)! {
//            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_email", comment: ""))
//        }else if self.isValidEmailAddress(emailAddressString: txtEmail.text!){
//            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_valid_email", comment: ""))
        }else if (txtPhoneNumber.text?.isEmpty)!{
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_phone_number", comment: ""))
        }else if (txtPhoneNumber.text?.count)! < 9 {
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_valid_phone_number", comment: ""))
        }else if (txtCity.text?.isEmpty)! {
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_enter_city", comment: ""))
        }else{
            EditProfileAPI()
        }
    }
    
    @IBAction func btnChangePhoto(_ sender: Any) {
        PickUpImage()
    }
    
    @IBAction func btnMale(_ sender: Any) {
        strUserGender = "Male"
        btnMale.setImage(#imageLiteral(resourceName: "CheckedBox"), for: .normal)
        btnFemale.setImage(#imageLiteral(resourceName: "UncheckedBox"), for: .normal)
    }
    
    @IBAction func btnFemale(_ sender: Any) {
        strUserGender = "Female"
        btnMale.setImage(#imageLiteral(resourceName: "UncheckedBox"), for: .normal)
        btnFemale.setImage(#imageLiteral(resourceName: "CheckedBox"), for: .normal)
    }
    
    //MARK:- Calling API
    
    func GetProfileAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let parameters: Parameters = [
                
                "user_id" : "\(strUID!)"
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.GET_PROFILE_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        let strImgeUrl = data["data"][0]["profile_picture"].description
                        self.imgProfilePicture.sd_setImage(with: URL(string: strImgeUrl), placeholderImage: UIImage(named: "placeholder.png"))
                        self.txtYourName.text = data["data"][0]["full_name"].description
                        self.txtEmail.text = data["data"][0]["email"].description
                        self.txtPhoneNumber.text = data["data"][0]["mobile_number"].description
                        self.txtCity.text = data["data"][0]["user_city"].description
                        self.txtMonth.text = data["data"][0]["birth_date"].description
                        let strGender = data["data"][0]["user_gender"].description
                        if strGender == "Male"{
                            self.btnMale.setImage(#imageLiteral(resourceName: "CheckedBox"), for: .normal)
                            self.btnFemale.setImage(#imageLiteral(resourceName: "UncheckedBox"), for: .normal)
                        }else if strGender == "Female"{
                            self.btnMale.setImage(#imageLiteral(resourceName: "UncheckedBox"), for: .normal)
                            self.btnFemale.setImage(#imageLiteral(resourceName: "CheckedBox"), for: .normal)
                        }else{
                            self.btnMale.setImage(#imageLiteral(resourceName: "UncheckedBox"), for: .normal)
                            self.btnFemale.setImage(#imageLiteral(resourceName: "UncheckedBox"), for: .normal)
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
    
    func EditProfileAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let parameters: Parameters = [
                
                "user_id" : "\(strUID!)",
                "full_name" : txtYourName.text!,
                "email" : txtEmail.text!,
                "user_phone" : txtPhoneNumber.text!,
                "user_city" : txtCity.text!,
                "user_gender" : strUserGender,
                "user_birthdate" : txtMonth.text!
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.EDIT_PROFILE_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                        UserDefaults.standard.set(self.txtYourName.text?.description, forKey: Constant.USERDEFAULTS.FULL_NAME)
                        UserDefaults.standard.set(self.txtCity.text?.description, forKey: Constant.USERDEFAULTS.USER_CITY)
                        UserDefaults.standard.synchronize()
                        
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
    
    
    func ProfilePictureAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let image = imgProfilePicture.image
            let imgData = UIImageJPEGRepresentation(image!, 0.9)!
            var strBase64 = imgData.base64EncodedString(options: .lineLength64Characters)
            strBase64 = strBase64.replacingOccurrences(of: "\r\n", with: "", options: NSString.CompareOptions.literal, range: nil)
            
            let parameters: Parameters = [
                "user_id" : "\(strUID!)",
                "profile_picture" : strBase64
            ]
            
            //            print("Para",parameters)
            
            
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                
                print(imgData)
                multipartFormData.append(imgData, withName: "profile_picture",fileName: "file.png", mimeType: "image/png")
                
                for (key, value) in parameters {
                    
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            },to:Constant.APIs.CHANGE_PROFILEPPICTURE_API,method:.post,headers:nil)
            { (result) in
                switch result {
                case .success(let upload,_,_):
                    
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress: \(progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { response in
                        
                        print("Sucesss.............")
                        UserDefaults.standard.set(UIImagePNGRepresentation(self.imgProfilePicture.image!), forKey: "PROFILE_IMAGE")
                        UserDefaults.standard.synchronize()
                        self.SidebarAPI()
                    }
                    
                case .failure(let encodingError):
                    
                    print ("Fail......")
                    print(encodingError)
                }
            }
            
            SVProgressHUD.dismiss()
            
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
}
