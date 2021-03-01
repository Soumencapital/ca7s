//
//  PendingRequestVC.swift
//  CA7S
//


import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD
import SDWebImage


class PendingRequestVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tblUserList: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblNoDataFound = UILabel()
    
    var ArrImgUser = NSMutableArray()
    var ArrUsername = NSMutableArray()
    
    var arrData = [[String:AnyObject]]()
    
    var strCurrentPageIndex = Int()
    var strLastPageIndex = Int()
    var Follow_id = Int()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SetUI()
        lblNoDataFound?.text = NSLocalizedString("No_Data_Found", comment: "")
        lblNoDataFound?.isHidden = true
        PendingRequestAPI(CurrentPage: 1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func SetUI() {
        lblTitle.text = NSLocalizedString("Pending_Request", comment: "")
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    //MARK:- Table Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:Pending_Request_TBLCell = tableView.dequeueReusableCell(withIdentifier: "Pending_Request_TBLCell") as! Pending_Request_TBLCell
        
        cell.btnAccept.layer.cornerRadius = cell.btnAccept.frame.size.height / 2
        cell.btnAccept.clipsToBounds = true
        cell.btnDecline.layer.cornerRadius = cell.btnDecline.frame.size.height / 2
        cell.btnDecline.clipsToBounds = true
        cell.selectionStyle = .none
        
        var dictData = arrData[indexPath.row]
        
        cell.lblUsername.text = dictData["full_name"]?.description
        
        Follow_id = dictData["follow_id"] as! Int
        
//        cell.btnAccept.tag = Follow_id
//        cell.btnDecline.tag = Follow_id

        cell.btnAccept.tag = indexPath.row
        cell.btnDecline.tag = indexPath.row
        
        cell.btnAccept.addTarget(self, action: #selector(btnAccept(_:)), for: .touchUpInside)
        cell.btnDecline.addTarget(self, action: #selector(btnDecline(_:)), for: .touchUpInside)
        
        let strImgeUrl = dictData["profile_picture"]?.description
        
        cell.imgUser.sd_setShowActivityIndicatorView(true)
        cell.imgUser.sd_setIndicatorStyle(.gray)
        
        cell.imgUser.sd_setImage(with: URL(string: strImgeUrl!), placeholderImage: UIImage(named: "placeholder.png"))
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    
    @objc func btnAccept(_ sender: UIButton) {
        var dictData = arrData[sender.tag]
        
         Follow_id = dictData["follow_id"] as! Int
        AcceptRequestAPI()
    }
    
    @objc func btnDecline(_ sender: UIButton) {
        var dictData = arrData[sender.tag]
        
        Follow_id = dictData["follow_id"] as! Int
        DeclineRequestAPI()
    }
    
    //MARK:- Button Actions
    
    @IBAction func btnBack(_ sender: Any){
        self.navigationController?.popViewController(animated: true)
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
                PendingRequestAPI(CurrentPage: NewPageNo)
            }
        }
    }
    
    //MARK:- API Calling
    
    func PendingRequestAPI(CurrentPage: Int) {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let parameters: Parameters = [
                
                "user_id" : "\(strUID!)",
                "page" : CurrentPage
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.PENDING_REQUEST_LIST_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                print("******\n \n  \n \n \n \(response) \n \n \n \n \n ********")
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                        if let arrSearchResponse =  data["list"]["data"].arrayObject{
                            
                            self.strCurrentPageIndex = data["data"]["current_page"].intValue
                            self.strLastPageIndex = data["data"]["total"].intValue
                            
                            if CurrentPage == 1{
                                self.arrData.removeAll()
                            }
                            
                            self.arrData = arrSearchResponse as! [[String:AnyObject]]
                            self.tblUserList.reloadData()
                            
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

    
    
    func AcceptRequestAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let parameters: Parameters = [
                
                "user_id" : "\(strUID!)",
                "follow_id" : Follow_id
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.ACCEPT_REQUEST_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                        self.PendingRequestAPI(CurrentPage: 1)
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

    func DeclineRequestAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let parameters: Parameters = [
                
                "user_id" : "\(strUID!)",
                "follow_id" : "\(Follow_id)"
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.REJECT_REQUEST_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        self.arrData.removeAll()
                        self.PendingRequestAPI(CurrentPage: 1)
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

