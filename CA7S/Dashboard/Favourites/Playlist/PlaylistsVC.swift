//
//  PlaylistsVC.swift
//  CA7S
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD
import SwiftyJSON
import ObjectMapper


class PlaylistsVC: UIViewController,UITableViewDelegate,UITableViewDataSource, MusicPlayerControllerDelegate {
    
    var Nav : UINavigationController!
    
    @IBOutlet var tblPlayList: UITableView!
    @IBOutlet weak var lblNoDataFound: UILabel?
    
    var ArrImgMusicAlbum = NSMutableArray()
    var ArrSongTitle = NSMutableArray()
    var ArrSongDescription = NSMutableArray()
    var arrData: [[String: AnyObject]]!
    var arrDataPlaylist = NSMutableArray()
    
    var strCurrentPageIndex = Int()
    var strLastPageIndex = Int()
    var repo = PlaylistRepositories()
    var localPlaylist: LocalPlayList!
    var isForDownlaod = false
    var tempImage = UIImage()
    var strUID = UserDefaults.standard.string(forKey: Constant.USERDEFAULTS.USER_ID) ?? "0"
    var playlistName = ""
    var paramForEditPlayList: Parameters!
    var forEdit = false
    var editOnLocation = 0
    
    private lazy var popUpVC: PopUpViewController =
    {
        let storyboard = UIStoryboard(name: "Profile", bundle: Bundle.main)
        var Controller = storyboard.instantiateViewController(withIdentifier: "PopUpViewController") as! PopUpViewController
        return Controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("reloadPlaylist"), object: nil)
        //self.GetPlaylistAPI(CurrentPage: 0)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.tblPlayList.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        self.setLocalizationString()
    }
    
    func setLocalizationString(){
        lblNoDataFound?.text = NSLocalizedString("No_Data_Found", comment: "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        self.strUID = UserDefaults.standard.string(forKey: Constant.USERDEFAULTS.USER_ID) ?? "0"
        self.fetchData()
    }
    
    
    func fetchData() {
        if isForDownlaod {
            if let item = UserDefaults.standard.string(forKey: Constant.USERDEFAULTS.LOCAL_PLAYLIST) {
                self.localPlaylist = Mapper<LocalPlayList>().map(JSONString: item) ?? LocalPlayList()
                self.lblNoDataFound?.isHidden = !self.localPlaylist.data.isEmpty
                self.tblPlayList.reloadData()
            }
        }else{
            let params = ["user_id": strUID]
            repo.playList(params: params, operation: .GET_USER_PLAYLIST) { (data) in
                if let items = data {
                    if let t = items["data"].dictionary {
                        if let _ = self.arrData {
                            self.arrData.removeAll()
                        }
                        
                        self.arrData = t["playlist"]?.arrayObject as! [[String : AnyObject]]
                        self.lblNoDataFound?.isHidden = !self.arrData.isEmpty
                        self.tblPlayList.reloadData()
                        
                    }else{
                        self.displayAlertMessage(messageToDisplay: NSLocalizedString("No Playlist were found", comment: ""))
                    }
                }else{
                    self.displayAlertMessage(messageToDisplay: NSLocalizedString("Something_went_wrong", comment: ""))
                }
            }
        }
    }
    
    
    //MARK:- Table Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isForDownlaod {
            if let _ = self.localPlaylist {
                return  self.localPlaylist.data.count
            }else{
                return 0
            }
        }else{
            if let _ = self.arrData {
                return self.arrData.count
            }else{
                return 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:Playlist_TBLCell = tableView.dequeueReusableCell(withIdentifier: "Playlist_TBLCell") as! Playlist_TBLCell
        
        cell.selectionStyle = .none
        
        
        if self.isForDownlaod {
            cell.lblSongTitle.text = self.localPlaylist.data[indexPath.row].playListName
            
            cell.imgAlbum.layer.cornerRadius = 15
            cell.imgAlbum.layer.masksToBounds = true
            cell.imgAlbum.image = UIImage(named: "app-logo")
            if let image = UIImage(data: Data(base64Encoded: self.localPlaylist.data[indexPath.row].images) ?? Data()) {
                cell.imgAlbum.image = image
                
            }
            
            
        }else{
            let dictData = arrData[indexPath.row]
            cell.lblSongTitle.text = dictData["name"]?.description
            let strImgeUrl = dictData["image"]?.description
            
            cell.imgAlbum.sd_setShowActivityIndicatorView(true)
            cell.imgAlbum.sd_setIndicatorStyle(.gray)
            
            
            
            cell.imgAlbum.sd_setImage(with: URL(string: strImgeUrl ?? ""), placeholderImage: UIImage(named: "app-logo"))
        }
        cell.btnMenu.tag = indexPath.row
        cell.btnMenu.addTarget(self, action: #selector(btnTableMenu(_:)), for: .touchUpInside)
        cell.imgAlbum.layer.cornerRadius = 15
        cell.imgAlbum.layer.masksToBounds = true
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GenreViewController") as! GenreViewController
        if isForDownlaod {
            let dicData = self.localPlaylist.data[indexPath.row]
            if dicData.songsInPlaylist == nil || dicData.songsInPlaylist.count == 0{
                let alert = UIAlertController(title: "Info", message: NSLocalizedString("List should not be empty", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                return}
            vc.strGenreIsFrom = "PlayList"
            vc.strIsFromTop = "NO"
            vc.strHeaderGenre = self.localPlaylist.data[indexPath.row].playListName
            vc.forLocalPlayList = true
            vc.strCurrentPageIndex = indexPath.row
            CAMusicViewController.sharedInstance()?.playerType = .local
            
        }else{
            let dictData = self.arrData[indexPath.row]
            vc.strGenreIsFrom = "PlayList"
            vc.strIsFromTop = "NO"
            vc.strHeaderGenre = (dictData["name"]?.description)!
            vc.playListData = dictData
        }
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.mainTabBarController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    
    //MARK:-
    //MARK:- Paggination Method
    
    
    @objc func btnTableMenu(_ sender: UIButton) {
        let actionsheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        actionsheet.addAction(UIAlertAction(title: NSLocalizedString("Edit", comment: ""), style: .default, handler: { (action) -> Void in
           
         
             self.onEditPlayList(sender.tag)
            //self.onEditPlayList("\(playList["id"] ?? 0 as AnyObject)")
            
        }))
        actionsheet.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { (action) -> Void in
            if self.isForDownlaod {
                
                if !self.localPlaylist.data.isEmpty {
                    self.localPlaylist.data.remove(at: sender.tag)
                }
                self.saveLocalPlayListData()
            }else{
                let playList = self.arrData[sender.tag]
                self.repo.playList(params: ["user_id": self.strUID, "id": "\(playList["id"] ?? 0 as AnyObject)"], operation: .REMOVE_PLAYLIST_API, onCompletion: { (item) in
                    self.arrData.removeAll()
                    self.tblPlayList.reloadData()
                    self.onGetResponse(item)
                })
            }
        }))
        actionsheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: nil))
        self.present(actionsheet, animated: true, completion: nil)
    }
    
    
    func onEditPlayList(_ id: Int) {
        self.forEdit = true
        self.editOnLocation = id
        
        let alert = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "PlaylistPopupViewController") as! PlaylistPopupViewController
        alert.modalPresentationStyle = .overCurrentContext
        alert.forEdit = self.forEdit
        if self.isForDownlaod {
            self.playlistName = self.localPlaylist.data[id].playListName
            
            if let image = UIImage(data: Data(base64Encoded: self.localPlaylist.data[id].images) ?? Data()) {
                alert.editPlayListImage = image
                
            }
            
        }else{
            self.playlistName = (self.arrData![id]["name"]?.description)!
            alert.playlistImageUrl = (self.arrData[id]["image"]?.description)!
        }
        alert.previousPlayList = self.playlistName
        alert.createPlayList = { name, image in
            self.playlistName = name
            if self.isForDownlaod {
                self.localPlaylist.data[id].playListName = name
            }else{
                let playList = self.arrData[id]
                self.paramForEditPlayList = ["user_id":self.strUID, "name": name, "playlist_id": "\(playList["id"] ?? 0 as AnyObject)"]
            }
            self.editPlayList(image: image)
        }
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.mainTabBarController?.present(alert, animated: true, completion: nil)
        }
    }
    
   
    
    
    
    func saveLocalPlayListData() {
        UserDefaults.standard.set(self.localPlaylist.toJSONString(), forKey: Constant.USERDEFAULTS.LOCAL_PLAYLIST)
        fetchData()
    }
    
    func onGetResponse(_ item: JSON?) {
        guard let data = item else {return}
        self.displayAlertMessage(messageToDisplay: data["message"].string ?? "Something Went wrong")
        self.fetchData()
    }
    
    //MARK:- Button Actions
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addPlayList(_ sender: UIButton) {
        self.forEdit = false
        
        let alert = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "PlaylistPopupViewController") as! PlaylistPopupViewController
        alert.modalPresentationStyle = .overCurrentContext
        alert.forEdit = self.forEdit
        alert.createPlayList = { name, image in
            self.playlistName = name
            if self.isForDownlaod {
                let playList = LocalPlayListItem()
                playList.playListName = name
                if self.localPlaylist == nil {
                    self.localPlaylist = LocalPlayList()
                }
                self.localPlaylist.data.append(playList)
                
                
            }
            self.createPlayList(image: image)
        }
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.mainTabBarController?.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
   
    func createPlayList(image: UIImage?) {
        if isForDownlaod {
            if let i = image {
                self.localPlaylist.data.last!.images = UIImageJPEGRepresentation(i, 0.5)!.base64EncodedString()
            }
            self.saveLocalPlayListData()
        }else{
            var params: Parameters =  ["user_id": self.strUID, "name": self.playlistName]
            if let i = image {
                params["image"] = UIImageJPEGRepresentation(i, 0.5)
            }
            self.repo.playList(params: params, operation: .CREATE_PLAYLIST_API, onCompletion: { (item) in
                guard let data = item else {return}
                if data["status"].string == "success" {
                    self.displayAlertMessage(messageToDisplay: NSLocalizedString((data["message"].string ?? ""), comment: ""))
                    self.fetchData()
                }else{
                    self.displayAlertMessage(messageToDisplay: NSLocalizedString("Something_went_wrong", comment: ""))
                }
            })
            
        }
    }
    
    func editPlayList(image: UIImage?){
        if isForDownlaod {
            if let i = image {
                self.localPlaylist.data[editOnLocation].images = UIImageJPEGRepresentation(i, 0.5)!.base64EncodedString()
            }
            self.saveLocalPlayListData()
        }else{
            if let i = image {
                self.paramForEditPlayList["image"] = UIImageJPEGRepresentation(i, 0.5)
            }
            self.repo.playList(params: self.paramForEditPlayList, operation: .UPDATE_PLAYLIST_API, onCompletion: { (item) in
                 guard let data = item else {return}
                if data["status"].string == "success" {
                    self.displayAlertMessage(messageToDisplay: NSLocalizedString((data["message"].string ?? ""), comment: ""))
                    self.fetchData()
                }else{
                    self.displayAlertMessage(messageToDisplay: NSLocalizedString("Something_went_wrong", comment: ""))
                }
            })
            
        }
        
    }
    
    
}

class LocalPlayList: Mappable {
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        data <- map["data"]
        
    }
    
    init() {
        
    }
    
    var data : [LocalPlayListItem] = []
    
    
    
}

class LocalPlayListItem: Mappable {
    required init?(map: Map) {
        
    }
    
    
    
    init() {
        
    }
    
    var playListName: String = ""
    var images = ""
    var songsInPlaylist: [[String: Any]]!
    
    
    
    func mapping(map: Map) {
        playListName <- map["playListName"]
        songsInPlaylist <- map["songsInPlaylist"]
        images <- map["images"]
    }
    
    
}


extension UILabel {
    
    
    open override func awakeFromNib() {
        self.text = NSLocalizedString(self.text ?? "", comment: "")
    }
}

extension UIButton {
    
    open override func awakeFromNib() {
        self.setTitle(NSLocalizedString(self.titleLabel?.text ?? "", comment: ""), for: .normal)
    }
}
