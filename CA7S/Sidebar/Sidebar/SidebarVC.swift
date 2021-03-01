//
//  SidebarVC.swift
//  CA7S
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD
import WebKit
import StoreKit

class SidebarVC: UIViewController,UITableViewDelegate,UITableViewDataSource, WKNavigationDelegate {
    
    @IBOutlet var tblMenuList: UITableView!
    @IBOutlet weak var imgProfilePicture: UIImageView!
    @IBOutlet weak var lblYourName: UILabel!
    @IBOutlet weak var lblVersion: UILabel!
    
    var menuItemName =  ["Notifications", "Discover", "Settings", "About Us", "Help", "Terms of privacy policy", "Share App", "Rate Us", "Sign In"]
    var menuIcons = [UIImage(named: "Path 1"), UIImage(named: "Path 279"), UIImage(named: "Settings"),UIImage(named: "Information"),UIImage(named: "Help"),UIImage(named: "Yes"),UIImage(named: "share"), UIImage(named: "Favorite"),UIImage(named: "Export")]
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        SetUI()
        
        
        //self.view.roundCorners([.bottomRight], radius: 20)

        view.clipsToBounds = false
        view.layer.cornerRadius = 10
        if #available(iOS 11.0, *) {
            view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        
        //self.view.layer.cornerRadius = 20
        //self.view.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        SetUI()
        
        if let _ = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID) {
            menuItemName[8] = NSLocalizedString("Sign out", comment: "")
        }
        
        let username = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_NAME)
        let fullname = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.FULL_NAME)
        let city = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_CITY)
        
        let strImageUrl = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.PROFILE_PICTURE) as? String
        if strImageUrl != nil{
            self.imgProfilePicture.sd_setImage(with: URL(string: strImageUrl!), placeholderImage: UIImage(named: "placeholder.png"))
        }
        else {
        
            self.imgProfilePicture.image = UIImage(named: "placeholder.png")
        }
        
        if fullname != nil {
         
            let textRange = NSRange(location: 0, length: ("\(fullname!)".count))
            let attributedText = NSMutableAttributedString(string: "\(fullname!)")
            attributedText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: textRange)
           // lblYourName.text = "Text"
            lblYourName.attributedText = attributedText
            
            //lblYourName.text = "\(fullname!)"
        }
//        if city != nil {
//            lblUserLovedPlace.text = "\(city!)"
//        }
//        if username != nil {
//            lblUsername.text = "\(username!)"
//        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func SetUI() {
        
        UIApplication.shared.statusBarStyle = .lightContent
        UINavigationBar.appearance().barStyle = .blackOpaque
          lblVersion.text = NSLocalizedString("Copyright Ca7s 2019", comment: "")
        tblMenuList.reloadData()
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        imgProfilePicture.layer.cornerRadius = imgProfilePicture.layer.frame.size.height / 2
        imgProfilePicture.clipsToBounds = true
    }
    
 
    
    //MARK:- Table Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItemName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:Sidebar_TBLCell = tableView.dequeueReusableCell(withIdentifier: "Sidebar_TBLCell") as! Sidebar_TBLCell
       cell.menuimage.image = self.menuIcons[indexPath.row]
        cell.menuTitle.text = NSLocalizedString(self.menuItemName[indexPath.row], comment: "")
        return cell
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.row == 1 {
            
//            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
//            let centerViewController = mainStoryboard.instantiateViewController(withIdentifier: "Dashboard_TabbarVC")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.mainTabBarController?.selectedIndex = 0
            sideMenuViewController?.contentViewController = UINavigationController(rootViewController: appDelegate.mainTabBarController!)
            sideMenuViewController?.hideMenuViewController()
        }
        
        if indexPath.row == 0 {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let centerViewController = mainStoryboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
            centerViewController.isFrom = "MENU"
            sideMenuViewController?.contentViewController = UINavigationController(rootViewController: centerViewController)
            sideMenuViewController?.hideMenuViewController()
        }
        
        if indexPath.row == 2 {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
            let centerViewController = mainStoryboard.instantiateViewController(withIdentifier: "SettingsVC")
            sideMenuViewController?.contentViewController = UINavigationController(rootViewController: centerViewController)
            sideMenuViewController?.hideMenuViewController()
        }
        
        if indexPath.row == 3 {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let centerViewController = mainStoryboard.instantiateViewController(withIdentifier: "AboutVC")
            sideMenuViewController?.contentViewController = UINavigationController(rootViewController: centerViewController)
            sideMenuViewController?.hideMenuViewController()
        }
        
        if indexPath.row == 4 {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let centerViewController = mainStoryboard.instantiateViewController(withIdentifier: "HelpVC")
            sideMenuViewController?.contentViewController = UINavigationController(rootViewController: centerViewController)
            sideMenuViewController?.hideMenuViewController()
        }
        
        if indexPath.row == 5 {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let centerViewController = mainStoryboard.instantiateViewController(withIdentifier: "TermsAndConditionVC") as? TermsAndConditionVC
            sideMenuViewController?.contentViewController = UINavigationController(rootViewController: centerViewController!)
            centerViewController?.screen_id = 0
//            centerViewController.screen_id = 0
            sideMenuViewController?.hideMenuViewController()
        }
        
        if indexPath.row == 6 {
            
            // text to share
          let url = URL(string: "https://apps.apple.com/us/app/ca7s/id1365704623")
            
            // set up activity view controller
            let textToShare = [url]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // exclude some activity types from the list (optional)
            activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
             sideMenuViewController?.hideMenuViewController()
            
                  }
        
        if indexPath.row == 7 {
             sideMenuViewController?.hideMenuViewController()
            rateApp(appId: "1365704623")
            
        }
        
        if indexPath.row == 8 {
            
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            if strUID == nil{
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                //            present(vc, animated: true, completion: nil)
                //            self.navigationController?.pushViewController(vc, animated: true)
                
                sideMenuViewController?.contentViewController = UINavigationController(rootViewController: vc)
                sideMenuViewController?.hideMenuViewController()
                
            }else{
                
                sideMenuViewController?.hideMenuViewController()
                
                // create the alert
                let alert = UIAlertController(title: "", message: NSLocalizedString("Are_you_sure_you_want_to_logout", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.default, handler: { action in
                    
                    self.LogoutAPI()
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: UIAlertActionStyle.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    
    }
    
    
    fileprivate func rateApp(appId: String) {
        openUrl("itms-apps://itunes.apple.com/app/" + appId)
        
    }
    fileprivate func openUrl(_ urlString:String) {
        let url = URL(string: urlString)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return (tableView.frame.height - 150) / 9
        
//        if indexPath.row == ArrTitleMenu.count{
//            return UITableViewAutomaticDimension
//        }else{
//            return 38.0
//        }
    }
    
    //MARK:- Button Action
    
    @IBAction func btnProfile(_ sender: Any) {
        
        
        let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
        
        if strUID == nil{
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            //            present(vc, animated: true, completion: nil)
//            self.navigationController?.pushViewController(vc, animated: true)
            
            sideMenuViewController?.contentViewController = UINavigationController(rootViewController: vc)
            sideMenuViewController?.hideMenuViewController()
            
        }else{
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let centerViewController = mainStoryboard.instantiateViewController(withIdentifier: "ProfileVC")
        self.sideMenuViewController?.contentViewController = UINavigationController(rootViewController: centerViewController)
        self.sideMenuViewController?.hideMenuViewController()
        }
    }
    
    @IBAction func btnRateUs(_ sender: Any) {
        
        sideMenuViewController?.hideMenuViewController()
        
        var webView: WKWebView!
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        
        let strRateUrl = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.RATE_US_URL) as? String
        if strRateUrl != nil{
            let url = URL(string: strRateUrl!)
            webView.load(URLRequest(url: url!))
            webView.allowsBackForwardNavigationGestures = true
            
        }else {
                self.displayAlertMessage(messageToDisplay: NSLocalizedString("Something_went_wrong", comment: ""))
        }
        
        
    }
    
    @IBAction func btnShare(_ sender: Any) {
        self.displayAlertMessage(messageToDisplay: NSLocalizedString("Under_Development", comment: ""))
    }
    
    @IBAction func btnLogout(_ sender: Any) {
        
        let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
        
        if strUID == nil {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            //            present(vc, animated: true, completion: nil)
            //            self.navigationController?.pushViewController(vc, animated: true)
            
            sideMenuViewController?.contentViewController = UINavigationController(rootViewController: vc)
            sideMenuViewController?.hideMenuViewController()
            
        }else {
        
            sideMenuViewController?.hideMenuViewController()
        
        // create the alert
        let alert = UIAlertController(title: "", message: NSLocalizedString("Are_you_sure_you_want_to_logout", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.default, handler: { action in
            
            self.LogoutAPI()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    //MARK: Calling API
    
    func LogoutAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            
            Alamofire.request(Constant.APIs.LOGOUT_API, method: .post, parameters: nil , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"].description == "Success" {
                        
                        CAMusicViewController.sharedInstance().stop()
                        
                        DispatchQueue.main.async {
                            let defaults = UserDefaults.standard
                            defaults.set(false, forKey: Constant.appConstants.IS_LOGIN)
                            defaults.set(false, forKey: Constant.isUploadMusicFirstTime)
                            defaults.set(false, forKey: Constant.isTapToScanFirstTime)
                            defaults.set(false, forKey: Constant.isUploadSongsStepsFirstTime1)
                            defaults.set(false, forKey: Constant.isUploadSongsStepsFirstTime2)
                            defaults.set(false, forKey: Constant.isUploadSongsStepsFirstTime3)
                            defaults.synchronize()
                            
                            
                            UserDefaults.standard.set(nil, forKey: Constant.USERDEFAULTS.USER_ID);
                            UserDefaults.standard.set("", forKey: Constant.USERDEFAULTS.FULL_NAME)
                            UserDefaults.standard.set("", forKey: Constant.USERDEFAULTS.USER_NAME)
                            UserDefaults.standard.set("", forKey: Constant.USERDEFAULTS.USER_CITY)
                            UserDefaults.standard.set("", forKey: Constant.USERDEFAULTS.PROFILE_PICTURE)
                            UserDefaults.standard.set("", forKey: Constant.USERDEFAULTS.RATE_US_URL)
                            UserDefaults.standard.set(nil, forKey: Constant.USERDEFAULTS.LOCAL_PLAYLIST)
                            
                            let local = NSLocale.current.languageCode!
                            
                            print(local)
                            
                            if local == "pt"{
                                
                                L102Language.setAppleLAnguageTo(lang: "pt")
                                
                                UserDefaults.standard.set("Portugese", forKey: Constant.AppLanguage)
                                
                            }else{
                                
                                L102Language.setAppleLAnguageTo(lang: "en")
                                
                                UserDefaults.standard.set("English", forKey: Constant.AppLanguage)
                                
                            }
                            
                            
                        }
                        
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let centerViewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginVC")
                        self.sideMenuViewController?.contentViewController = UINavigationController(rootViewController: centerViewController)
                        self.sideMenuViewController?.panGestureEnabled = false
                        self.sideMenuViewController?.hideMenuViewController()
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
extension UIView {
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        self.layer.masksToBounds = true
    }
}
