    //
    //  MusicPlayerVC.swift
    //  CA7S
    //
    
    import UIKit
    import SVProgressHUD
    import Alamofire
    import Alamofire_SwiftyJSON
    import iCarousel
    import PopoverKit
    import Network
    import SDWebImage
    import ObjectMapper
    
    class MusicPlayerVC: UIViewController, MusicPlayerControllerDelegate, selectSongDelegate, iCarouselDataSource, iCarouselDelegate {
        
        @IBOutlet weak var lyricsBackground: UIImageView!
        @IBOutlet weak var viewSongsListPan: UIView!
        @IBOutlet var vwSongsContainer: UIView!
        @IBOutlet weak var musicPlayer: iCarousel!
        @IBOutlet var sliderPlayer:UISlider!
        @IBOutlet var btnPlay:UIButton?
        @IBOutlet var btnNext:UIButton!
        @IBOutlet var btnPrevious:UIButton!
        @IBOutlet var btnLike:UIButton!
        @IBOutlet var btnShare:UIButton!
        @IBOutlet var btnFavorite:UIButton!
        @IBOutlet var btnDownload: MyCircularProgressButton!
        @IBOutlet var btnShuffle:UIButton!
        @IBOutlet var btnRepeat:UIButton!
        @IBOutlet var btnAddToPlaylist:UIButton!
        
        @IBOutlet weak var upnextLabel: UILabel!
        
        @IBOutlet var leadingDownloadButton:NSLayoutConstraint!
        
        @IBOutlet weak var lblTitle: UILabel!
        
        @IBOutlet var lblTrackTitle:UILabel!
        @IBOutlet var lblAlbumTitle:UILabel!
        @IBOutlet var lblLikeCount:UILabel!
        
        @IBOutlet var songImage:UIImageView!
        @IBOutlet var btnUpDown:UIButton!
        @IBOutlet var imgUpDown:UIImageView!
        @IBOutlet var imgMusicControl:UIImageView!
        
        var strSongID = String()
        var strLikeCount = String()
        var strTrackType = String()
        var strTrackTypeFromSearch = String()
        var strGenreID = String()
        var strFROMTOP = String()
        var strHeaderGenre = String()
        var strGenreName = String()
        var strGenreIsFrom = String()
        var strAlbumName = String()
        var strArtistName = String()
        var strMBID = String()
        var strIsFromTop = String()
        var strIsFromPlayer = String()
        var playListRepo = PlaylistRepositories()
        
        
        var timer : Timer?
        var isPanning:Bool = false
        
        var trackFavouriteStatus:((Bool) -> ())?
        
        var isFromMyMusic : Bool = false
        var isFromUploadMusic: Bool = false
        var isFromSearch: Bool = false
        var isDownload: Bool = false
        
        var isFrom = UIViewController()
        var canPlaySongFromScroll = false
        var maximumValueOfSlider: Float = 0.0
        var currentVisibleCell = 0
        
        var localPlaylist: LocalPlayList! = LocalPlayList()
        var isForLocalPlayList = false
        var isPresented = false
        private lazy var popUpVC: PopUpViewController =
        {
            let storyboard = UIStoryboard(name: "Profile", bundle: Bundle.main)
            var Controller = storyboard.instantiateViewController(withIdentifier: "PopUpViewController") as! PopUpViewController
            return Controller
        }()
        
        var genreData: [String: Any] = [:]
        
        var arrAlbumData = [[String: AnyObject]]()
        
        var mode = ""
        
        var intValue = 0
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        
        
        //MARK:-
        //MARK:- ViewController Lifecycle
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            musicPlayer.dataSource = self
            musicPlayer.delegate = self
            musicPlayer.isPagingEnabled = true
            musicPlayer.type = .linear
            
            sliderPlayer.setMaximumTrackImage(#imageLiteral(resourceName: "max_track"), for: .normal)
            self.showPopoverforLyricsTutorial()
            self.showPopoverforDownlaodAwareness()
            
            //            sliderPlayer.setThumbImage(#imageLiteral(resourceName: "slider_thumb"), for: .normal)
            //            sliderPlayer.setThumbImage(#imageLiteral(resourceName: "slider_thumb"), for: .highlighted)
            if CAMusicViewController.sharedInstance().playbackState == .playing {
                btnPlay?.isSelected = true
                imgMusicControl.image = UIImage(named: "mainControlPause")
            }
            CAMusicViewController.sharedInstance().add(self)
            
            if strFROMTOP == "YES"{
                strTrackType = "2"
            }else{
                strTrackType = "1"
            }
            
            // txtVLyrics.isHidden = true
            //        UIApplication.shared.beginReceivingRemoteControlEvents()
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))
            panGesture.cancelsTouchesInView = false
            //viewSongsListPan.addGestureRecognizer(panGesture)
            
            
            //self.view.bringSubview(toFront: viewSongsListPan)
        }
        
        
        // to getThe localPlayList
        func setLocalPlayList() {
            if let item = UserDefaults.standard.string(forKey: Constant.USERDEFAULTS.LOCAL_PLAYLIST) {
                
                self.localPlaylist = Mapper<LocalPlayList>().map(JSONString: item) ?? LocalPlayList()
               
               
            }
        }
        
        
        
        // to the show access of the lyrics
        func showPopoverforLyricsTutorial() {
            if !UserDefaults.standard.bool(forKey: Constant.shownLyricsTutorial) && UserDefaults.standard.bool(forKey: Constant.isAwareAboutTheDownloading){
                let txtLabel = PureTitleModel(title: NSLocalizedString("Tap_here_to_see_lyrics", comment: ""))
                let vc = PopoverTableViewController(items: [txtLabel])
                vc.pop.isNeedPopover = true
                vc.pop.popoverPresentationController?.sourceView = self.musicPlayer
                let y = (self.musicPlayer.bounds.height / 2) - 50
                vc.pop.popoverPresentationController?.sourceRect = CGRect(x: self.musicPlayer.bounds.minX, y: (self.musicPlayer.bounds.minY + y), width: self.musicPlayer.bounds.width, height: 50)
                vc.pop.popoverPresentationController?.arrowDirection = .up
                //  vc.delegate = self
                present(vc, animated: true, completion: nil)
                
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: Constant.shownLyricsTutorial)
                defaults.synchronize()
            }
        }
        
        // to the show the access of the download functionality
        func showPopoverforDownlaodAwareness() {
            if !UserDefaults.standard.bool(forKey: Constant.isAwareAboutTheDownloading){
                let txtLabel = PureTitleModel(title: NSLocalizedString("Tap_here_to_download_this_Song", comment: ""))
                let vc = PopoverTableViewController(items: [txtLabel])
                vc.pop.isNeedPopover = true
                vc.pop.popoverPresentationController?.sourceView = self.btnDownload
                vc.pop.popoverPresentationController?.sourceRect = self.btnDownload.bounds
                vc.pop.popoverPresentationController?.arrowDirection = .down
                //  vc.delegate = self
                present(vc, animated: true, completion: nil)
                
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: Constant.isAwareAboutTheDownloading)
                defaults.synchronize()
            }
        }
        
        
        // to show detect the network connetction type
        
        
        
        
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            self.setLocalPlayList()
            self.musicPlayer.scrollToItem(at: intValue, animated: false)
            
            
            self.lblTitle.text = NSLocalizedString("Now_Playing", comment: "")
            self.upnextLabel.text = NSLocalizedString("Up Next", comment: "")
            
            if strLikeCount == "0"{
                strLikeCount = ""
            }
            
            lblLikeCount.text = strLikeCount
            
            // if self.repet
            if CAMusicViewController.sharedInstance().repeatMode == MPMusicRepeatMode.one{
                self.btnRepeat.isSelected = true
            }else{
                self.btnRepeat.isSelected = false
            }
            
            // if self.Shuffle
            if CAMusicViewController.sharedInstance().shuffleMode {
                self.btnShuffle.isSelected = true
            }else{
                self.btnShuffle.isSelected = false
            }
            
            
            //        if self.isFromMyMusic == true{
            
            self.btnLike.isHidden = (CAMusicViewController.sharedInstance().playerType == .local)
            self.btnFavorite.isHidden = (CAMusicViewController.sharedInstance().playerType == .local)
        //    self.btnAddToPlaylist.isHidden = (CAMusicViewController.sharedInstance().playerType == .local)
            
            
            if isFromSearch {
                btnLike.isHidden = false
                btnFavorite.isHidden = false
                
                if self.isDownload == true{
                    btnDownload.isHidden = false
                }else if self.isDownload == false {
                    btnLike.isHidden = false
                    btnFavorite.isHidden = false
                    btnDownload.isHidden = false
                                }else{
                    print("Nothing.......")
                }
              
                if strTrackTypeFromSearch == "1"{
                    self.btnLike.isHidden = false
                    self.btnFavorite.isHidden = false
                 }else{
                    self.btnLike.isHidden = true
                    self.btnFavorite.isHidden = true
                }
                
            }
            self.btnAddToPlaylist.isHidden = self.isFromUploadMusic
            self.lblLikeCount.isHidden = (CAMusicViewController.sharedInstance().playerType == .local)
            if self.strHeaderGenre == "International" {
                if UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.IS_FROM_INTERNATIONAL) as! Bool == true{
                    btnLike.isHidden = true
                    //   heightButtonView.isActive = false
                }
            }
            
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timedJob), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: .commonModes)
            sliderPlayer.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
            if  CAMusicViewController.sharedInstance()?.queue == nil{
                self.navigationController?.popViewController(animated: true)
                return
            }
            if CAMusicViewController.sharedInstance().queue.count == 1 {
                btnNext.isEnabled = false
                btnPrevious.isEnabled = false
            } else {
                btnNext.isEnabled = true
                btnPrevious.isEnabled = true
            }
            
            let musicPlayer = CAMusicViewController.sharedInstance()
            
            if isFromSearch == false{
                strGenreID = CAMusicViewController.sharedInstance().strAlbumID ?? ""
            }
            
            
            
            if let mediaitem = musicPlayer?.nowPlayingItem {
                var imageURL = ""
                if mediaitem["image_url"] != nil {
                    imageURL = mediaitem["image_url"] as! String
                }
                
                self.lblTrackTitle.text = mediaitem["title"] as? String
                self.lblAlbumTitle.text = musicPlayer?.strAlbumName
                sliderPlayer.minimumValue = 0
                
                sliderPlayer.maximumValue = Float(musicPlayer!.getTrackDuration()) > 0 ? Float(musicPlayer!.getTrackDuration()) : 10
                maximumValueOfSlider = Float(musicPlayer!.getTrackDuration()) > 0 ? Float(musicPlayer!.getTrackDuration()) : 10
                sliderPlayer.value = Float(musicPlayer!.currentPlaybackTime)
                
                btnPlay?.isSelected = musicPlayer?.playbackState == MPMusicPlaybackState.playing
                imgMusicControl.image = UIImage(named: "mainControlPause")
                self.btnLike.isSelected = (mediaitem["is_like"] as? Bool) ?? false
                self.btnFavorite.isSelected = (mediaitem["is_favorite"] as? Bool) ?? false
                
                self.btnAddToPlaylist.isSelected = (mediaitem["is_playlist"] as? Bool) ?? false
                lblAlbumTitle.text = mediaitem["artist_name"] as? String
                
                let audioID = "\(mediaitem["id"]!)"
                let query = NSString(format: "SELECT * from audio where id = \"%@\"", audioID)
                let ArrSong = DataBase.sharedInstance().getDataFor(query as String)
                if ArrSong!.count > 0 || (CADownloadManager.shared.arrIDs?.contains(audioID))! {
                    btnDownload.isSelected = true
                    btnFavorite.isHidden = true
                    btnLike.isHidden = true
                    lblLikeCount.isHidden = true
                }
            }
            
            
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: genreData)
            
            UserDefaults.standard.set(encodedData, forKey: "trackData")
            UserDefaults.standard.synchronize()
            
        }
        
        func setupNextSongs() {
            Songs.delegate = self
            Songs.isComingFrom = "musicPlayer"
            getSongsUpNextSongs()
            addChildViewController(Songs)
            Songs.onMovePlayList = { [weak self] songsData in
                
                // this logic is written for the reaarringing order to set next song in play list
                guard let strongSelf = self else{return}
                let count = (strongSelf.arrAlbumData.count - 1) - strongSelf.intValue
                strongSelf.arrAlbumData.removeLast(count)
                
                let remaingItem = strongSelf.arrAlbumData
                let songs = NSMutableArray(array: remaingItem)
                let mergedArray = songs.addingObjects(from: songsData as [AnyObject])
                strongSelf.arrAlbumData = mergedArray as! [[String : AnyObject]]
                strongSelf.musicPlayer.reloadData()
                CAMusicViewController.sharedInstance()?.setQueueWithItemCollection(NSMutableArray(array: mergedArray))
                
                //strongSelf.getSongsUpNextSongs()
            }
            vwSongsContainer.addSubview(Songs.view)
            Songs.didMove(toParentViewController: self)
        }
        
        
        func getSongsUpNextSongs() {
            Songs.view.backgroundColor = UIColor.clear
            if arrAlbumData.count == 1 {return}
            var temp = arrAlbumData
            temp.removeFirst(self.intValue + 1)
            let arrData = NSMutableArray(array: temp)
            
            Songs.arrData = arrData
            Songs.tblMusicList.reloadData()
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
                sliderPlayer.value = Float(CAMusicViewController.sharedInstance().currentPlaybackTime)
                
                //MANSI's Code
                
                if isFromMyMusic || isForLocalPlayList{
                    if sliderPlayer.value == 0.0 {
                        CAMusicViewController.sharedInstance().skipToNextItem()
                    }
                }
            }
            
        }
        
        
        private lazy var Songs: SongsVC =
        {
            let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle.main)
            var Controller = storyboard.instantiateViewController(withIdentifier: "SongsVC") as! SongsVC
            Controller.Nav = self.navigationController
            return Controller
        }()
        
        //MARK:- Button Action
        
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
        
        
        
        @IBAction func btnBack(_ sender: Any){
            if mode == "favourite" || isPresented{
                self.dismiss(animated: true, completion: nil)
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        @IBAction func btnOptionsPressed(_ sender: Any) {
            
            self.addChildViewController(popUpVC)
            popUpVC.view.frame = self.view.frame
            popUpVC.trackData = genreData
            if strGenreName == NSLocalizedString("Brand_New", comment: "") || strGenreName == NSLocalizedString("Top_Ca7s", comment: ""){
                let track = genreData
                popUpVC.strAlbumName = track["album_name"] as? String ?? ""
            }else{
                popUpVC.strAlbumName = strGenreName
            }
            
            if strIsFromTop == "YES"{
                popUpVC.strFROMTOP = "YES"
            }else{
                popUpVC.strFROMTOP = "NO"
            }
            
            popUpVC.strGenreID = strGenreID
            
            if mode == "offline"{
                popUpVC.mode = "offline"
            }
            
            self.view.addSubview(popUpVC.view)
            popUpVC.didMove(toParentViewController: self)
        }
        
        
        
        @IBAction func btnPlay(_ sender: Any){
            if CAMusicViewController.sharedInstance().playbackState == MPMusicPlaybackState.playing {
                CAMusicViewController.sharedInstance().pause()
                btnPlay?.isSelected = false
                imgMusicControl.image = UIImage(named: "main controls")
            } else {
                CAMusicViewController.sharedInstance().play()
                btnPlay?.isSelected = true
                imgMusicControl.image = UIImage(named: "mainControlPause")
            }
        }
        
        @IBAction func btnNext(_ sender: Any){
            
            if intValue < arrAlbumData.count - 1 {
                intValue = intValue+1
                playItem(intValue)
            }
        }
        
        @IBAction func btnPrevious(_ sender: Any){
            
            if intValue > 0 {
                intValue = intValue-1
                playItem(intValue)
                
            }
        }
        
        func playItem(_ at: Int) {
            musicPlayer.scrollToItem(at: at, animated: true)
        }
        
        
        @IBAction func btnLike(_ sender: Any){
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            if strUID == nil{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                vc.mode = "musicPlayer"
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else{
                likeUnLikeTrack()
            }
        }
        
        @IBAction func btnShareAction(_ sender: Any){
            
            let mediaitem = CAMusicViewController.sharedInstance().nowPlayingItem
            let text = mediaitem?["title"] as? String ?? ""
            
            var image = ""
            if let imgUrl = mediaitem?["image_url"] as? String{
                image = imgUrl
            }
            
            if let imgUrl = mediaitem?["artwork_url"] as? String {
                image = imgUrl
            }
            
            var mySongURL = ""
            
            mySongURL = mediaitem?["stream_url"] as? String ?? ""
            var strSongDesc : String = ""
            
            if (mediaitem?["artist_name"] as? String) != nil {
                strSongDesc = "\(((mediaitem?["artist_name"] as? String))!) \n\((strAlbumName))"
            }else{
                strSongDesc = strAlbumName
            }
            var strTrackID : String  = ""
            if (mediaitem?["track_id"] as? Int) != nil {
                strTrackID = "\(((mediaitem?["track_id"] as? Int))!)"
            } else {
                if let track_id = mediaitem?["id"] as? String {
                    strTrackID = track_id
                }
                
            }
            self.ShareMusicData(text: text, image: image, mySongURL: mySongURL ?? "", strSongDesc: strSongDesc , track_id: strTrackID )
        }
        
        func ShareMusicData(text: String, image: String, mySongURL: String,  strSongDesc: String, track_id: String) {
            
            if Connectivity.isConnectedToInternet() {
                
                //            //SVProgressHUD.show()
                let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
                var desc : String = strSongDesc
                
                if strSongDesc == ""{
                    desc = text
                }
                let  parameters = [
                    "user_id" : "\(strUID ?? 0)",
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
                            var items = [URL(string: strGeneratedShareURL)!] as [Any]
                            if let i = imageView.image {
                                items.append(i)
                            }
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
        
        
        
        
        @IBAction func btnAddToPlaylist(_ sender: Any){
            
            
            
            
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            if strUID == nil && !self.isForLocalPlayList{
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                
                vc.mode = "musicPlayer"
                //            sideMenuViewController?.contentViewController = UINavigationController(rootViewController: vc)
                //            sideMenuViewController?.hideMenuViewController()
                
                self.navigationController?.pushViewController(vc, animated: true)
                
                
            }else{
                addToPlaylistTrack()
            }
        }
        
        @IBAction func btnFavorite(_ sender: Any) {
            
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            if strUID == nil{
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                
                vc.mode = "musicPlayer"
                //            sideMenuViewController?.contentViewController = UINavigationController(rootViewController: vc)
                //            sideMenuViewController?.hideMenuViewController()
                
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else {
                favoriteUnfavoriteTrack()
            }
        }
        
        @IBAction func btnDownload(_ sender: MyCircularProgressButton) {
            
            let item = CAMusicViewController.sharedInstance().nowPlayingItem
            let item2 = genreData
            let audioID =  "\(String(describing: item!["id"] ?? ""))"
            //        let query = NSString(format: "SELECT * from audio where id = \"%@\"", audioID)
            //        let ArrSong = DataBase.sharedInstance().getDataFor(query as String)
            if btnDownload.isSelected {
                if (CADownloadManager.shared.arrIDs?.contains(audioID)) ?? false {
                    self.displayAlertMessage(messageToDisplay: NSLocalizedString("This_song_is_downloading", comment: ""))
                } else {
                    self.displayAlertMessage(messageToDisplay: NSLocalizedString("This_song_is_already_downloaded", comment: ""))
                }
                
            } else {
                var index:Int = -1
                var fdi:FileDownloadInfo?
                if CADownloadManager.shared.arrIDs?.contains(audioID) == true {
                    index = (CADownloadManager.shared.arrIDs?.index(of: audioID)) ?? 0
                    fdi = CADownloadManager.shared.arrFileInfo?[index]
                } else {
                    var lyrics = ""
                    //                if let str = item!["lyrics"] {
                    //                    lyrics = str as! String
                    //                }
                    
                    if let str = item!["lyrics"] as? String {
                        lyrics = str
                    }
                    
                    
                    //Updated By MANSI//
                    
                    if let strAlbum = item!["album_name"] as? String{
                        CAMusicViewController.sharedInstance().strAlbumName = item!["album_name"] as? String
                    }else{
                        CAMusicViewController.sharedInstance().strAlbumName = ""
                    }
                    
                  
                    if let streamUrl = item!["stream_url"] as? String {
                        var source =  streamUrl
                        if source.contains("ca7s/storage") {
                          source =  "https://www.ca7s.com" + streamUrl
                        }
                       
                        
                        
                        fdi = FileDownloadInfo(title: (item!["title"] as? String)!, downloadSource: source, downloadSource2: source, andFile: audioID, data: item as! [String:Any], album:CAMusicViewController.sharedInstance().strAlbumName, lyrics:item!["lyrics"] as? String ?? "", albumImageUrl: item!["image_url"] as? String ?? "")
                        
                        CADownloadManager.shared.arrIDs?.append(audioID)
                        CADownloadManager.shared.arrFileInfo?.append(fdi!)
                    }
                    
                    CADownloadManager.shared.downloadFile(fdi!)
                    CADownloadManager.shared.progress = { progress in
                        sender.progress = progress
                        if progress == 0.0 {
                            self.displayAlertMessage(messageToDisplay: NSLocalizedString("This_song_is_already_downloaded", comment: ""))
                        }
                        if progress == 1.0 {
                            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Download completed", comment: ""))
                        }
                    }
                    btnDownload.isSelected = true
                }
                    }
                    
             
        }
        
        @IBAction func btnShuffle(_ sender: Any){
            CAMusicViewController.sharedInstance().shuffleMode = !CAMusicViewController.sharedInstance().shuffleMode
            btnShuffle.isSelected = CAMusicViewController.sharedInstance().shuffleMode
        }
        
        @IBAction func btnRepeat(_ sender: Any){
            if !btnRepeat.isSelected {
                CAMusicViewController.sharedInstance().repeatMode = MPMusicRepeatMode.one
                btnRepeat.isSelected = true
            } else {
                CAMusicViewController.sharedInstance().repeatMode = MPMusicRepeatMode.none
                btnRepeat.isSelected = false
            }
        }
        
        
        @IBAction func btnUpDownAction(_ sender: UIButton) {
            
            if !btnUpDown.isSelected {
                btnUpDown.isSelected = true
                let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle.main)
                var Controller = storyboard.instantiateViewController(withIdentifier: "SongsVC") as! SongsVC
                
                Controller.Nav = self.navigationController
                Songs = Controller
                UIView.animate(withDuration: 0.5, animations: {
                    
                    
                    self.setupNextSongs()
                    
                    self.viewSongsListPan.frame = CGRect(x: 0, y: 50, width: self.viewSongsListPan.frame.size.width, height: self.viewSongsListPan.frame.size.height)
                }){ (completion) in
                    self.lyricsBackground.isHidden = false
                    self.imgUpDown.image = UIImage(named: "backward")
                }
            }
            else {
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.viewSongsListPan.frame = CGRect(x: 0, y: self.viewSongsListPan.frame.size.height-30, width: self.viewSongsListPan.frame.size.width, height: self.viewSongsListPan.frame.size.height)
                    
                    // self.viewSongsListPan.frame = CGRect(x: 0, y: 80, width: self.viewSongsListPan.frame.size.width, height: self.viewSongsListPan.frame.size.height)
                    
                }) { (completion) in
                    self.Songs.willMove(toParentViewController: nil)
                    self.Songs.view.removeFromSuperview()
                    self.Songs.removeFromParentViewController()
                    self.lyricsBackground.isHidden = true
                    self.imgUpDown.image = UIImage(named: "Forward")
                }
                btnUpDown.isSelected = false
            }
            
        }
        
        
        
        
        func numberOfItems(in carousel: iCarousel) -> Int {
            if !UserDefaults.standard.bool(forKey: Constant.USERDEFAULTS.economicMode) {
                return isFromSearch ? 1 : arrAlbumData.count
            }else{
                return 0
            }
        }
        
        func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
            let dictData = arrAlbumData[index]
            //            let strImgeUrl = (dictData as! [String:Any])["image_url"] as? String
            //            if(strImgeUrl != nil){
            //                cell.imgAlbum.sd_setImage(with: URL(string: strImgeUrl!), placeholderImage: UIImage(named: "placeholder.png"))
            //            }
            var strImgeUrl = ""
            if let image = dictData["image_url"] as? String {
                strImgeUrl = image
            } else if let image = dictData["artwork_url"] as? String {
                strImgeUrl = image
            }
            
            if isFromSearch {
                strImgeUrl = self.genreData["artwork_url"] as? String ?? ""
            }
            
            
            
            
            let width = carousel.frame.width * 0.9
            let height = carousel.frame.height
            let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
            let pic =  UIImageView(frame: CGRect(x: 20, y: 10, width: (width - 20), height: (height - 10)))
            view.addSubview(pic)
            pic.contentMode = .scaleToFill
            pic.layer.cornerRadius = 10
            pic.layer.masksToBounds = true
            
            pic.sd_setImage(with: URL(string: strImgeUrl ?? ""), completed: nil)
            
            return view
        }
        
        func carouselDidScroll(_ carousel: iCarousel) {
            
            
            let index = carousel.currentItemIndex
            intValue = index
            if canPlaySongFromScroll && index > -1 {
                CAMusicViewController.sharedInstance()?.playItem(at: UInt(index))
            }
            canPlaySongFromScroll = true
        }
        
        
        func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
            let c = self.storyboard?.instantiateViewController(withIdentifier:  "LyricsViewController") as! LyricsViewController
            c.modalPresentationStyle = .overCurrentContext
            
            c.dictData = self.arrAlbumData[index]
            let item = CAMusicViewController.sharedInstance().nowPlayingItem
             c.lyrics = NSLocalizedString("No Lyrics Found", comment: "")
            if let lyrics =  item!["lyrics"] as? String {
                 c.lyrics = lyrics
            }
            
          
            present(c, animated: true, completion: nil)
            
        }
        
        
        @IBAction func btnCrossLyricsAction(_ sender: Any) {
            //self.vwLyrics.isHidden = true
        }
        
        // MARK:- CAMusicPlayerDelegate Methods
        
        func musicPlayer(_ musicPlayer: CAMusicViewController!, playbackStateChanged playbackState: MPMusicPlaybackState, previousPlaybackState: MPMusicPlaybackState) {
            //        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PlayBackStateChanged"), object: nil)
            btnPlay?.isSelected = (playbackState == .playing)
            imgMusicControl.image = UIImage(named: "mainControlPause")
            SVProgressHUD.dismiss()
        }
        
        func musicPlayer(_ musicPlayer: CAMusicViewController!, trackDidChange nowPlayingItem: [AnyHashable : Any]!, previousTrack: [AnyHashable : Any]!) {
            if nowPlayingItem != nil {
                // Dont try to ever remove this otherwise it will set current item always to 0
                DispatchQueue.main.async {
                    let mediaitem = nowPlayingItem as! [String:Any]
                    self.setViewfor(mediaitem)
                    let audioID = "\(mediaitem["id"] ?? "")"
                    let query = NSString(format: "SELECT * from audio where id = \"%@\"", audioID)
                    let ArrSong = DataBase.sharedInstance().getDataFor(query as String)
                    if ArrSong!.count > 0 || (CADownloadManager.shared.arrIDs?.contains(audioID))! {
                        self.btnDownload.isSelected = true
                        self.btnDownload.progress = 1.0
                    } else {
                        self.btnDownload.isSelected = false
                        self.btnDownload.progress = 0
                    }
                    let temp = Int(musicPlayer.indexOfNowPlayingItem)
                    if temp != self.intValue {
                        self.intValue = temp
                        self.canPlaySongFromScroll = false
                        self.musicPlayer.scrollToItem(at: self.intValue, animated: false)
                    }
                    self.btnAddToPlaylist.isSelected = (mediaitem["is_playlist"] as? Bool) ?? false
                    if let _ = mediaitem["playlist_id"] as? Int {
                        self.btnAddToPlaylist.isSelected = true
                        
                    }
                    
                    
                    
                    self.GetSingleTrackDetailUsingId()
                }
                
            }
        }
        
      
        
        
        func musicPlayerDuration(_ musicPlayer: CAMusicViewController!, setduration item: AVPlayerItem!) {
            if item != nil {
                sliderPlayer.minimumValue = 0.0
                sliderPlayer.maximumValue = Float(CMTimeGetSeconds(item.duration))
            }
        }
        
        func musicPlayer(_ musicPlayer: CAMusicViewController!, endOfQueueReached lastTrack: [AnyHashable : Any]!) {
            
        }
        
        override func remoteControlReceived(with event: UIEvent?) {
            if event?.type != .remoteControl {
                return
            }
            
            let musicPlayer = CAMusicViewController.sharedInstance()
            if event?.subtype ==  UIEventSubtype.remoteControlTogglePlayPause {
                if musicPlayer?.playbackState == .playing {
                    musicPlayer?.pause()
                } else {
                    musicPlayer?.play()
                }
            } else if event?.subtype == UIEventSubtype.remoteControlPlay {
                musicPlayer?.play()
            } else if event?.subtype ==  UIEventSubtype.remoteControlNextTrack {
                musicPlayer?.skipToNextItem()
            } else if event?.subtype ==  UIEventSubtype.remoteControlPreviousTrack {
                musicPlayer?.skipToPreviousItem()
            } else if event?.subtype ==  UIEventSubtype.remoteControlPause {
                musicPlayer?.pause()
            } else if event?.subtype ==  UIEventSubtype.remoteControlEndSeekingForward {
                musicPlayer?.endSeeking()
            } else if event?.subtype ==  UIEventSubtype.remoteControlEndSeekingBackward {
                musicPlayer?.endSeeking()
            } else if event?.subtype ==  UIEventSubtype.remoteControlStop {
                musicPlayer?.stop()
            } else if event?.subtype ==  UIEventSubtype.remoteControlBeginSeekingForward {
                musicPlayer?.beginSeekingForward()
            } else if event?.subtype ==  UIEventSubtype.remoteControlBeginSeekingBackward {
                musicPlayer?.beginSeekingBackward()
            }
        }
        
        //MARK:- API Calling
        
        func GetSingleTrackDetailUsingId(){
            var item = CAMusicViewController.sharedInstance().nowPlayingItem as! [String:Any]
            guard let _ = item["id"] as? Int else{return}
            if Connectivity.isConnectedToInternet() {
                
                ////SVProgressHUD.show()
                let strUID = UserDefaults.standard.string(forKey: Constant.USERDEFAULTS.USER_ID)
                
                
                var parameters: Parameters =  [
                    "track_id" : "\(item["id"]!)"
                ]
                
                if let str = strUID {
                    parameters["user_id"] = str
                }
                
                
                
                Alamofire.request(Constant.APIs.Get_SINGLE_Track, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                    SVProgressHUD.dismiss()
                    if let data = response.result.value {
                        if data["status"] == "success" {
                            self.setViewfor(data["data"].dictionaryObject!)
                            //self.btnLike.isSelected = (data["data"]["is_like"] as? Bool) ?? false
                        }else{
                            let strMsg = data["message"]
                            if !strMsg.string!.contains("required") {
                            self.displayAlertMessage(messageToDisplay: strMsg.string!)
                            }
                        }
                    }else{
                        self.displayAlertMessage(messageToDisplay: NSLocalizedString("Something_went_wrong", comment: ""))
                    }
                })
            }else{
                self.displayAlertMessageWithTitle(title: Constant.APIs.InternetConnectionTitle, alertMessage: Constant.APIs.InternetConnectionMessage)
            }
        }
        
        func setViewfor(_ mediaitem: [String: Any]) {
            self.lblTrackTitle.text = mediaitem["title"] as? String
            self.lblAlbumTitle.text = mediaitem["artist_name"] as? String
            self.btnLike.isSelected = (mediaitem["is_like"] as? Bool) ?? false
            self.btnFavorite.isSelected = (mediaitem["is_favorite"] as? Bool) ?? false
            
            
            
            self.lblLikeCount.text = ((mediaitem["like_count"] as? Int) ?? 0).description
            if let duration = mediaitem["duration"] as? String{
                let duration1 = Float(duration) ?? 0.0
                self.sliderPlayer.minimumValue = 0.0
                self.sliderPlayer.maximumValue  = Float(duration1/60.0)
            }
        }
        
        
        func likeUnLikeTrack() {
            
            if Connectivity.isConnectedToInternet() {
                
                ////SVProgressHUD.show()
                let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
                
                var strURL:URLConvertible?
                if btnLike.isSelected == true {
                    strURL = Constant.APIs.UNLIKE_TRACK
                } else {
                    strURL = Constant.APIs.LIKE_TRACK
                }
                
                var item =
                    CAMusicViewController.sharedInstance().nowPlayingItem as! [String:Any]
                var parameters = Parameters()
                
                parameters = [
                    "user_id" : "\(strUID!)",
                    "track_id" : "\(item["id"]!)",
                    "track_type" : strTrackType
                ]
                print("Para",parameters)
                
                Alamofire.request(strURL!, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                    
                    SVProgressHUD.dismiss()
                    
                    if let data = response.result.value {
                        
                        if data["like_count"].description == "0"{
                            self.lblLikeCount.text = ""
                            self.strLikeCount = ""
                        }else{
                            self.lblLikeCount.text = data["like_count"].description
                            self.strLikeCount = data["like_count"].description
                        }
                        
                        //                    self.lblLikeCount.text = data["like_count"].description
                        
                        if data["status"] == "success" {
                            self.btnLike.isSelected = !self.btnLike.isSelected
                            
                            item["is_like"] = NSNumber.init(booleanLiteral: self.btnLike.isSelected)
                            item["is_favorite"] = NSNumber.init(booleanLiteral: self.btnFavorite.isSelected)
                            CAMusicViewController.sharedInstance().updateNowPlaying(forKey: item)
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
                
                var strURL = ""
                if btnFavorite.isSelected == true {
                    strURL = Constant.APIs.UNFAVORITE_TRACK
                } else {
                    strURL = Constant.APIs.FAVORITE_TRACK
                }
                
                var item = CAMusicViewController.sharedInstance().nowPlayingItem as! [String:Any]
                var parameters = Parameters()
                
                var track_type : String = ""
                
                
                if isFromSearch{
                    track_type = strTrackTypeFromSearch
                }else{
                    track_type = strTrackType
                }
                
                parameters = [
                    "user_id" : "\(strUID!)",
                    "track_id" : "\(item["id"]!)",
                    "track_type" : track_type,
                    "album_id" : strGenreID
                ]
                
                print("Para",parameters)
                
                Alamofire.request(strURL, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                    
                    //                SVProgressHUD.dismiss()
                    
                    if let data = response.result.value {
                        
                        if data["status"] == "success" {
                            self.btnFavorite.isSelected = !self.btnFavorite.isSelected
                            
                            item["is_like"] = NSNumber.init(booleanLiteral: self.btnLike.isSelected)
                            item["is_favorite"] = NSNumber.init(booleanLiteral: self.btnFavorite.isSelected)
                            
                            CAMusicViewController.sharedInstance().updateNowPlaying(forKey: item)
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
            if isFromUploadMusic {return}
            var item = CAMusicViewController.sharedInstance().nowPlayingItem as! [String:Any]
            if Connectivity.isConnectedToInternet() {
                if !self.btnAddToPlaylist.isSelected {
                    let stosyBoard = UIStoryboard.init(name: "Profile", bundle: nil)
                    let vc = stosyBoard.instantiateViewController(withIdentifier: "ShowPlaylistViewController") as! ShowPlaylistViewController
                    vc.isAdded  = btnAddToPlaylist.isSelected
                    vc.data = item
                    vc.isForDownlaod = isForLocalPlayList
                   
                    vc.onSelect = {
                        vc.dismiss(animated: true, completion: {
                            self.btnAddToPlaylist.isSelected = !self.btnAddToPlaylist.isSelected
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
                                return value == item["created"] as! String
                            })
                            
                            if let index = index {
                                self.displayAlertMessage(messageToDisplay: NSLocalizedString("Songs is already added in playlist", comment: ""))
                                //self.localPlaylist.data[idx].songsInPlaylist.remove(at: index)
                            }
                            self.btnAddToPlaylist.isSelected = false
                            UserDefaults.standard.set(self.localPlaylist.toJSONString(), forKey: Constant.USERDEFAULTS.LOCAL_PLAYLIST)
                        }
                    }else{
                        if let playListId = item["playlist_id"] as? Int {
                            let params = ["track_id": "\(item["id"]!)", "playlist_id": "\(playListId)"]
                            
                            self.playListRepo.playList(params: params, operation: .REMOVE_SONG_FROM_PLAYLIST_API) { (item) in
                                guard let data = item else {return}
                                self.displayAlertMessage(messageToDisplay: NSLocalizedString(data["message"].string ?? "Something Went wrong", comment: ""))
                                self.btnAddToPlaylist.isSelected = !self.btnAddToPlaylist.isSelected
                            }
                        }
                    }
                }
            }else{
                self.displayAlertMessageWithTitle(title: Constant.APIs.InternetConnectionTitle, alertMessage: Constant.APIs.InternetConnectionMessage)
            }
        }
        @IBAction func moreView(_ sender: UIButton) {
            
            sender.isSelected = !sender.isSelected
            if sender.isSelected  {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.viewSongsListPan.frame = CGRect(x: 0, y: self.viewSongsListPan.frame.size.height-30, width: self.viewSongsListPan.frame.size.width, height: self.viewSongsListPan.frame.size.height)
                    
                    // self.viewSongsListPan.frame = CGRect(x: 0, y: 80, width: self.viewSongsListPan.frame.size.width, height: self.viewSongsListPan.frame.size.height)
                    
                }) { (completion) in
                    
                    self.btnUpDown.isSelected = false
                    self.imgUpDown.image = UIImage(named: "Forward")
                }
            }
            else {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.viewSongsListPan.frame = CGRect(x: 0, y: 50, width: self.viewSongsListPan.frame.size.width, height: self.viewSongsListPan.frame.size.height)
                }){ (completion) in
                    
                    self.btnUpDown.isSelected = true
                    self.imgUpDown.image = UIImage(named: "backward")
                }
            }
            
            
        }
        
        @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
            
            
            if sender.state == .began || sender.state == .changed {
                //
                //                let translation = gestureRecognizer.translation(in: self.view)
                //                print(gestureRecognizer.view!.center.y)
                //
                //                if(gestureRecognizer.view!.center.y > 555) {
                //
                //                    gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: gestureRecognizer.view!.center.y + translation.y)
                //                }
                //                else {
                //                    gestureRecognizer.view!.center = CGPoint(x:gestureRecognizer.view!.center.x, y:556)
                //                }
                //                gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
            }
            else if sender.state == .ended {
                
                
            }
        }
        
        
        //MARK: - selectSongMusicPlayerDelegate
        func selectSongMusicPlayerDelegate(int: Int) {
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.viewSongsListPan.frame = CGRect(x: 0, y: self.viewSongsListPan.frame.size.height-30, width: self.viewSongsListPan.frame.size.width, height: self.viewSongsListPan.frame.size.height)
                self.lyricsBackground.isHidden = true
                
            }) { (completion) in
                
                self.intValue = self.intValue + int + 1
                
                self.musicPlayer.scrollToItem(at: self.intValue, animated: false)
                CAMusicViewController.sharedInstance()?.playItem(self.arrAlbumData[int])
            }
        }
    }
    
    class MyCircularProgressButton : UIButton {
        var progress : Float = 0 {
            didSet {
                self.shapelayer?.strokeEnd = CGFloat(self.progress)
            }
        }
        private weak var shapelayer : CAShapeLayer?
        override func layoutSubviews() {
            super.layoutSubviews()
            guard self.shapelayer == nil else {return}
            let layer = CAShapeLayer()
            layer.frame = self.bounds
            layer.lineWidth = 2
            layer.fillColor = nil
            layer.strokeColor = UIColor.init(hexString: "#AB0092").cgColor
            let b = UIBezierPath(ovalIn: self.bounds.insetBy(dx: 3, dy: 3))
            layer.path = b.cgPath
            layer.strokeStart = 0
            layer.strokeEnd = 0
            layer.setAffineTransform(CGAffineTransform(rotationAngle: -.pi/2.0))
            self.layer.addSublayer(layer)
            self.shapelayer = layer
        }
    }
