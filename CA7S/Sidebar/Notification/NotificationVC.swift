//
//  NotificationVC.swift
//  CA7S
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD


class NotificationVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var tblNotification: UITableView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var lblNoDataFound: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    var isFrom = String()
    
    var arrData = [[String:AnyObject]]()
    
    var strCurrentPageIndex = Int()
    var strLastPageIndex = Int()
    var Message_id = Int()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SetUI()
        
        NotificationListAPI(CurrentPage: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setLocalizationString(){
        lblNoDataFound.text = NSLocalizedString("No_Data_Found", comment: "")
        self.lblTitle.text = NSLocalizedString("Notifications", comment: "")
    }
    
    func SetUI() {
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isHidden = true
        
        self.setLocalizationString()
        
        if isFrom == "MENU"{
            btnMenu.setImage(#imageLiteral(resourceName: "Menu_White"), for: .normal)
            btnMenu.addTarget(self, action:#selector(SSASideMenu.presentLeftMenuViewController), for: .touchUpInside)
            
        }else{
            btnMenu.setImage(#imageLiteral(resourceName: "btnBack"), for: .normal)
        }
    }
    
    //MARK:- Table Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:Notification_TBLCell = tableView.dequeueReusableCell(withIdentifier: "Notification_TBLCell") as! Notification_TBLCell
        
        cell.selectionStyle = .none
        
        var dictData = arrData[indexPath.row]
        cell.lblSongUploadBefore.isHidden = false
        cell.lblSongTitle.text = dictData["title"]?.description
      //  cell.lblSongDescription.text = "Dummy Description..."
        cell.lblSongUploadBefore.text = dictData["created_at"]?.description
        cell.lblDesc.text = dictData["message"]?.description
        
        
//        cell.imgSong.image = UIImage(named: "profile_user")
        let strImgeUrl = dictData["profile_picture"]?.description
        
        cell.imgSong.sd_setShowActivityIndicatorView(true)
        cell.imgSong.sd_setIndicatorStyle(.gray)
        
        cell.imgSong.sd_setImage(with: URL(string: strImgeUrl!), placeholderImage: UIImage(named: "placeholder.png"))
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
//        return 85.0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: NSLocalizedString("Remove", comment: "")) { (action, indexPath) in
            
            var dictData = self.arrData[indexPath.row]
            let intMsgID = dictData["id"]
            
            let alertController = UIAlertController(title:"", message: NSLocalizedString("Would_you_like_to_delete_this_notification?", comment: ""), preferredStyle: .alert)
            let OKAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .default) { (action:UIAlertAction!) in
                
                self.DeleteSingleNotificationAPI(msgID : Int(intMsgID as! Int))
            }
            let CancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default) { (action:UIAlertAction!) in
                
            }
            alertController.addAction(OKAction)
            alertController.addAction(CancelAction)
            self.present(alertController, animated: true, completion:nil)
            
        }
        delete.backgroundColor = .red
        return [delete]
    }
    
    //MARK:- Button Actions
    
    @IBAction func btnBack(_ sender: Any){
        if isFrom == "HOME"{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnCross(_ sender: Any){
        
        
        let alertController = UIAlertController(title:"", message: NSLocalizedString("Would_you_like_to_delete_all_notification?", comment: ""), preferredStyle: .alert)
        let OKAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .default) { (action:UIAlertAction!) in
            
            self.ClearAllNotificationAPI()
        }
        let CancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default) { (action:UIAlertAction!) in
            
        }
        alertController.addAction(OKAction)
        alertController.addAction(CancelAction)
        self.present(alertController, animated: true, completion:nil)
        
    }
    
    @IBAction func btnSearch(_ sender: Any){
        self.displayAlertMessage(messageToDisplay: NSLocalizedString("Under_Development", comment: ""))
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
                
                NotificationListAPI(CurrentPage: NewPageNo)
            }
        }
    }
    
    //MARK:- API Calling
    func NotificationListAPI(CurrentPage: Int) {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)

            var parameters: Parameters = [:]
            
            if strUID == nil{
            
//                parameters = [
//
//                "user_id" : "\(strUID!)",
//                "page" : CurrentPage
//            ]
            }else{
                    parameters = [
                        
                        "user_id" : "\(strUID!)",
                    "page" : CurrentPage
                ]
            }
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.GET_NOTIFICATION_LIST_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                        if let arrSearchResponse =  data["list"]["data"].arrayObject{
                            
                            self.strCurrentPageIndex = data["list"]["current_page"].intValue
                            self.strLastPageIndex = data["list"]["total"].intValue
                            
                            if CurrentPage == 1{
                                self.arrData.removeAll()
                            }
                            
                            self.arrData += arrSearchResponse as! [[String:AnyObject]]
                            self.tblNotification.reloadData()
                            
                            if self.arrData.count == 0 {
                                self.lblNoDataFound.isHidden = false
                            }else{
                                self.lblNoDataFound.isHidden = true
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
    
    func DeleteSingleNotificationAPI(msgID : Int) {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            
            let parameters: Parameters = [
                
                "message_id" : msgID
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.DELETE_SINGLE_NOTIFICATION_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                        let strMsg = data["message"]
                        self.displayAlertMessage(messageToDisplay: strMsg.string!)
                        self.NotificationListAPI(CurrentPage: 1)
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

    func ClearAllNotificationAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let parameters: Parameters = [
                
                "user_id" : "\(strUID!)"
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.CLEAR_ALL_NOTIFICATION_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        self.arrData.removeAll()
                        self.tblNotification.reloadData()
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
}
