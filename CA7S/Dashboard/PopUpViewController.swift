//
//  PopUpViewController.swift
//  CA7S
//

import UIKit
import SVProgressHUD
import Alamofire
import Alamofire_SwiftyJSON
import SDWebImage
import ObjectMapper

class PopUpViewController: UIViewController, MusicPlayerControllerDelegate {
    
    @IBOutlet var playerSlider:UISlider!
    
    @IBOutlet weak var imgAlbumHeader: UIImageView!
    @IBOutlet weak var imgBottomSongAlbum: UIImageView!
    
    @IBOutlet weak var lblHeaderSongTitle: UILabel!
    @IBOutlet weak var lblBottomSongTitle: UILabel!
    @IBOutlet weak var lblHeaderAlbum: UILabel!
    @IBOutlet weak var lblBottomAlbumName: UILabel!
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnFavourite: UIButton!
    @IBOutlet weak var btnPlaylist: UIButton!
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnShareSong: UIButton!
    
    
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet var viewBorrom: NSLayoutConstraint!
    @IBOutlet var heightButtonView: NSLayoutConstraint!
    
    var timer : Timer?
    var strGenreID = String()
    var strAlbumName : String = ""
    var strFROMTOP = String()
    var strTrackType = String()
    var isPanning:Bool = false
    var trackData:[String:Any]?
    var repo = PlaylistRepositories()
    var strHeaderGenre = ""
    var mode = ""
    var isDownload = false
    var isForLocalPlayList = false
    var localPlaylist = LocalPlayList()
    
    var fromFav = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgBottomSongAlbum.layer.cornerRadius = 10
        imgBottomSongAlbum.layer.masksToBounds = true
        /*playerSlider.maximumTrackTintColor = UIColor.init(red: 254.0/255, green: 142.0/255, blue: 211.0/255, alpha: 1)
        playerSlider.minimumTrackTintColor = UIColor.white*/
        
        playerSlider.setMaximumTrackImage(#imageLiteral(resourceName: "max_track"), for: .normal)
        playerSlider.setMinimumTrackImage(#imageLiteral(resourceName: "min_track").stretchableImage(withLeftCapWidth: 5, topCapHeight: 5), for: .normal)
      //playerSlider.setThumbImage(#imageLiteral(resourceName: "slider_thumb"), for: .normal)
        //playerSlider.setThumbImage(#imageLiteral(resourceName: "slider_thumb"), for: .highlighted)
        
        if strFROMTOP == "YES"{
            strTrackType = "2"
        }else{
            strTrackType = "1"
        }
        btnLike.isHidden = false
        self.setLocalizationString()
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setLocalizationString(){
        btnLike.setTitle(NSLocalizedString("Like", comment: ""), for: .normal)
        btnFavourite.setTitle(NSLocalizedString("Add_to_Favorites", comment: ""), for: .normal)
        btnDownload.setTitle(NSLocalizedString("Download_Song", comment: ""), for: .normal)
        btnPlaylist.setTitle(NSLocalizedString("Add_to_Playlist", comment: ""), for: .normal)
        btnShareSong.setTitle(NSLocalizedString("Share_Song", comment: ""), for: .normal)
    }
    
    
    
    func updateDownloadInfo() {
        let item = trackData
        let audioID =  "\(String(describing: item!["id"]!))"
        let query = NSString(format: "SELECT * from audio where id = \"%@\"", audioID)
        let ArrSong = DataBase.sharedInstance().getDataFor(query as String)
        self.isDownload = !(ArrSong?.count == 0)
        self.btnDownload.isSelected = self.isDownload
    }
    
    func setbtnDefault() {
        btnDownload.isSelected = false
        btnLike.isHidden = false
        btnFavourite.isHidden = false
        btnShareSong.isHidden = false
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
        setbtnDefault()
        
        
        if self.isForLocalPlayList {
            setLocalPlayList()
            self.btnPlaylist.isSelected = false
            if let isPlaylist = self.trackData?["is_playlist"] as? Int {
                self.btnPlaylist.isSelected = isPlaylist == 1
            }
            
                self.btnLike.isHidden = true
                self.btnDownload.isHidden = true
            self.btnFavourite.isHidden = true
            
        }
        
        CADownloadManager.shared.progress = {p in
           // self.btnLike.progress = p
        }
        
//        if UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.IS_FROM_INTERNATIONAL) != nil{
//        if UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.IS_FROM_INTERNATIONAL) as! Bool == true{
//            btnLike.isHidden = true
//            heightButtonView.isActive = false
//        }else{
//            btnLike.isHidden = false
//            heightButtonView.isActive = true
//        }
//        }else{
//            btnLike.isHidden = true
//           // heightButtonView.isActive = false
//        }
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timedJob), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .commonModes)
        playerSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        
        let musicPlayer = CAMusicViewController.sharedInstance()
        
        if let mediaitem = musicPlayer?.nowPlayingItem {
            
            print("mediaitem",mediaitem)
            
            var imageURL = ""
            
            if (mediaitem["image_url"] != nil){
         
                imageURL = mediaitem["image_url"] as! String
            }
            
            self.imgBottomSongAlbum.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "default album"))
            //            let imgData = try? Data.init(contentsOf: URL.init(string: imageURL)!)
            //            if let data = imgData {
            //                img = UIImage.init(data: data)
            //                self.imgAlbumHeader.image = img;
            //                self.imgBottomSongAlbum.image = img;
            //            }
            
            self.lblBottomSongTitle.text = mediaitem["title"] as? String
            
            //self.lblBottomAlbumName.text = mediaitem["artist_name"] as? String
            
            if (mediaitem["album_name"] as? String) != nil{
                   self.lblBottomAlbumName.text = mediaitem["album_name"] as? String
            }else{
                    self.lblBottomAlbumName.text = musicPlayer?.strAlbumName
            }
            
            playerSlider.minimumValue = 0
            if Float(musicPlayer!.getTrackDuration()) > 0 {
                playerSlider.maximumValue = Float(musicPlayer!.getTrackDuration())
            } else {
                playerSlider.maximumValue = 1
            }
            
            playerSlider.value = Float(musicPlayer!.currentPlaybackTime)
            
            btnPlay.isSelected = musicPlayer?.playbackState == MPMusicPlaybackState.playing
        } else {
            viewBorrom.isActive = false
        }
        if let trackData = trackData {
            self.lblHeaderSongTitle.text = trackData["title"] as? String
            self.lblHeaderAlbum.text = trackData["artist_name"] as? String
            /*if (trackData["album_name"] as? String) != nil{
                self.lblHeaderAlbum.text = trackData["album_name"] as? String
            }else{
                self.lblHeaderAlbum.text = strAlbumName
            }*/
            var imageURL = ""
            if(trackData["image_url"] != nil){
                imageURL = trackData["image_url"] as! String
            }
            
            self.imgAlbumHeader.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "default album"))
            
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            if strUID == nil{
                
//                btnFavourite.isHidden = true
//                btnPlaylist.isHidden = true
//                btnLike.isHidden = true

            }else if mode == "offline"{
                
        }else{
           
                //btnFavourite.isSelected = Bool(trackData["is_favorite"] as! Bool)
                
                if UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.IS_FROM_INTERNATIONAL) != nil {
                    
                    if UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.IS_FROM_INTERNATIONAL) as! Bool == true {
                        
                    }
                    else {
                        if((trackData["is_playlist"] as? Bool) != nil){
                            btnPlaylist.isSelected = Bool(trackData["is_playlist"] as! Bool)
                        }
                        btnLike.isSelected = Bool(trackData["is_like"] as! Bool)
                    }
                }
            
            if let boolLike = trackData["is_like"]{
                
                print(boolLike)
                let boolLike1 = trackData["is_like"] as? Bool
                
                if boolLike1 == true {
                    self.btnLike.isSelected = true
                }else{
                    self.btnLike.isSelected = false
                }
            }
            
            
            if let boolFav = trackData["is_favorite"] {
                
                print(boolFav)
                let boolFav1 = trackData["is_favorite"] as? Bool
                
                if boolFav1 == true{
                    self.btnFavourite.isSelected = true
                }else{
                    self.btnFavourite.isSelected = false
                }
            }
            
            if let boolPlaylist = trackData["is_playlist"] {
                
                print(boolPlaylist)
                let boolPlaylist1 = trackData["is_playlist"] as? Bool
                
                if boolPlaylist1 == true {
                    self.btnPlaylist.isSelected = true
                }else{
                    self.btnPlaylist.isSelected = false
                }
               
                
            }
            }
            
            let audioID = "\(trackData["id"]!)"
            let query = NSString(format: "SELECT * from audio where id = \"%@\"", audioID)
            let ArrSong = DataBase.sharedInstance().getDataFor(query as String)
            btnDownload.isSelected = false
            if ArrSong!.count > 0 || (CADownloadManager.shared.arrIDs?.contains(audioID))! {
                btnDownload.isSelected = true
                btnLike.isHidden = true
                btnFavourite.isHidden = true
                
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
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
    
    func setLocalPlayList() {
        if let item = UserDefaults.standard.string(forKey: Constant.USERDEFAULTS.LOCAL_PLAYLIST) {
            self.localPlaylist = Mapper<LocalPlayList>().map(JSONString: item)!
            
            
        }
    }
    
    

    
    
    //MARK:- Button Actions
    
    @IBAction func btnLike(_ sender: Any) {
        
        
        let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
        
        //        print(strUID)
        
        if strUID == nil{
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            
            vc.mode = "musicPlayer"
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else{
        likeUnLikeTrack()
        }
    }
    
    @IBAction func btnAddToFavourite(_ sender: Any) {
        
        let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
        
        //        print(strUID)
        
        if strUID == nil{
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            
            vc.mode = "musicPlayer"
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else{
        favoriteUnfavoriteTrack()
        }
    }
    
    @IBAction func btnAddToPlaylist(_ sender: Any) {
        
        let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
        if strUID == nil && !isForLocalPlayList{
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            
            vc.mode = "musicPlayer"
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else{
        addToPlaylistTrack()
        }
    }
    
    @IBAction func btnDownload(_ sender: MyCircularProgressButton) {
        
        let item = trackData
        let audioID =  "\(String(describing: item!["id"]!))"
        let query = NSString(format: "SELECT * from audio where id = \"%@\"", audioID)
        let ArrSong = DataBase.sharedInstance().getDataFor(query as String)
        
        if btnDownload.isSelected {
            if (CADownloadManager.shared.arrIDs?.contains(audioID))! {
                self.displayAlertMessage(messageToDisplay: NSLocalizedString("This_song_is_downloading", comment: ""))
            } else {
                self.displayAlertMessage(messageToDisplay: NSLocalizedString("This_song_is_already_downloaded", comment: ""))
            }
            
        } else {
            var index:Int = -1
            var fdi:FileDownloadInfo?
            if CADownloadManager.shared.arrIDs?.contains(audioID) == true {
                index = (CADownloadManager.shared.arrIDs?.index(of: audioID))!
                fdi = CADownloadManager.shared.arrFileInfo?[index]
            } else {
                let url = "https://www.ca7s.com" + (item!["stream_url"] as! String)
                
                fdi = FileDownloadInfo(title: (item!["title"] as? String)!, downloadSource: url, downloadSource2: "", andFile: audioID, data: item!, album:CAMusicViewController.sharedInstance().strAlbumName, lyrics: item!["lyrics"] as? String ?? "", albumImageUrl: "")
                
//                print(trackData!["stream_url"])
                
                
                //                fdi = FileDownloadInfo(title: (item!["title"] as? String)!, downloadSource: item!["stream_url"] as! String, andFile: audioID, data: item!, album:CAMusicViewController.sharedInstance().strAlbumName, lyrics: item!["lyrics"] as? String ?? "", is_like: (item!["is_like"] as? Bool)!, is_favorite: (item!["is_favorite"] as? Bool)!, like_count: "\((item!["like_count"])!)")
                
                CADownloadManager.shared.arrIDs?.append(audioID)
                CADownloadManager.shared.arrFileInfo?.append(fdi!)
                  CADownloadManager.shared.downloadFile(fdi!)
                CADownloadManager.shared.progress = { progress in
                    //sender.progress = progress
                }
               
            }
            
          
            btnDownload.isSelected = true
        }
    }
  
    @IBAction func btnShareSong(_ sender: Any){
        let mediaitem = trackData
        let text = mediaitem?["title"] as? String ?? ""
        let image = mediaitem?["image_url"] as? String ?? ""
        
        var mySongURL = ""

            mySongURL = mediaitem?["stream_url"] as? String ?? ""
        var strSongDesc : String = ""
        
        if (mediaitem?["artist_name"] as? String) != nil {
                strSongDesc = "\(((mediaitem?["artist_name"] as? String))!) \n\((strAlbumName))"
        }else{
            strSongDesc = strAlbumName
        }
        
            //mediaitem?["lyrics"] as? String
        
        var strTrackID : String  = ""
        if (mediaitem?["track_id"] as? Int) != nil {
            strTrackID = "\(((mediaitem?["track_id"] as? Int))!)"
        } else {
            let track_id = "\((mediaitem?["id"] as? String) ?? "25")"
            strTrackID = track_id
        }
        
        print(mySongURL)
        
        
        self.ShareMusicData(text: text, image: image, mySongURL: mySongURL ?? "", strSongDesc: strSongDesc , track_id: strTrackID )
        
    }

    
    @IBAction func btnPlay(_ sender: Any) {
        if CAMusicViewController.sharedInstance().playbackState == MPMusicPlaybackState.playing {
            CAMusicViewController.sharedInstance().pause()
            btnPlay.isSelected = false
        } else {
            CAMusicViewController.sharedInstance().play()
            btnPlay.isSelected = true
        }
    }
    
    @IBAction func btnPrevious(_ sender: Any) {
        CAMusicViewController.sharedInstance().skipToPreviousItem()
    }
    
    @IBAction func btnNext(_ sender: Any) {
        CAMusicViewController.sharedInstance().skipToNextItem()
    }
    
    //MARK:-
    //MARK:- API Calling
    
    func ShareMusicData(text: String, image: String, mySongURL: String,  strSongDesc: String, track_id: String) {
        
        if Connectivity.isConnectedToInternet() {
            
            //            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.integer(forKey: Constant.USERDEFAULTS.USER_ID)
            
            //            let mediaitem = dicMediaData
            //
            //            let text = mediaitem["title"] as? String ?? ""
            //            let image = mediaitem["image_url"] as! String
            //            let mySongURL = mediaitem["stream_url"] as? String
            //            let strSongDesc = mediaitem["lyrics"] as? String
            
            print(mySongURL)
            var desc : String = strSongDesc
            
            if strSongDesc == ""{
                desc = text
            }
            let parameters = [
                "user_id" : "\(strUID)",
                "title" : text,
                "music_description" : desc ,
                "music_thumbnail": image,
                "music_url": mySongURL,
                "track_id": track_id
            ]
            
            Alamofire.request(Constant.APIs.SHARE_MUSIC, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                //                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    var strGeneratedShareURL : String = ""
                    
                    if data["status"] == "success" {
                        strGeneratedShareURL =  "\((data["generated_url"]))"
                        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                        imageView.sd_setImage(with: URL(string: image), completed: nil)
                        
                        let items = [URL(string: strGeneratedShareURL)!, (imageView.image ?? UIImage())] as [Any]
                    
                        
                        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                        self.present(ac, animated: true)
                        
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
    
    
    func likeUnLikeTrack() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            var strURL:URLConvertible?
            if btnLike.isSelected == true {
                strURL = Constant.APIs.UNLIKE_TRACK
            } else {
                strURL = Constant.APIs.LIKE_TRACK
            }
            
            let data = trackData//CAMusicViewController.sharedInstance().nowPlayingItem as! [String:Any]
            var parameters = Parameters()
            
//            var item = CAMusicViewController.sharedInstance().nowPlayingItem as! [String:Any]
            
            parameters = [
                "user_id" : "\(strUID!)",
                "track_id" : "\(data!["id"]!)",
                "track_type" : strTrackType
            ]
            print("Para",parameters)
            
            Alamofire.request(strURL!, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        self.btnLike.isSelected = !self.btnLike.isSelected
                        
                        if CAMusicViewController.sharedInstance()?.nowPlayingItem != nil{
                        
                        var item = CAMusicViewController.sharedInstance().nowPlayingItem as! [String:Any]
                        
                        item["is_like"] = NSNumber.init(booleanLiteral: self.btnLike.isSelected)
                        item["is_favorite"] = NSNumber.init(booleanLiteral: self.btnFavourite.isSelected)
                        CAMusicViewController.sharedInstance().updateNowPlaying(forKey: item)
                            
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
    
    func favoriteUnfavoriteTrack() {
        
        if Connectivity.isConnectedToInternet() {
            
            //            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            var strURL:URLConvertible?
            if btnFavourite.isSelected == true {
                strURL = Constant.APIs.UNFAVORITE_TRACK
            } else {
                strURL = Constant.APIs.FAVORITE_TRACK
            }
            
            let data = trackData//CAMusicViewController.sharedInstance().nowPlayingItem as! [String:Any]
            var parameters = Parameters()
            
//            var item = CAMusicViewController.sharedInstance().nowPlayingItem as! [String:Any]
            
            parameters = [
                "user_id" : "\(strUID!)",
                "track_id" : "\(data!["id"]!)",
                "track_type" : strTrackType,
                "album_id" : strGenreID
            ]
            
            print("Para",parameters)
            
            Alamofire.request(strURL!, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                //                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        self.btnFavourite.isSelected = !self.btnFavourite.isSelected
                        
                        if CAMusicViewController.sharedInstance()?.nowPlayingItem != nil{
                            
                        var item = CAMusicViewController.sharedInstance().nowPlayingItem as! [String:Any]
                        item["is_like"] = NSNumber.init(booleanLiteral: self.btnLike.isSelected)
                        item["is_favorite"] = NSNumber.init(booleanLiteral: self.btnFavourite.isSelected)
                        CAMusicViewController.sharedInstance().updateNowPlaying(forKey: item)
                            
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
    
    func addToPlaylistTrack() {
        
        if !self.btnPlaylist.isSelected {
            let stosyBoard = UIStoryboard.init(name: "Profile", bundle: nil)
            let vc = stosyBoard.instantiateViewController(withIdentifier: "ShowPlaylistViewController") as! ShowPlaylistViewController
            vc.isAdded  = btnPlaylist.isSelected
            vc.data = self.trackData!
            vc.isForDownlaod = isForLocalPlayList
            vc.onSelect = {
                vc.dismiss(animated: true, completion: {
                    self.btnPlaylist.isSelected = !self.btnPlaylist.isSelected
                })
                
            }
            vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        }else{
            if isForLocalPlayList {
                if let idx = self.localPlaylist.data.firstIndex(where: {$0.playListName == self.strHeaderGenre}) {
                    let index = self.localPlaylist.data[idx].songsInPlaylist.index(where: { dictionary in
                        guard let value = dictionary["created"] as? String
                            else { return false }
                        return value == trackData?["created"] as! String
                    })
                    
                    if let index = index {
                        self.displayAlertMessage(messageToDisplay: NSLocalizedString("Song removed from playlist", comment: ""))
                        self.localPlaylist.data[idx].songsInPlaylist.remove(at: index)
                    }
                    self.btnPlaylist.isSelected = false
                    UserDefaults.standard.set(self.localPlaylist.toJSONString(), forKey: Constant.USERDEFAULTS.LOCAL_PLAYLIST)
                }
            }else{
                if let playListId = trackData!["playlist_id"] as? Int {
                    
                    let params = ["track_id": "\(trackData!["id"]!)", "playlist_id": "\(playListId)"]
                    
                    self.repo.playList(params: params, operation: .REMOVE_SONG_FROM_PLAYLIST_API) { (item) in
                        guard let data = item else {return}
                        self.displayAlertMessage(messageToDisplay: NSLocalizedString(data["message"].string ?? "Something Went wrong", comment: ""))
                        self.btnPlaylist.isSelected = !self.btnPlaylist.isSelected
                    }
                }
            }
        }
        
        
        
    }
    
    //MARK:-
    //MARK: CAMusicPlayerDelegate Methods
    
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
                
                if let imageURL = mediaitem["image_url"]{
                    let imgData = try? Data.init(contentsOf: URL.init(string: imageURL as! String)!)
                    if let data = imgData {
                        img = UIImage.init(data: data)
                        self.imgBottomSongAlbum.image = img;
                    }
                }
                self.lblBottomSongTitle.text = mediaitem["title"] as? String
                //                let duration = Float((mediaitem["duration"] as! Int))
                //                self.sliderPlayer.minimumValue = 0.0
                //                self.sliderPlayer.maximumValue  = Float(duration/60.0)
            }
        }
    }
    
    func musicPlayerDuration(_ musicPlayer: CAMusicViewController!, setduration item: AVPlayerItem!) {
        if item != nil {
            playerSlider.minimumValue = 0.0
            playerSlider.maximumValue = Float(CMTimeGetSeconds(item.duration))
        }
    }
}
