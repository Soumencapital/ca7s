//
//  FollowingVC.swift
//  CA7S
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD


class FollowingVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet var tblFollowing: UITableView!
    
    @IBOutlet weak var heightView: NSLayoutConstraint!
    
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var btnCloseSearch: UIButton!
    @IBOutlet weak var lblNoDataFound = UILabel()
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var viewBorder: UIView!
    
    var ArrImgFollowingUser = NSMutableArray()
    var ArrUserName = NSMutableArray()
    var ArrLovedPlace = NSMutableArray()
    
    var arrData = [[String:AnyObject]]()
    
    var strCurrentPageIndex = Int()
    var strLastPageIndex = Int()
    var Follow_id = Int()
    
    var Index : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewBorder.layer.cornerRadius = 19
        viewBorder.layer.masksToBounds = true
        viewBorder.layer.borderColor = UIColor.init(red: 171.0/255.0, green: 0, blue: 147.0/255.0, alpha: 1).cgColor
        viewBorder.layer.borderWidth = 1.0
        
//        let leftView = UIImageView(image: UIImage(named: "Search_Pink"))
//        
//        leftView.frame = CGRect(x: 0.0, y: 0.0, width: (((leftView.image?.size.width) ?? 0.0) + (5)), height: ((leftView.image?.size.height ?? 0.0)))
//        
//        leftView.contentMode = .center
//        
//        txtSearch.leftViewMode = .always
//        txtSearch.leftView = leftView
        
//        txtSearch.leftViewMode = UITextFieldViewMode.always
//        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
//        imageView.contentMode = .scaleToFill
//        let image = UIImage(named: "Search_Pink")
//        imageView.image = image
//        txtSearch.leftView = imageView
        
        
        FollowingAPI(CurrentPage: 1)
        
        viewSearch.isHidden = true
        heightView.constant = 0
        
        lblNoDataFound?.text = NSLocalizedString("No_Data_Found", comment: "")
        lblNoDataFound?.isHidden = true
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.txtSearch.placeholder = NSLocalizedString("Search", comment: "")
        self.lblTitle.text = NSLocalizedString("Following", comment: "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        let length = text.count + string.count - range.length
        
        if length == 0 {
            self.arrData.removeAll()
            FollowingAPI(CurrentPage: 1)
        }
        if length == 1 {
            print("1 Count")
        }
        if length == 2 {
            print("2 Count")
        }
        if length >= 3 {
            self.arrData.removeAll()
            SearchUserAPI(CurrentPage: 1)
        }
        
        return length <= 55 // To just allow up to 55 characters
    }
    
    //MARK:- Table Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:Following_TBLCell = tableView.dequeueReusableCell(withIdentifier: "Following_TBLCell") as! Following_TBLCell
        
        cell.selectionStyle = .none
        
        var dictData = arrData[indexPath.row]
        
        cell.lblUsername.text = dictData["full_name"]?.description
        cell.lblPlaceName.text = dictData["user_city"]?.description
        
        let strImgeUrl = dictData["profile_picture"]?.description
        
        cell.imgUser.sd_setShowActivityIndicatorView(true)
        cell.imgUser.sd_setIndicatorStyle(.gray)
        
        cell.imgUser.sd_setImage(with: URL(string: strImgeUrl!), placeholderImage: UIImage(named: "placeholder.png"))
        
        let strUserStatus = dictData["user_status"]?.description
        if strUserStatus == "following" || strUserStatus == "Following" {
            cell.btnFollowing.isHidden = false
            cell.btnOption.isHidden = false
            cell.btnFollowing.setTitleColor(Constant.ColorConstant.lightPink, for: .normal)
            cell.btnFollowing.setTitle(NSLocalizedString("Following", comment: ""), for: .normal)
            cell.btnFollowing.layer.cornerRadius = 3
            cell.btnFollowing.layer.borderWidth = 1
            cell.btnFollowing.layer.borderColor = Constant.ColorConstant.lightPink.cgColor
            cell.btnFollowing.clipsToBounds = true
        }else if strUserStatus == "pending" || strUserStatus == "Pending"{
            cell.btnFollowing.isHidden = false
            cell.btnOption.isHidden = false
            cell.btnFollowing.setTitleColor(Constant.ColorConstant.lightPink, for: .normal)
            cell.btnFollowing.setTitle(NSLocalizedString("Pending", comment: ""), for: .normal)
            cell.btnFollowing.layer.cornerRadius = 3
            cell.btnFollowing.layer.borderWidth = 1
            cell.btnFollowing.layer.borderColor = Constant.ColorConstant.lightPink.cgColor
            cell.btnFollowing.clipsToBounds = true
        }else if strUserStatus == "request" || strUserStatus == "Request"{
            cell.btnFollowing.isHidden = false
            cell.btnOption.isHidden = false
            cell.btnFollowing.setTitleColor(Constant.ColorConstant.lightPink, for: .normal)
            cell.btnFollowing.setTitle(NSLocalizedString("Pending", comment: ""), for: .normal)
            cell.btnFollowing.layer.cornerRadius = 3
            cell.btnFollowing.layer.borderWidth = 1
            cell.btnFollowing.layer.borderColor = Constant.ColorConstant.lightPink.cgColor
            cell.btnFollowing.clipsToBounds = true
        }else if strUserStatus == "self"{
            cell.btnFollowing.isHidden = true
            cell.btnOption.isHidden = true
        }else{
            cell.btnFollowing.isHidden = false
            cell.btnOption.isHidden = false
            cell.btnFollowing.setTitleColor(Constant.ColorConstant.darkPink, for: .normal)
//            cell.btnFollowing.setTitle("Follow +", for: .normal)
            cell.btnFollowing.setTitle("\(NSLocalizedString("Follow", comment: "")) +", for: .normal)
            cell.btnFollowing.layer.cornerRadius = 3
            cell.btnFollowing.layer.borderWidth = 1
            cell.btnFollowing.layer.borderColor = Constant.ColorConstant.darkPink.cgColor
            cell.btnFollowing.clipsToBounds = true
            cell.btnFollowing.tag = Follow_id
            cell.btnFollowing.addTarget(self, action: #selector(btnFollowing(_:)), for: .touchUpInside)
        }
        
        Follow_id = dictData["id"] as! Int
        
//        cell.btnFollowing.tag = Follow_id
//        cell.btnFollowing.addTarget(self, action: #selector(btnFollowing(_:)), for: .touchUpInside)
//        cell.btnOption.tag = Follow_id
        
        cell.btnFollowing.tag = indexPath.row
        cell.btnOption.tag = indexPath.row
        
        cell.btnOption.addTarget(self, action: #selector(btnOption(_:)), for: .touchUpInside)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var dictData = arrData[indexPath.row]
        UserDefaults.standard.set(dictData["id"] as! Int, forKey: Constant.USERDEFAULTS.VIEWER_ID)
        UserDefaults.standard.synchronize()
        
        self.PushToViewProfileController(StroyboardName: "Profile", "ViewProfileVC",isFromFollowers: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    @objc func btnFollowing(_ sender: UIButton) {
        var dictData = arrData[sender.tag]
        
        Follow_id = dictData["id"] as! Int
        FollowAPI(sender: sender)
    }
    
    
    @objc func btnOption(_ sender: UIButton) {
        
        let alert = UIAlertController(title: NSLocalizedString("Are_you_sure_you_want_to_unfollow?", comment: ""), message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Unfollow", comment: ""), style: .destructive , handler:{ (UIAlertAction)in
            
            var dictData = self.arrData[sender.tag]
            
            self.Follow_id = dictData["id"] as! Int
            self.UnfollowAPI(sender: sender)
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
    }
    
    //MARK:- Button Actions
    
    @IBAction func btnBack(_ sender: Any){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSearch(_ sender: Any){
        viewSearch.isHidden = false
        heightView.constant = 50
    }
    
    @IBAction func btnCloseSearch(_ sender: Any){
        txtSearch.text = ""
        arrData.removeAll()
        FollowingAPI(CurrentPage: 1)
        viewSearch.isHidden = true
        heightView.constant = 0
    }
    
    //MARK:- Paggination Method
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if strCurrentPageIndex == strLastPageIndex{
            
            print("Page Complated")
            
        }else{
            if maximumOffset - currentOffset <= 10.0 {
                var NewPageNo = strCurrentPageIndex
                NewPageNo = NewPageNo + 1
                if viewSearch.isHidden {
                    FollowingAPI(CurrentPage: NewPageNo)
                }else{
                    SearchUserAPI(CurrentPage: NewPageNo)
                }
            }
        }
    }
    
    //MARK:- API Calling
    
    func FollowingAPI(CurrentPage: Int) {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let parameters: Parameters = [
                
                "user_id" : "\(strUID!)",
                "page" : CurrentPage
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.FOLLOWING_LIST_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                        if let arrSearchResponse =  data["list"]["data"].arrayObject{
                            
                            self.strCurrentPageIndex = data["list"]["current_page"].intValue
                            self.strLastPageIndex = data["list"]["total"].intValue
                            
                            if CurrentPage == 1{
                                self.arrData.removeAll()
                            }
                            
//                            if self.arrData.count == 0 {
                                self.arrData = arrSearchResponse as! [[String:AnyObject]]
                                self.tblFollowing.reloadData()
//                            } else {
//
//                            }
                            if self.arrData.count == 0 {
                                self.lblNoDataFound?.isHidden = false
                            }else{
                                self.lblNoDataFound?.isHidden = true
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
    
    func SearchUserAPI(CurrentPage: Int) {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let parameters: Parameters = [
                
                "user_id" : "\(strUID!)",
                "search_text" : txtSearch.text!,
                "page" : CurrentPage
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.SEARCH_USER_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
//                user_token
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                        if let arrSearchResponse =  data["list"]["data"].arrayObject{
                            
                            self.strCurrentPageIndex = data["list"]["current_page"].intValue
                            self.strLastPageIndex = data["list"]["total"].intValue
                            
                            if CurrentPage == 1{
                                self.arrData.removeAll()
                            }
                            
                            if self.arrData.count == 0 {
                                self.arrData = arrSearchResponse as! [[String:AnyObject]]
                                self.tblFollowing.reloadData()
                            } else {
                                
                            }
                            if self.arrData.count == 0 {
                                self.lblNoDataFound?.isHidden = false
                            }else{
                                self.lblNoDataFound?.isHidden = true
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
    
    func UnfollowAPI(sender: UIButton) {
        
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
                        
                        self.FollowingAPI(CurrentPage: 1)
                        self.tblFollowing.reloadData()
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
    
    func FollowAPI(sender: UIButton) {
        
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
                    
                    print("******\n \n  \n \n \n \(response) \n \n \n \n \n ********")
                    
                    if data["status"] == "success" {
                        
                        let objIndexPath = IndexPath(row: sender.tag, section: 0)
                        let cell = self.tblFollowing.cellForRow(at: objIndexPath) as? Following_TBLCell
                        cell?.btnFollowing.setTitle("\(data["user_status"])", for: .normal)
                        
                        self.SearchUserAPI(CurrentPage: 1)
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
