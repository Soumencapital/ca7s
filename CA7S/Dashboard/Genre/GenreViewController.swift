//
//  GenreViewController.swift
//  CA7S
//
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD
import SDWebImage
import SwiftyJSON
import IQKeyboardManagerSwift
import ObjectMapper

enum genereType {
    case top, new, risingStar
}


class GenreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MusicPlayerControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet var tblGenre:UITableView!
    @IBOutlet var lblGenreTitle:UILabel!
    @IBOutlet var lblGenreHeader:UILabel!
    
    @IBOutlet weak var imgAlbum: UIImageView!
    @IBOutlet var viewPlayer:UIView!
    @IBOutlet var playerSlider:UISlider!
    @IBOutlet var lblSongTitle: UILabel!
    @IBOutlet var lblAlbumName: UILabel!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var btnPrevious: UIButton!
    @IBOutlet var btnNext: UIButton!
    @IBOutlet weak var tableTopConstriant: NSLayoutConstraint!
    
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var musicPlayerHeight: NSLayoutConstraint!
    var strCurrentPageIndex : Int = 1
    var strLastPageIndex = Int()
    
    /////////// New Params to works on
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet var typeName: [UILabel]!
    @IBOutlet weak var typeInfo: UILabel!
    var gereInfoData: [String: Any] = [:]
    var isFromZeroIndex = false
    var playListData: [String: AnyObject] = [:]
    var selectionType: Constant.APIs.DiscoverDeatilUrl = .none
    var repo = DiscoverRepositories()
    var searchKeyWord = ""
    var isFilteering = false
    var forLocalPlayList = false
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var tableHeaderView: UIView!
    var localPlaylist = LocalPlayList()
    @IBOutlet weak var headerImageTopConstarint: NSLayoutConstraint!
    
    
    //////////?End of new params////////////
    var strHeaderGenre = String()
    var strLikeCount = String()
    var strGenreID = String()
    var strGenreName = String()
    var strGenreIsFrom = String()
    var strAlbumName = String()
    var strArtistName = String()
    var strMBID = String()
    var strIsFromTop = String()
    var strIsFromPlayer = String()
    
    var arrDataGenre = NSMutableArray()
    // for implementation of the filter task
    var allDataOfGenre = NSMutableArray()
    
    
    var arrGenre = Array<Any>()
    
    var timer : Timer?
    var isPanning:Bool = false
    var trackData:[String:Any]?
    
    private let refreshControl = UIRefreshControl()
    
    private lazy var popUpVC: PopUpViewController =
    {
        let storyboard = UIStoryboard(name: "Profile", bundle: Bundle.main)
        var Controller = storyboard.instantiateViewController(withIdentifier: "PopUpViewController") as! PopUpViewController
        return Controller
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblGenreTitle.text = strGenreName
        
        imgAlbum.layer.cornerRadius = 10
        imgAlbum.layer.masksToBounds = true
        IQKeyboardManager.sharedManager().enable = false
        
        playerSlider.setMaximumTrackImage(#imageLiteral(resourceName: "max_track"), for: .normal)
        playerSlider.setMinimumTrackImage(#imageLiteral(resourceName: "min_track").stretchableImage(withLeftCapWidth: 5, topCapHeight: 5), for: .normal)
        playerSlider.setThumbImage(#imageLiteral(resourceName: "slider_thumb"), for: .normal)
        playerSlider.setThumbImage(#imageLiteral(resourceName: "slider_thumb"), for: .highlighted)
        playerSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Data ...", attributes: [:])
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            self.tblGenre.refreshControl = refreshControl
        } else {
            self.tblGenre.addSubview(refreshControl)
        }
        searchBar.delegate = self
        initViewWithData()
        
    }
    
    
    func setLocalPlayList() {
        if let item = UserDefaults.standard.string(forKey: Constant.USERDEFAULTS.LOCAL_PLAYLIST) {
            self.localPlaylist = Mapper<LocalPlayList>().map(JSONString: item)!
            
            
        }
    }
    
    
    func initViewWithData() {
        
        albumImage.layer.cornerRadius = 15
        albumImage.layer.masksToBounds = true
        typeInfo.text = strGenreIsFrom
        setLocalizationString()
        if self.selectionType != .none{
            setItemOnBaseOf(selectionType)
        }else {
            if isFromZeroIndex {
                albumImage.image = UIImage(named: "bannerTop")
            }else if strGenreIsFrom == "PlayList" {
                typeInfo.text = "\(self.playListData["name"] ?? "" as AnyObject)"
                let strImgeUrl = (self.playListData["image"] as AnyObject).description
                albumImage.sd_setShowActivityIndicatorView(true)
                albumImage.sd_setIndicatorStyle(.gray)
                albumImage.sd_setImage(with: URL(string: strImgeUrl!), placeholderImage: UIImage(named: "default album-1"))
                setLocalizationString()
                
            }else {
                
                let strImgeUrl = (gereInfoData["image_icon"] as AnyObject).description
                albumImage.sd_setShowActivityIndicatorView(true)
                albumImage.sd_setIndicatorStyle(.gray)
                albumImage.sd_setImage(with: URL(string: strImgeUrl!), placeholderImage: UIImage(named: "default album-1"))
            }
            
        }
    }
    
    func setItemOnBaseOf(_ type: Constant.APIs.DiscoverDeatilUrl) {
        switch type {
        case .topGenereAtZero:
            strHeaderGenre = "Top Ca7s"
            albumImage.image = UIImage(named: "bannerTop")
        case .topAfterZero, .newReleaseAfterZero, .risingStarAfterZero:
            strHeaderGenre = (gereInfoData["type"] as AnyObject).description
            let strImgeUrl = (gereInfoData["image_icon"] as AnyObject).description
            albumImage.sd_setShowActivityIndicatorView(true)
            albumImage.sd_setIndicatorStyle(.gray)
            albumImage.sd_setImage(with: URL(string: strImgeUrl!), placeholderImage: UIImage(named: "default album-1"))
        case .newReleaseAtZero:
            strHeaderGenre = "New Releases"
            albumImage.image = UIImage(named: "bannerNew")
        case .risingStarAtZero:
            strHeaderGenre = "Rising Star"
            albumImage.image = UIImage(named: "bannerRising")
            
        case .none:
            break
        }
        self.setLocalizationString()
    }
    
    
    
    func fetchData() {
        //self.arrDataGenre.removeAllObjects()
        
        //            if strGenreIsFrom == "Top"{
        //                self.GetTOPLISTAPI(CurrentPage: strCurrentPageIndex, album_name: strAlbumName, artist_name: strArtistName, mbid: strMBID)
        //            }else
        if strGenreIsFrom == "Fav"{
            self.GetFavListAPI(CurrentPage: strCurrentPageIndex)
        }
            //        else if strGenreIsFrom == "MostLikely"{
            //                self.GetTopCA7SListAPI(CurrentPage: strCurrentPageIndex)
            //            }
        else if strGenreIsFrom == "PlayList" {
            self.setLocalPlayList()
            self.getPlayListSongs(CurrentPage: strCurrentPageIndex)
        }else if strGenreIsFrom == "Search" {
            self.SearchByKeyword(keyWord: self.searchKeyWord)
        }else{
            self.GetGenreAPI(CurrentPage: strCurrentPageIndex)
        }
        
        
        
        
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        print("refreshWeatherData refreshWeatherData refreshWeatherData refreshWeatherData")
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
        
        if (CAMusicViewController.sharedInstance().playbackState == MPMusicPlaybackState.playing || CAMusicViewController.sharedInstance().playbackState == MPMusicPlaybackState.paused) {
          
            CAMusicViewController.sharedInstance().add(self)
            musicPlayerHeight.constant = 80
            tableHeightConstraint.constant = 320
            viewPlayer.isHidden = false
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timedJob), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: .commonModes)
            playerSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
            
            let musicPlayer = CAMusicViewController.sharedInstance()
            
            if let mediaitem = musicPlayer?.nowPlayingItem {
                
                //   var img:UIImage?
                
                SDImageCache.shared().clearMemory()
                SDImageCache.shared().clearDisk()
                var imageUrl = ""
                if  let image = mediaitem["image_url"] as? String {
                    imageUrl = image
                }else if let image = mediaitem["artwork_url"] as? String {
                    imageUrl = image
                }
                self.imgAlbum.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "default song"))
                self.lblSongTitle.text = mediaitem["title"] as? String
                if (mediaitem["album_name"] as? String) != nil{
                    self.lblAlbumName.text = mediaitem["album_name"] as? String
                }else{
                    self.lblAlbumName.text = musicPlayer?.strAlbumName
                }
                
                //                self.lblAlbumName.text = musicPlayer?.strAlbumName
                playerSlider.minimumValue = 0
                if Float((musicPlayer?.getTrackDuration())!) > 0 {
                    playerSlider.maximumValue = Float(musicPlayer!.getTrackDuration())
                } else {
                    playerSlider.maximumValue = 1
                }
                playerSlider.value = Float(musicPlayer!.currentPlaybackTime)
                
                btnPlay.isSelected = musicPlayer?.playbackState == MPMusicPlaybackState.playing
            }
        } else {
            musicPlayerHeight.constant = 0
            tableHeightConstraint.constant = 400
            viewPlayer.isHidden = true
        }
    }
    
    func setLocalizationString(){
        self.typeName.forEach { (item) in
            item.text = NSLocalizedString(strHeaderGenre, comment: "")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        CAMusicViewController.sharedInstance().remove(self)
    }
    
    func timedJob() {
        if CAMusicViewController.sharedInstance().currentPlaybackTime > 0 {
            SVProgressHUD.dismiss()
        }
        if !isPanning {
            playerSlider.value = Float(CAMusicViewController.sharedInstance().currentPlaybackTime)
        }
    }
    
    @IBAction func btnDownArrowPressed(_ sender:Any) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                isPanning = true
                break
            case .moved:
                break
            case .ended:
                isPanning = false
                CAMusicViewController.sharedInstance().currentPlaybackTime = TimeInterval(slider.value)
                break
            default:
                break
            }
        }
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.strCurrentPageIndex = 1
        self.fetchData()
        refreshControl.endRefreshing()
    }
    
    //MARK:- Button Actions
    
    @IBAction func btnPlay(_ sender: Any) {
        if CAMusicViewController.sharedInstance().playbackState == MPMusicPlaybackState.playing {
            CAMusicViewController.sharedInstance().pause()
            btnPlay.isSelected = false
        } else {
            CAMusicViewController.sharedInstance().play()
            btnPlay.isSelected = true
        }
    }
    
    @IBAction func btnOpenPlayer(_ sender: UIButton){
        
        let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MusicPlayerVC") as! MusicPlayerVC
        controller.isFrom = GenreViewController()
        let trackData2  = UserDefaults.standard.object(forKey: "trackData")
        if trackData2 != nil{
            let trackData3 = NSKeyedUnarchiver.unarchiveObject(with: trackData2 as! Data) as? [String: Any]
            controller.genreData = trackData3!
            //controller.arrAlbumData = arrDataGenre as! [[String : AnyObject]]
            controller.intValue = 0
        }
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    @IBAction func btnPrevious(_ sender: Any) {
        CAMusicViewController.sharedInstance().skipToPreviousItem()
    }
    
    @IBAction func btnNext(_ sender: Any) {
        CAMusicViewController.sharedInstance().skipToNextItem()
    }
    
    //MARK:- UITableView Methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDataGenre.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:GenreListCell = tableView.dequeueReusableCell(withIdentifier: "GenreListCell") as! GenreListCell
        cell.selectionStyle = .none
        cell.lblCount.text = "\(indexPath.row + 1)"
        cell.btnOptions.tag = indexPath.row
        
        let dictData = arrDataGenre[indexPath.row]
        
        print("@@@@@@ \(dictData)******")
        
        cell.imgAlbum.sd_setShowActivityIndicatorView(true)
        cell.imgAlbum.sd_setIndicatorStyle(.gray)
        
        cell.imgAlbum.layer.cornerRadius = 15
        cell.imgAlbum.layer.masksToBounds = true
        
        
        if let _ = dictData as? [String:Any] {
            if strGenreIsFrom == "Top"{
                cell.lblSongTitle.text = (dictData as! [String:Any])["title"] as? String
                cell.lblGenreTitle.text = strArtistName
                let strImgeUrl = (dictData as! [String:Any])["image_url"] as! String
                cell.imgAlbum.sd_setImage(with: URL(string: strImgeUrl), placeholderImage: UIImage(named: "default song"))
                
            }else {
                cell.lblSongTitle.text = (dictData as! [String:Any])["title"] as? String
                cell.lblGenreTitle.text = (dictData as! [String:Any])["artist_name"] as? String
                
                if let imageUrl = (dictData as! [String:Any])["image_url"] as? String {
                    if !UserDefaults.standard.bool(forKey: Constant.USERDEFAULTS.economicMode) {
                         cell.imgAlbum.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "default song"))
                    }
                  
                }
                
                
            }
            cell.btnOptions.isHidden = false
            cell.btnOptions.addTarget(self, action: #selector(btnOptionsPressed(_:)), for: UIControlEvents.touchUpInside)
            cell.btnLike.tag = indexPath.row
            cell.btnLike.isSelected = (dictData as! [String:Any])["is_like"] as? Bool ?? false
            cell.btnLike.addTarget(self, action: #selector(btnLikePressed(_:)), for: UIControlEvents.touchUpInside)
        }
        
        if indexPath.row == arrDataGenre.count - 1 && strCurrentPageIndex != strLastPageIndex && !self.isFilteering && !self.forLocalPlayList{
            strCurrentPageIndex = strCurrentPageIndex + 1
            fetchData()
        }
        
        return cell
    }
    
    
    
    
    @IBAction func playBtton(_ sender: UIButton) {
        onPlayat(0)
        
    }
    
    func onPlayat(_ index: Int) {
        if CAMusicViewController.sharedInstance().playbackState == .playing{
            CAMusicViewController.sharedInstance().pause()
        }
        CAMusicViewController.sharedInstance().add(self)
        CAMusicViewController.sharedInstance().playerType = .remote
        if self.forLocalPlayList {
            CAMusicViewController.sharedInstance().playerType = .local
        }
        
        CAMusicViewController.sharedInstance().setQueueWithItemCollection(arrDataGenre)
        CAMusicViewController.sharedInstance().strAlbumName = strGenreName
        if CAMusicViewController.sharedInstance().shuffleMode {
            let item = self.arrDataGenre[index]
            let index = (CAMusicViewController.sharedInstance().queue! as NSArray).index(of: item)
            CAMusicViewController.sharedInstance().playItem(at: UInt(index))
        } else {
            CAMusicViewController.sharedInstance().playItem(at: UInt(index))
        }
        let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MusicPlayerVC") as! MusicPlayerVC
        controller.isFrom = self
        controller.strHeaderGenre = strHeaderGenre
        controller.strFROMTOP = strIsFromTop
        CAMusicViewController.sharedInstance().strAlbumID = strGenreID
        controller.strGenreID = strGenreID
        controller.strGenreName = strGenreName
        controller.strAlbumName = strAlbumName
        controller.genreData = arrDataGenre[index] as! [String : Any]
        controller.isForLocalPlayList = self.forLocalPlayList
        
        if strIsFromTop == "YES"{
            var dictData1 = arrDataGenre[index] as? [String:Any]
            controller.trackFavouriteStatus = { isFavourite in
                dictData1!["is_like"] = NSNumber.init(booleanLiteral: isFavourite)
                dictData1!["is_favorite"] = NSNumber.init(booleanLiteral: isFavourite)
                
            }
        }else{
            
            let dictData = arrDataGenre[index]
            let strSongID = (dictData as! [String:Any])["id"]!
            controller.strSongID = "\(strSongID)"
            controller.intValue = index
            if let dictData = arrDataGenre as? [[String : AnyObject]] {
                controller.arrAlbumData = dictData
            }
            
            if "\((dictData as! [String:Any])["like_count"] ?? 0)" == "0"{
                controller.strLikeCount = ""
            }else{
                controller.strLikeCount = "\((dictData as! [String:Any])["like_count"]!)"
            }
            
            
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onPlayat(indexPath.row)
    }
    
    
    
    
    //MARK: Button Actions
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        
        
    }
    
    func btnLikePressed(_ sender: UIButton) {
        let data = arrDataGenre[sender.tag] as! [String: Any]
        let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
        
        if strUID == nil{
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            
            vc.mode = "musicPlayer"
            //            sideMenuViewController?.contentViewController = UINavigationController(rootViewController: vc)
            //            sideMenuViewController?.hideMenuViewController()
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            if Connectivity.isConnectedToInternet() {
                
                //            //SVProgressHUD.show()
                let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
                
                var strURL:URLConvertible?
                if sender.isSelected == true {
                    strURL = Constant.APIs.UNLIKE_TRACK
                } else {
                    strURL = Constant.APIs.LIKE_TRACK
                }
                var parameters = Parameters()
                parameters = [
                    "user_id" : "\(strUID!)",
                    "track_id" : "\(data["id"]!)",
                    "track_type" : "1",
                ]
                
                print("Para",parameters)
                
                Alamofire.request(strURL!, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                    
                    //                SVProgressHUD.dismiss()
                    
                    if let data = response.result.value {
                        
                        if data["status"] == "success" {
                            sender.isSelected = !sender.isSelected
                            
                            
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
    
    
    
    
    
    
    func btnOptionsPressed(_ sender: Any) {
        
        self.addChildViewController(popUpVC)
        popUpVC.view.frame = self.view.frame
        let index = (sender as! UIButton).tag
        popUpVC.trackData = arrDataGenre[index] as? [String : Any]
        
        if strGenreName == NSLocalizedString("Brand_New", comment: "") || strGenreName == NSLocalizedString("Top_Ca7s", comment: ""){
            let track = arrDataGenre[index] as? [String : Any]
            popUpVC.strAlbumName = track?["album_name"] as? String ?? ""
        }else{
            popUpVC.strAlbumName = strGenreName
        }
        
        if strIsFromTop == "YES"{
            popUpVC.strFROMTOP = "YES"
        }else{
            popUpVC.strFROMTOP = "NO"
        }
        popUpVC.isForLocalPlayList = forLocalPlayList
        popUpVC.strGenreID = strGenreID
        popUpVC.strHeaderGenre = self.strHeaderGenre
        self.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParentViewController: self)
    }
    
    
    // MARK:- CAMusicPlayerDelegate Methods
    
    func musicPlayer(_ musicPlayer: CAMusicViewController!, playbackStateChanged playbackState: MPMusicPlaybackState, previousPlaybackState: MPMusicPlaybackState) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PlayBackStateChanged"), object: nil)
        btnPlay.isSelected = (playbackState == .playing)
        SVProgressHUD.dismiss()
    }
    
    func musicPlayer(_ musicPlayer: CAMusicViewController!, trackDidChange nowPlayingItem: [AnyHashable : Any]!, previousTrack: [AnyHashable : Any]!) {
        if nowPlayingItem != nil {
            DispatchQueue.main.async {
                let mediaitem = nowPlayingItem as! [String:Any]
                
                var img:UIImage?
                
                if let imageURL = mediaitem["image_url"] as? String{
                    self.imgAlbum.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "default album"))
                    //                    let imgData = try? Data.init(contentsOf: URL.init(string: imageURL as! String)!)
                    //                    if let data = imgData {
                    //                        img = UIImage.init(data: data)
                    //                        self.imgAlbum.image = img;
                    //                    }
                }
                
                self.lblSongTitle.text = mediaitem["title"] as? String
            }
        }
    }
    
    func musicPlayerDuration(_ musicPlayer: CAMusicViewController!, setduration item: AVPlayerItem!) {
        if item != nil {
            playerSlider.minimumValue = 0.0
            playerSlider.maximumValue = Float(CMTimeGetSeconds(item.duration))
        }
    }
    
    
    //MARK:- API Calling
    
    func GetGenreAPI(CurrentPage: Int) {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            var parameters: Parameters = [
                "genre_id" : strGenreID,
                "page" : CurrentPage,
                
                ]
            
            if strUID != nil{
                parameters["user_id"] = "\(strUID!)"
            }
            
            if self.selectionType == .topGenereAtZero {
                parameters["type"] = "top"
            }
            
            print("Para",parameters)
            
            repo.playList(params: parameters, operation: self.selectionType) { (item) in
                self.onGetResponse(item)
            }
        }else{
            self.displayAlertMessageWithTitle(title: Constant.APIs.InternetConnectionTitle, alertMessage: Constant.APIs.InternetConnectionMessage)
        }
    }
    
    func getPlayListSongs(CurrentPage: Int) {
        
        if forLocalPlayList {
            
            self.arrDataGenre = NSMutableArray(array: self.localPlaylist.data[CurrentPage].songsInPlaylist)
            self.allDataOfGenre = NSMutableArray(array: self.localPlaylist.data[CurrentPage].songsInPlaylist)
            self.tblGenre.reloadData()
        }else{
            if Connectivity.isConnectedToInternet() {
                
                //SVProgressHUD.show()
                let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
                let playListId = self.playListData["id"]!
                let parameters: Parameters = [
                    "playlist_id" : "\(playListId)",
                    "user_id" : "\(strUID!)",
                    "page" : CurrentPage
                ]
                
                
                print("Para",parameters)
                PlaylistRepositories().playList(params: parameters, operation: .GET_SONG_FROM_PLAYLIST) { (item) in
                    self.onGetResponse(item)
                }
            }else{
                self.displayAlertMessageWithTitle(title: Constant.APIs.InternetConnectionTitle, alertMessage: Constant.APIs.InternetConnectionMessage)
            }
        }
    }
    
    func onGetResponse(_ item: JSON?) {
        if let data = item {
            if data["status"] == "success" {
                if let arrSearchResponse =  data["list"]["data"].arrayObject{
                    self.strCurrentPageIndex = data["list"]["current_page"].intValue
                    self.strLastPageIndex = data["list"]["total"].intValue
                    if self.strCurrentPageIndex == 1{
                        allDataOfGenre.removeAllObjects()
                        self.arrDataGenre.removeAllObjects()
                    }
                    if arrSearchResponse.count > 0 {
                        //self.arrDataGenre.addObjects(from: arrSearchResponse)
                        self.allDataOfGenre.addObjects(from: arrSearchResponse)
                      
                    }
                }
                
                if let arrSearchResponse =  data["data"].arrayObject{
                    if self.strCurrentPageIndex == 1{
                        self.arrDataGenre.removeAllObjects()
                        self.allDataOfGenre.removeAllObjects()
                    }
                    if arrSearchResponse.count > 0 {
                        self.arrDataGenre.addObjects(from: arrSearchResponse)
                        self.allDataOfGenre.addObjects(from: arrSearchResponse)
                       
                    } else {
                        
                    }
                }
                
            self.arrDataGenre = self.allDataOfGenre
                 self.tblGenre.reloadData()
                
            }else{
                
                let strMsg = data["message"]
                self.displayAlertMessage(messageToDisplay: strMsg.string!)
            }
        }else{
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Something_went_wrong", comment: ""))
        }
    }
    
    
    func GetTOPLISTAPI(CurrentPage: Int, album_name: String, artist_name: String, mbid: String) {
        if Connectivity.isConnectedToInternet() {
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            var parameters: Parameters = [
                "page" : CurrentPage,
                "playlist_id" : mbid
            ]
            if strUID != nil{
                parameters ["user_id"] = "\(strUID!)"
            }
            
            Alamofire.request(Constant.APIs.TOP_LIST_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                self.onGetResponse(response.result.value)
            })
        }else{
            self.displayAlertMessageWithTitle(title: Constant.APIs.InternetConnectionTitle, alertMessage: Constant.APIs.InternetConnectionMessage)
        }
    }
    
    func GetFavListAPI(CurrentPage: Int) {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let parameters: Parameters = [
                
                "user_id" : "\(strUID!)",
                "genre_id" : strGenreID,
                "page" : CurrentPage
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.GET_FAVOURITE_BY_ALBUM_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                        if let arrSearchResponse =  data["list"].arrayObject{
                            self.strCurrentPageIndex = data["list"]["current_page"].intValue
                            self.strLastPageIndex = data["list"]["total"].intValue
                            if CurrentPage == 1{
                                self.arrDataGenre.removeAllObjects()
                            }
                            self.arrDataGenre.addObjects(from: arrSearchResponse)
                            self.tblGenre.reloadData()
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
    
    func SearchByKeyword(keyWord: String) {
        
        if Connectivity.isConnectedToInternet() {
            //SVProgressHUD.show()
            let parameters: Parameters = [
                "keyword" : keyWord,
                ]
            Alamofire.request(Constant.APIs.SEARCCH_SONG_BY_KEYWORD, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                self.onGetResponse(response.result.value)
            })
        }else{
            self.displayAlertMessageWithTitle(title: Constant.APIs.InternetConnectionTitle, alertMessage: Constant.APIs.InternetConnectionMessage)
        }
    }
    
    
    func GetTopCA7SListAPI(CurrentPage: Int) {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            var parameters: Parameters = [
                "type" : strGenreID,
                "page" : CurrentPage
            ]
            
            if strUID != nil{
                parameters["user_id"] = "\(strUID!)"
                
            }
            
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.GET_TOP_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                self.onGetResponse(response.result.value)
            })
        }else{
            self.displayAlertMessageWithTitle(title: Constant.APIs.InternetConnectionTitle, alertMessage: Constant.APIs.InternetConnectionMessage)
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let height = self.view.bounds.height - 375
        if offset > 224 {
            // self.headerHeightConstraint.constant = 375 - 224
        }
        
        
        if(offset > 0) && (offset < 224){
            
            
            // self.tableHeaderView.frame = CGRect(x: 0, y: 60, width: self.view.bounds.size.width, height: 0)
        }else{
            
            
            //self.tableHeaderView.frame = CGRect(x: 0, y: 60, width: self.view.bounds.size.width, height: 100 - offset)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        let searchText  = textField.text! as NSString
        let txtAfterUpdate = searchText.replacingCharacters(in: range, with: string)
        if txtAfterUpdate == "" {
            self.arrDataGenre = self.allDataOfGenre
            self.isFilteering = false
        }else{
            
            self.isFilteering = true
            let item = (self.allDataOfGenre as! [[String: Any]]).filter { (item) -> Bool in
                var text = ""
                if let t = item["song_title"] as? String {
                    text = t
                }
                if let t = item["title"] as? String {
                    text = t
                }
                return text.localizedCaseInsensitiveContains(txtAfterUpdate)
            }
            self.arrDataGenre = NSMutableArray(array: item)
            
            
        }
        self.tblGenre.reloadData()
        
        return true
    }
    
    
}
