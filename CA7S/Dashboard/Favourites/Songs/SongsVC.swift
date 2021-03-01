//
//  SongsVC.swift
//  CA7S
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD
import SwiftyJSON


protocol selectSongDelegate: class {
    
    func selectSongMusicPlayerDelegate(int: Int)
    
}

class SongsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MusicPlayerControllerDelegate {
    
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tblMusicList: UITableView!
    @IBOutlet weak var lblNoDataFound: UILabel!
    
    var ArrImgMusicAlbum = NSMutableArray()
    var ArrSongTitle = NSMutableArray()
    var ArrSongDescription = NSMutableArray()
    
    var arrData = NSMutableArray()
    var strCurrentPageIndex = Int()
    var strLastPageIndex = Int()
    var Nav : UINavigationController!
    var currentItem = 0
    var isComingFrom = String()
    var keyWord = ""
    var onMovePlayList: ((_ songs: NSMutableArray)->Void)!
    var fromFavroite = false
   
    
    
    weak var delegate: selectSongDelegate?
    
    private lazy var popUpVC: PopUpViewController =
    {
        let storyboard = UIStoryboard(name: "Profile", bundle: Bundle.main)
        var Controller = storyboard.instantiateViewController(withIdentifier: "PopUpViewController") as! PopUpViewController
        Controller.fromFav = self.fromFavroite
        return Controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTable(notification:)), name: Notification.Name("reloadFavList"), object: nil)
        
        if isComingFrom == "musicPlayer" {
            self.tblMusicList.reloadData()
            tblMusicList.isEditing = true
            tblMusicList.allowsSelectionDuringEditing = true
        }else if isComingFrom == "Search" {
            self.headerHeightConstraint.constant = 60
            self.SearchByKeyword(keyWord: self.keyWord)
        }else{
            GetFavouriteAPI(CurrentPage: 1)
        }
     

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isComingFrom != "musicPlayer" {
        
           
        
//            lblNoDataFound.text = NSLocalizedString("No_Data_Found", comment: "")
//            self.tblMusicList.scrollToRow(at: IndexPath(row: currentItem, section: 0), at: .top, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func reloadTable(notification: NSNotification) {
        GetFavouriteAPI(CurrentPage: 1)
    }
    
    
    func SearchByKeyword(keyWord: String) {
        
        if Connectivity.isConnectedToInternet() {
            //SVProgressHUD.show()
            let parameters: Parameters = [
                "keyword" : keyWord,
                ]
            Alamofire.request(Constant.APIs.SEARCH_MANUALLY_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                self.onGetResponse(response.result.value)
            })
        }else{
            self.displayAlertMessageWithTitle(title: Constant.APIs.InternetConnectionTitle, alertMessage: Constant.APIs.InternetConnectionMessage)
        }
    }
    

    func onGetResponse(_ item: JSON?) {
        if let data = item {
            if data["status"] == "success" {
                if let arrSearchResponse =  data["data"].arrayObject{
                    if self.strCurrentPageIndex == 1{
                        self.arrData.removeAllObjects()
                    }
                    if arrSearchResponse.count > 0 {
                        self.arrData.addObjects(from: arrSearchResponse)
                        self.tblMusicList.reloadData()
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
    }
    //MARK:- Table Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:Song_TBLCell = tableView.dequeueReusableCell(withIdentifier: "Song_TBLCell") as! Song_TBLCell
        
        cell.selectionStyle = .none
        
        if isComingFrom == "musicPlayer" {
            
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            cell.lblSongTitle.textColor = UIColor.white
        }
        
        let dictData = arrData[indexPath.row] as! [String:Any]
        
        cell.lblSongTitle.text =  dictData["title"] as? String
        cell.lblSongDescription.text = ""//(dictData as! [String:Any])["title"] as? String
        
        cell.btnMenu.tag = indexPath.row
        
        cell.btnMenu.addTarget(self, action: #selector(btnTableMenu(_:)), for: .touchUpInside)
        
        var strImgeUrl = ""
        
        if let image = dictData["image_url"] as? String {
            strImgeUrl = image
        }
        if strImgeUrl == "", let image = dictData["artwork_url"] as? String {
            strImgeUrl = image
        }
        
        
        cell.imgAlbum.sd_setShowActivityIndicatorView(true)
        cell.imgAlbum.sd_setIndicatorStyle(.gray)
        
        cell.imgAlbum.layer.cornerRadius = 15
        cell.imgAlbum.layer.masksToBounds = true
        
        cell.imgAlbum.sd_setImage(with: URL(string: strImgeUrl), placeholderImage: UIImage(named: "default song"))
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        
        let item = arrData[sourceIndexPath.row]
        
        arrData.removeObject(at: sourceIndexPath.row)
        arrData.insert(item, at: destinationIndexPath.row)
        self.onMovePlayList(arrData)
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
      return  UITableViewCellEditingStyle.none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isComingFrom == "musicPlayer" {
            
            delegate?.selectSongMusicPlayerDelegate(int: indexPath.row)
            
            return
        }
        
        if CAMusicViewController.sharedInstance().playbackState == .playing{
            CAMusicViewController.sharedInstance().pause()
        }
        CAMusicViewController.sharedInstance().add(self)
        CAMusicViewController.sharedInstance().playerType = .remote
        CAMusicViewController.sharedInstance().setQueueWithItemCollection(arrData)
//        CAMusicViewController.sharedInstance().strAlbumName = strGenreID
        if CAMusicViewController.sharedInstance().shuffleMode {
            let item = self.arrData[indexPath.row]
            let index = (CAMusicViewController.sharedInstance().queue! as NSArray).index(of: item)
            CAMusicViewController.sharedInstance().playItem(at: UInt(index))
        } else {
            CAMusicViewController.sharedInstance().playItem(at: UInt(indexPath.row))
        }
        
        let dictData = arrData[indexPath.row]
        let strSongID = (dictData as! [String:Any])["id"]!
            
        let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MusicPlayerVC") as! MusicPlayerVC
        controller.strSongID = "\(strSongID)"
        controller.strFROMTOP = "NO"
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        
        controller.genreData = arrData[indexPath.row] as! [String : Any]
        controller.arrAlbumData = arrData as! [[String : AnyObject]]
        controller.intValue = indexPath.row
        controller.mode = "favourite"
        self.present(controller, animated: true, completion: nil)
//        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
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
                GetFavouriteAPI(CurrentPage: NewPageNo)
            }
        }
    }
    
    //MARK:- Button Actions
    
    @objc func btnTableMenu(_ sender: UIButton) {
        self.addChildViewController(popUpVC)
        popUpVC.view.frame = CGRect(x: 0, y: 80, width: self.view.frame.width, height: self.view.frame.height)
        popUpVC.trackData = arrData[sender.tag] as! [String : Any]
        self.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParentViewController: self)
    }
    
    
    
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- API Calling
    
    func GetFavouriteAPI(CurrentPage: Int) {
        
        if Connectivity.isConnectedToInternet() {
                       
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            if strUID == nil {
                
                self.lblNoDataFound.isHidden = false
                
                return
            }
            
            //SVProgressHUD.show()
            
            let parameters: Parameters = [
                
                "user_id" : "\(strUID!)",
                "page" : CurrentPage
            ]
     
            Alamofire.request(Constant.APIs.GET_FAVOURITE_LIST_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                        if let arrSearchResponse =  data["list"]["favorite_list"].arrayObject{
                            
                            self.strCurrentPageIndex = data["list"]["current_page"].intValue
                            self.strLastPageIndex = data["list"]["total"].intValue
                            
                            
                            
                            
                            if CurrentPage == 1{
                                self.arrData.removeAllObjects()
                            }
                            
                            self.arrData.addObjects(from: arrSearchResponse)
                            
                            if self.arrData.count == 0 {
                                self.lblNoDataFound.isHidden = false
                                self.lblNoDataFound.text = NSLocalizedString("No_Data_Found", comment: "")
                            }else{
                                self.lblNoDataFound.isHidden = true
                            }
                            
                            DispatchQueue.main.async {
                                self.tblMusicList.reloadData()
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
