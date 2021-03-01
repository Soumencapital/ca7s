//
//  FollowersVC.swift
//  CA7S
//


import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD

class FollowersVC: UIViewController,UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var tblFollowers: UITableView!
    @IBOutlet weak var heightView: NSLayoutConstraint!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnCloseSearch: UIButton!
    
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var viewBorder: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNoDataFound = UILabel()
    
    var ArrImgUser = NSMutableArray()
    var ArrUserName = NSMutableArray()
    var ArrLovedPlace = NSMutableArray()
    var ArrFollowIDS = NSMutableArray()
    
    var arrData = [[String:AnyObject]]()
    
    var strCurrentPageIndex = Int()
    var strLastPageIndex = Int()
    var Follow_id = Int()
    
    var Index : Int?
    
    var isFromSearch: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FollowersAPI(CurrentPage: 1)
        
        viewBorder.layer.cornerRadius = 19
        viewBorder.layer.masksToBounds = true
        viewBorder.layer.borderColor = UIColor.init(red: 171.0/255.0, green: 0, blue: 147.0/255.0, alpha: 1).cgColor
        viewBorder.layer.borderWidth = 1.0
        
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
        lblTitle.text = NSLocalizedString("Followers", comment: "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Textfield Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        let length = text.count + string.count - range.length
        
        if length == 0 {
            self.arrData.removeAll()
            FollowersAPI(CurrentPage: 1)
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
        
        let cell:Followers_TBLCell = tableView.dequeueReusableCell(withIdentifier: "Followers_TBLCell") as! Followers_TBLCell
        
        cell.selectionStyle = .none
        
        var dictData = arrData[indexPath.row]
        
        cell.lblUsername.text = dictData["full_name"]?.description
        cell.lblPlaceName.text = dictData["user_city"]?.description
        
        let strImgeUrl = dictData["profile_picture"]?.description
        
        cell.imgUser.sd_setShowActivityIndicatorView(true)
        cell.imgUser.sd_setIndicatorStyle(.gray)
        
        cell.imgUser.sd_setImage(with: URL(string: strImgeUrl!), placeholderImage: UIImage(named: "placeholder.png"))
        
        let strUserStatus = dictData["user_status"]?.description
        
        if self.isFromSearch == true{
                cell.btnOption.isHidden = true
        }else{
            cell.btnOption.isHidden = false
        }
        
        
        
        if strUserStatus == "following" || strUserStatus == "Following" {
            cell.btnFollow.isHidden = false
//            cell.btnOption.isHidden = false
            cell.btnFollow.setTitleColor(Constant.ColorConstant.lightPink, for: .normal)
            cell.btnFollow.setTitle(NSLocalizedString("Following", comment: ""), for: .normal)
            cell.btnFollow.layer.cornerRadius = 3
            cell.btnFollow.layer.borderWidth = 1
            cell.btnFollow.layer.borderColor = Constant.ColorConstant.lightPink.cgColor
            cell.btnFollow.clipsToBounds = true
        }else if strUserStatus == "request" || strUserStatus == "Request"{
            cell.btnFollow.isHidden = false
//            cell.btnOption.isHidden = false
            cell.btnFollow.setTitleColor(Constant.ColorConstant.lightPink, for: .normal)
            cell.btnFollow.setTitle(NSLocalizedString("Pending", comment: ""), for: .normal)
            cell.btnFollow.layer.cornerRadius = 3
            cell.btnFollow.layer.borderWidth = 1
            cell.btnFollow.layer.borderColor = Constant.ColorConstant.lightPink.cgColor
            cell.btnFollow.clipsToBounds = true
        }else if strUserStatus == "pending" || strUserStatus == "Pending"{
            cell.btnFollow.isHidden = false
//            cell.btnOption.isHidden = false
            cell.btnFollow.setTitleColor(Constant.ColorConstant.lightPink, for: .normal)
            cell.btnFollow.setTitle(NSLocalizedString("Pending", comment: ""), for: .normal)
            cell.btnFollow.layer.cornerRadius = 3
            cell.btnFollow.layer.borderWidth = 1
            cell.btnFollow.layer.borderColor = Constant.ColorConstant.lightPink.cgColor
            cell.btnFollow.clipsToBounds = true
            
        }else if strUserStatus == "self"{
            cell.btnFollow.isHidden = true
            cell.btnOption.isHidden = true
        }else{
            cell.btnFollow.isHidden = false
//            cell.btnOption.isHidden = false
            cell.btnFollow.setTitleColor(Constant.ColorConstant.darkPink, for: .normal)
            cell.btnFollow.setTitle("\(NSLocalizedString("Follow", comment: "")) +", for: .normal)
            cell.btnFollow.layer.cornerRadius = 3
            cell.btnFollow.layer.borderWidth = 1
            cell.btnFollow.layer.borderColor = Constant.ColorConstant.darkPink.cgColor
            cell.btnFollow.clipsToBounds = true
        }
        
        Follow_id = dictData["id"] as! Int

        cell.btnFollow.tag = indexPath.row
//        cell.btnFollow.tag = Follow_id
        cell.btnFollow.addTarget(self, action: #selector(btnFollow(_:)), for: .touchUpInside)
//        cell.btnOption.tag = Follow_id
        cell.btnOption.tag = indexPath.row
        
        cell.btnOption.addTarget(self, action: #selector(btnOption(_:)), for: .touchUpInside)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var dictData = arrData[indexPath.row]
        UserDefaults.standard.set(dictData["id"] as! Int, forKey: Constant.USERDEFAULTS.VIEWER_ID)
        UserDefaults.standard.synchronize()
        self.PushToViewProfileController(StroyboardName: "Profile", "ViewProfileVC",isFromFollowers: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    @objc func btnFollow(_ sender: UIButton) {
        
        var dictData = arrData[sender.tag]
        
        Follow_id = dictData["id"] as! Int
        FollowAPI(sender: sender)
    }
    
    @objc func btnOption(_ sender: UIButton) {
        let alert = UIAlertController(title: NSLocalizedString("Are_you_sure_you_want_to_remove?", comment: ""), message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: ""), style: .default , handler:{ (UIAlertAction)in
            
            var dictData = self.arrData[sender.tag]
            
            self.Follow_id = dictData["id"] as! Int
            
            self.RemoveAPI(sender: sender)
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
    
    //MARK:- Button ActionsappLogoPing
    
    @IBAction func btnBack(_ sender: Any){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSearch(_ sender: Any){
        viewSearch.isHidden = false
        heightView.constant = 50
    }
    
    @IBAction func btnCloseSearch(_ sender: Any){
        arrData.removeAll()
        txtSearch.text = ""
        FollowersAPI(CurrentPage: 1)
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
                    FollowersAPI(CurrentPage: NewPageNo)
                }else{
                    SearchUserAPI(CurrentPage: NewPageNo)
                }
            }
        }
    }
    
    //MARK:- API Calling
    
    func FollowersAPI(CurrentPage: Int) {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let parameters: Parameters = [
                
                "user_id" : "\(strUID!)",
                "page" : CurrentPage
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.FOLLOWERS_LIST_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
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
                                self.isFromSearch = false
                                self.tblFollowers.reloadData()
                                
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
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
        
                            print("***** \n \n \n \(data) \n \n \n ******")
                        
                        if let arrSearchResponse =  data["list"]["data"].arrayObject{
                            
                            self.strCurrentPageIndex = data["list"]["current_page"].intValue
                            self.strLastPageIndex = data["list"]["total"].intValue
                            
                            if CurrentPage == 1{
                                self.arrData.removeAll()
                            }
                            
                            if self.arrData.count == 0 {
                                self.arrData = arrSearchResponse as! [[String:AnyObject]]
                                self.isFromSearch = true
                                self.tblFollowers.reloadData()
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
    
    func RemoveAPI(sender: UIButton) {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let parameters: Parameters = [
                
                "user_id" : "\(strUID!)",
                "follow_id" : Follow_id
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.REMOVE_FRIEND_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    print("******\n \n  \n \n \n \(response) \n \n \n \n \n ********")
                    
                    let objIndexPath = IndexPath(row: sender.tag, section: 0)
                    let cell = self.tblFollowers.cellForRow(at: objIndexPath) as? Followers_TBLCell
                    cell?.btnFollow.setTitle("\(NSLocalizedString(data["user_status"].description, comment: "")) +", for: .normal)

                    
                    
                    if data["status"] == "success" {
                        
//                        sender.setTitle("\(data["user_status"])", for: .normal)
                        
                        DispatchQueue.main.async {
                            self.FollowersAPI(CurrentPage: 1)
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
    
//    func FollowAPI() {
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
                
                print("******\n \n  \n \n \n \(response) \n \n \n \n \n ********")
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                      
//                        sender.setTitle("\(data["user_status"])", for: .normal)
                        
                        
                        let objIndexPath = IndexPath(row: sender.tag, section: 0)
                        let cell = self.tblFollowers.cellForRow(at: objIndexPath) as? Followers_TBLCell
                        cell?.btnFollow.setTitle("\(data["user_status"])", for: .normal)
                        
//                        arrData[indexPath.row]
                        
                        
                        if self.viewSearch.isHidden {
                            self.FollowersAPI(CurrentPage: 1)
                        }else{
                            self.SearchUserAPI(CurrentPage: 1)
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
