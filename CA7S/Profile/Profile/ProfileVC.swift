//
//  ProfileVC.swift
//  CA7S
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD


class ProfileVC: UIViewController {
    
    @IBOutlet weak var imgProfilePicture: UIImageView!
    
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblLovedPlace: UILabel!
    @IBOutlet weak var lblNoOfFollowers: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblNoOfFollowing: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet var lblRequestCount: UILabel!
    
    @IBOutlet weak var btnEditProfile: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblFavourite: UILabel!
    @IBOutlet weak var lblAddMusic: UILabel!
    @IBOutlet weak var lblMyMusic: UILabel!
    
    //MARK:-
    //MARK:- ViewController LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblRequestCount.layer.cornerRadius = lblRequestCount.frame.size.width/2
        self.lblRequestCount.layer.masksToBounds = true
        
        btnMenu.addTarget(self, action:#selector(SSASideMenu.presentLeftMenuViewController), for: .touchUpInside)
        SetUI()
        GetProfileAPI()
        SidebarAPI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setLocalizationString()
        self.GetProfileAPI()
    }
    
    func setLocalizationString(){
        self.lblUsername.text = NSLocalizedString("Your_name", comment: "")
        self.lblFollowers.text = NSLocalizedString("Followers", comment: "")
        self.lblFollowing.text = NSLocalizedString("Following", comment: "")
        self.lblHeader.text = NSLocalizedString("Profile", comment: "")
        self.lblFavourite.text = NSLocalizedString("Favourites", comment: "")
        self.lblMyMusic.text = NSLocalizedString("My_Music", comment: "")
        self.lblAddMusic.text = NSLocalizedString("Add_Music", comment: "")
        
        btnEditProfile.setTitle(NSLocalizedString("EDIT_PROFILE", comment: ""), for: .normal)
    }
    
    
    func SetUI() {
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        imgProfilePicture.layer.cornerRadius = imgProfilePicture.layer.frame.size.height / 2
        imgProfilePicture.clipsToBounds = true
        imgProfilePicture.layer.borderWidth = 2
        imgProfilePicture.layer.borderColor = UIColor.white.cgColor
        
        btnEditProfile.layer.cornerRadius = btnEditProfile.layer.frame.size.height / 2
        btnEditProfile.clipsToBounds = true
        btnEditProfile.layer.borderWidth = 1
        btnEditProfile.layer.borderColor = Constant.ColorConstant.darkPink.cgColor
    }
    
    //MARK:-
    //MARK:- Button Actions

    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddUser(_ sender: Any) {
        
        self.lblRequestCount.isHidden = true
        self.lblRequestCount.text = "0"
        
        self.PushToController(StroyboardName: "Profile", "PendingRequestVC")
    }
    
    @IBAction func btnViewSelfProfile(_ sender: Any) {
        let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
        UserDefaults.standard.set(strUID!, forKey: Constant.USERDEFAULTS.VIEWER_ID)
        UserDefaults.standard.synchronize()
        self.PushToController(StroyboardName: "Profile", "ViewProfileVC")
    }
    
    @IBAction func btnFollowres(_ sender: Any) {
        self.PushToController(StroyboardName: "Profile", "FollowersVC")
    }
    
    @IBAction func btnFollowing(_ sender: Any) {
        self.PushToController(StroyboardName: "Profile", "FollowingVC")
    }
    
    @IBAction func btnEditProfile(_ sender: Any) {
        self.PushToController(StroyboardName: "Profile", "EditProfileVC")
    }
    
    @IBAction func btnFavourite(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.mainTabBarController?.selectedIndex = 3
        sideMenuViewController?.contentViewController = UINavigationController(rootViewController: appDelegate.mainTabBarController!)
        sideMenuViewController?.hideMenuViewController()
    }
    
    @IBAction func btnMyMusic(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.mainTabBarController?.selectedIndex = 2
        sideMenuViewController?.contentViewController = UINavigationController(rootViewController: appDelegate.mainTabBarController!)
        sideMenuViewController?.hideMenuViewController()
    }
    
    @IBAction func btnAddMusic(_ sender: Any) {
        self.PushToController(StroyboardName: "Profile", "UploadedMusicVC")
    }
    
    //MARK:- API Calling
    
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
                        
                        
                        if data["request_count"].description == "0"{
                            self.lblRequestCount.isHidden = true
                        }else{
                            self.lblRequestCount.isHidden = false
                            self.lblRequestCount.text = data["request_count"].description
                        }
                        
                        
                        let strImgeUrl = data["data"][0]["profile_picture"].description
                        self.imgProfilePicture.sd_setImage(with: URL(string: strImgeUrl), placeholderImage: UIImage(named: "placeholder.png"))
                        self.lblUsername.text = data["data"][0]["full_name"].description
                        self.lblLovedPlace.text = data["data"][0]["user_city"].description
                        self.lblNoOfFollowers.text = data["data"][0]["followers"].description
                        self.lblNoOfFollowing.text = data["data"][0]["following"].description
                       
                        let loveAttachment = NSTextAttachment()
                        let iconsSize = CGRect(x: 0, y: 0, width: 18, height: 15)
                        let attributedString = NSMutableAttributedString(string: "I ")
                        loveAttachment.image = UIImage(named: "like_filled")
                        loveAttachment.bounds = iconsSize
                        attributedString.append(NSAttributedString(attachment: loveAttachment))
                        
                        attributedString.append(NSAttributedString(string: " \(data["data"][0]["user_city"].description)"))
                        self.lblLovedPlace.attributedText = attributedString
                        
                        
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
