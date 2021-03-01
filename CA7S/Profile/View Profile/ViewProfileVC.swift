//
//  ViewProfileVC.swift
//  CA7S
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD


class ViewProfileVC: UIViewController {

    @IBOutlet weak var imgUser: UIImageView!
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblUserLovePlace: UILabel!
    @IBOutlet weak var lblUserEmail: UILabel!
    @IBOutlet weak var lblUserPhone: UILabel!
    @IBOutlet weak var lblUserCity: UILabel!
    @IBOutlet weak var lblUserGender: UILabel!
    @IBOutlet weak var lblBirthday: UILabel!

    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var btnUnfollow: UIButton!
    
    var Follow_id = String()
    var isFromFollowers: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SetUI()
        ViewProfileAPI()
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
        
        let strViewerID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.VIEWER_ID)
        let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
        if "\(String(describing: strViewerID))" == "\(String(describing: strUID))" {
            btnFollow.isHidden = true
        }else{
            btnFollow.isHidden = false
        }
        
        lblHeader.text = NSLocalizedString("Profile", comment: "")
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        imgUser.layer.borderWidth = 2
        imgUser.layer.borderColor = UIColor.black.cgColor
        
        imgUser.layer.cornerRadius = imgUser.layer.frame.size.height / 2
        imgUser.clipsToBounds = true
        btnFollow.layer.cornerRadius = btnFollow.layer.frame.size.height / 2
        btnFollow.clipsToBounds = true
        btnFollow.layer.borderWidth = 1
        btnFollow.layer.borderColor = Constant.ColorConstant.darkPink.cgColor
        btnUnfollow.layer.cornerRadius = btnUnfollow.layer.frame.size.height / 2
        btnUnfollow.clipsToBounds = true
    }
    
    //MARK:- Button Actions
    
    @IBAction func btnBack(_ sender: Any){
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnFollow(_ sender: UIButton){
        let strUserStatus = sender.titleLabel?.text
        if self.isFromFollowers == true{
            if strUserStatus == "request" || strUserStatus == NSLocalizedString("pending", comment: "") || strUserStatus == "Request" || strUserStatus == NSLocalizedString("Pending", comment: "") || strUserStatus == "Pending +" || strUserStatus == "Em espera"  {
                
                let alert = UIAlertController(title: NSLocalizedString("Are_you_sure_you_want_to_remove?", comment: ""), message: "", preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: ""), style: .default , handler:{ (UIAlertAction)in
                    self.RemoveAPI()
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: UIAlertActionStyle.cancel, handler:{ (UIAlertAction)in
                    
                }))
                
                if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
                    
                    let controller = alert.popoverPresentationController
                    
                    controller?.sourceView = self.view
                    controller?.sourceRect = CGRect(x:self.view.frame.midX, y: self.view.frame.midY ,width: 315,height: 170)
                    controller?.permittedArrowDirections = UIPopoverArrowDirection.up
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }else{
                    self.present(alert, animated: true, completion: nil)
                }
//                self.UnfollowAPI()
            }else{
                self.FollowAPI()
            }
        }else{
            
            if strUserStatus == "following" || strUserStatus == "Following" || strUserStatus == NSLocalizedString("Following", comment: "") {
                
                
                let alert = UIAlertController(title: NSLocalizedString("Are_you_sure_you_want_to_unfollow?", comment: ""), message: "", preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Unfollow", comment: ""), style: .destructive , handler:{ (UIAlertAction)in
                    self.UnfollowAPI()
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: UIAlertActionStyle.cancel, handler:{ (UIAlertAction)in
                    
                }))
                
                if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
                    
                    let controller = alert.popoverPresentationController
                    
                    controller?.sourceView = self.view
                    controller?.sourceRect = CGRect(x:self.view.frame.midX, y: self.view.frame.midY ,width: 315,height: 170)
                    controller?.permittedArrowDirections = UIPopoverArrowDirection.up
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }else{
                    self.present(alert, animated: true, completion: nil)
                }
                
                
                
                
            }else{
                self.FollowAPI()
            }
        }
    }
    
    @IBAction func btnUnfollow(_ sender: Any){
        self.displayAlertMessage(messageToDisplay: NSLocalizedString("Under_Development", comment: ""))
    }
    
    //MARK:- API Calling
    
    func ViewProfileAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let parameters: Parameters = [
                
                "user_id" : "\(strUID!)",
                "view_id" : UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.VIEWER_ID)!
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.VIEW_PROFILE_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                print("******\n \n  \n \n \n \(response) \n \n \n \n \n ********")
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
//                        let strUserStatus =
                        
                        self.Follow_id = data["data"][0]["user_id"].description
                        
//                        if self.isFromFollowers == true{
                            //Remove
                            
                            
                            let strUserStatus = data["data"][0]["user_status"].description
                            
                            if strUserStatus == "following" {
                                self.btnFollow.setTitle(NSLocalizedString("Following", comment: ""), for: .normal)
                            }else if strUserStatus == "request" || strUserStatus == "pending" || strUserStatus == "Em espera"{
                                self.self.btnFollow.setTitle(NSLocalizedString("Pending", comment: ""), for: .normal)
                            }else if strUserStatus == "self"{
                                self.btnFollow.isHidden = true
                            }else{
                                self.btnFollow.isHidden = false
                                self.btnFollow.setTitle("\(NSLocalizedString("Follow", comment: "")) +", for: .normal)
                            }
                        
                        
//                            if data["data"][0]["followers"].description == "1"{
//                                self.btnFollow.setTitle("Remove", for: .normal)
//                            }else{
//                                self.btnFollow.setTitle("Follow", for: .normal)
//                            }
//                        }else{
                            //UnFollow
//                            if data["data"][0]["following"].description == "1"{
//                                self.btnFollow.setTitle("Unfollow", for: .normal)
//                            }else{
//                                self.btnFollow.setTitle("Follow", for: .normal)
//                            }
//                        }
                        
//                        if strUserStatus == "following"{
//                            self.btnFollow.setTitle("Unfollow", for: .normal)
//                        }else{
//                            self.btnFollow.setTitle("Follow", for: .normal)
//                        }
                        
                        let strImgeUrl = data["data"][0]["profile_picture"].description
                        self.imgUser.sd_setImage(with: URL(string: strImgeUrl), placeholderImage: UIImage(named: "placeholder.png"))
                        self.lblUsername.text = data["data"][0]["full_name"].description
                        self.lblUserCity.text = data["data"][0]["user_city"].description
                        self.lblUserEmail.text = data["data"][0]["email"].description
                        self.lblBirthday.text = data["data"][0]["birth_date"].description
                        if self.lblBirthday.text == ""{
                            self.lblBirthday.text = NSLocalizedString("Date_of_Birth", comment: "")
                        }
                        self.lblUserPhone.text = data["data"][0]["mobile_number"].description
                        if self.lblUserPhone.text == ""{
                            self.lblUserPhone.text = NSLocalizedString("Mobile_number", comment: "")
                        }
                        
                        self.lblUserGender.text = NSLocalizedString("Gender: ", comment: "") + NSLocalizedString(data["data"][0]["user_gender"].description, comment: "")
                        
//                        self.lblUserLovePlace.text = data["data"][0]["user_city"].description
                        
                        let loveAttachment = NSTextAttachment()
                        let iconsSize = CGRect(x: 0, y: 0, width: 18, height: 15)
                        let attributedString = NSMutableAttributedString(string: "I ")
                        loveAttachment.image = UIImage(named: "like_filled")
                        loveAttachment.bounds = iconsSize
                        attributedString.append(NSAttributedString(attachment: loveAttachment))
                        
                        attributedString.append(NSAttributedString(string: " \(data["data"][0]["user_city"].description)"))
                        self.lblUserLovePlace.attributedText = attributedString
                        
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
    
    func FollowAPI() {

        if Connectivity.isConnectedToInternet() {

            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)

            let parameters: Parameters = [
                "user_id" : "\(strUID!)",
                "follow_id" : Follow_id
            ]

            print("Para",parameters)

            Alamofire.request(Constant.APIs.FOLLOW_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in

                SVProgressHUD.dismiss()

                if let data = response.result.value {

                    print("**** \n \n \n \(data) \n \n \n*****")
                    
                    if data["status"] == "success" {
                        
//                        let strUserStatus = data["user_status"]
                        let strUserStatus = NSLocalizedString(data["user_status"].description, comment: "")
                        
                        if strUserStatus == "following" {
                            self.btnFollow.setTitle(NSLocalizedString("Following", comment: ""), for: .normal)
                        }else if strUserStatus == "request" || strUserStatus == "pending" || strUserStatus == "Pending"{
                            self.self.btnFollow.setTitle(NSLocalizedString("Pending", comment: ""), for: .normal)
                        }else if strUserStatus == "self"{
                            self.btnFollow.isHidden = true
                        }else{
                            self.btnFollow.isHidden = false
                            self.btnFollow.setTitle("\(NSLocalizedString("Follow", comment: "")) +", for: .normal)
                        }
                        
                        
//                        self.btnFollow.setTitle("\(data["user_status"]) +", for: .normal)
                        
                        let strMsg = data["message"]
                        
                        self.displayAlertMessage(messageToDisplay: strMsg.string!)
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

    func UnfollowAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let parameters: Parameters = [
                
                "user_id" : "\(strUID!)",
                "follow_id" : Follow_id
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.UNFOLLOW_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
//                        self.btnFollow.setTitle("\(data["user_status"]) +", for: .normal)


//                        let strUserStatus = data["user_status"]
                        let strUserStatus = NSLocalizedString(data["user_status"].description, comment: "")
                        
                        if strUserStatus == "following" {
                            self.btnFollow.setTitle(NSLocalizedString("Following", comment: ""), for: .normal)
                        }else if strUserStatus == "request" || strUserStatus == "pending" || strUserStatus == "Pending"{
                            self.self.btnFollow.setTitle(NSLocalizedString("Pending", comment: ""), for: .normal)
                        }else if strUserStatus == "self"{
                            self.btnFollow.isHidden = true
                        }else{
                            self.btnFollow.isHidden = false
                            self.btnFollow.setTitle("\(NSLocalizedString("Follow", comment: "")) +", for: .normal)
                        }

                        let strMsg = data["message"]
                        self.displayAlertMessage(messageToDisplay: strMsg.string!)
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
    
    func RemoveAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let parameters: Parameters = [
                
                "user_id" : Follow_id,
                "follow_id" :"\(strUID!)"
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.REMOVE_FRIEND_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    print("******\n \n  \n \n \n \(response) \n \n \n \n \n ********")
                    
                    if data["status"] == "success" {
                        
//                        let strUserStatus = data["user_status"].description
                        let strUserStatus = NSLocalizedString(data["user_status"].description, comment: "")
                        
                        if strUserStatus == "following" {
                            self.btnFollow.setTitle(NSLocalizedString("Following", comment: ""), for: .normal)
                        }else if strUserStatus == "request" || strUserStatus == "pending" || strUserStatus == "Em espera"{
                            self.self.btnFollow.setTitle(NSLocalizedString("Pending", comment: ""), for: .normal)
                        }else if strUserStatus == "self"{
                            self.btnFollow.isHidden = true
                        }else{
                            self.btnFollow.isHidden = false
                            self.btnFollow.setTitle("\(NSLocalizedString("Follow", comment: "")) +", for: .normal)
                        }
//                        self.btnFollow.setTitle("\(NSLocalizedString(data["user_status"].description, comment: "")) +", for: .normal)
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
