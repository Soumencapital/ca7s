//
//  MyMusicVC.swift
//  CA7S
//

import UIKit
import SVProgressHUD
import ObjectMapper

class MyMusicVC: UIViewController,UITableViewDelegate,UITableViewDataSource, MusicPlayerControllerDelegate, UITextFieldDelegate, UITabBarControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var tblMusicList: UITableView!
    
    @IBOutlet weak var btnMenu: UIButton!
    
    @IBOutlet weak var heightView: NSLayoutConstraint!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnCloseSearch: UIButton!
    @IBOutlet weak var viewSearch: UIView!
    
    @IBOutlet weak var imgAlbum: UIImageView!
    @IBOutlet var viewPlayer:UIControl!
    @IBOutlet var playerSlider:UISlider!
    @IBOutlet var lblSongTitle: UILabel!
    @IBOutlet var lblAlbumName: UILabel!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var btnPrevious: UIButton!
    @IBOutlet var btnNext: UIButton!
    
    @IBOutlet var tblBottom: NSLayoutConstraint!
    @IBOutlet weak var viewPlayerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var viewBorder: UIView!

    @IBOutlet var CollectionView_Header: UICollectionView!

    
    var ArrImgMusicAlbum = NSMutableArray()
    var ArrSong = NSMutableArray()
    var ArrSongDescription = NSMutableArray()
    
    var timer : Timer?
    var isPanning:Bool = false
    
    var ArrFavourites = NSMutableArray()
    var Str_Song = String()
    var Str_Playlist = String()
    @IBOutlet weak var containerView: UIView!
    
    private lazy var popUpVC: PopUpViewController =
    {
        let storyboard = UIStoryboard(name: "Profile", bundle: Bundle.main)
        var Controller = storyboard.instantiateViewController(withIdentifier: "PopUpViewController") as! PopUpViewController
        return Controller
    }()
    
    
    private lazy var Playlists: PlaylistsVC =
    {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle.main)
        var Controller = storyboard.instantiateViewController(withIdentifier: "PlaylistsVC") as! PlaylistsVC
        Controller.Nav = self.navigationController
       Controller.isForDownlaod = true
        if let item = UserDefaults.standard.string(forKey: Constant.USERDEFAULTS.LOCAL_PLAYLIST) {
            
            Controller.localPlaylist = Mapper<LocalPlayList>().map(JSONString: item) ?? LocalPlayList()
           
        }
        return Controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewBorder.layer.cornerRadius = 25
        viewBorder.layer.masksToBounds = true
        viewBorder.layer.borderColor = UIColor.init(red: 171.0/255.0, green: 0, blue: 147.0/255.0, alpha: 1).cgColor
        viewBorder.layer.borderWidth = 1.0
        
        imgAlbum.layer.cornerRadius = 10
        imgAlbum.layer.masksToBounds = true
        
        Str_Song = "YES"
        
        ArrFavourites.add(NSLocalizedString("Songs", comment: ""))
        ArrFavourites.add(NSLocalizedString("Playlists", comment: ""))
        
        btnMenu.addTarget(self, action:#selector(SSASideMenu.presentLeftMenuViewController), for: .touchUpInside)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        tblMusicList.tintColor = UIColor.gray
        tblMusicList.tableFooterView = UIView()
        
        //viewSearch.isHidden = true
       // heightView.constant = 0
        
        /*playerSlider.maximumTrackTintColor = UIColor.init(red: 254.0/255, green: 142.0/255, blue: 211.0/255, alpha: 1)
        playerSlider.minimumTrackTintColor = UIColor.white*/
        
        playerSlider.setMaximumTrackImage(#imageLiteral(resourceName: "max_track"), for: .normal)
        playerSlider.setMinimumTrackImage(#imageLiteral(resourceName: "min_track").stretchableImage(withLeftCapWidth: 5, topCapHeight: 5), for: .normal)
      //playerSlider.setThumbImage(#imageLiteral(resourceName: "slider_thumb"), for: .normal)
        //playerSlider.setThumbImage(#imageLiteral(resourceName: "slider_thumb"), for: .highlighted)
        playerSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        
        txtSearch.delegate = self
        
        self.tabBarController?.delegate = self
        
        self.setLocalizationString()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setLocalizationString(){
        lblTitle.text = NSLocalizedString("Downloads", comment: "")
        txtSearch.placeholder = NSLocalizedString("Search", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLocalizationString()
        ArrFavourites.removeAllObjects()
       ArrFavourites.add(NSLocalizedString("Songs", comment: ""))
        ArrFavourites.add(NSLocalizedString("Playlists", comment: ""))
        CollectionView_Header.reloadData()
        self.tabBarItem.title = NSLocalizedString("Downloads", comment: "")
        
        if (CAMusicViewController.sharedInstance().playbackState == MPMusicPlaybackState.playing || CAMusicViewController.sharedInstance().playbackState == MPMusicPlaybackState.paused) {
          
            CAMusicViewController.sharedInstance().add(self)
            tblBottom.isActive = true
            viewPlayer.isHidden = false
            viewPlayerHeight.constant = 80
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timedJob), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: .commonModes)
            playerSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
            
            let musicPlayer = CAMusicViewController.sharedInstance()
            
            if let mediaitem = musicPlayer?.nowPlayingItem {
                
                var img:UIImage?
                var imageURL = ""
                
                if(mediaitem["image_url"] != nil){
                imageURL = mediaitem["image_url"] as! String
                } else if let image = mediaitem["artwork_url"] as? String {
                    imageURL = image
                }
                
                self.imgAlbum.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "default song"))
                self.lblSongTitle.text = mediaitem["title"] as? String
//                self.lblAlbumName.text = musicPlayer?.strAlbumName
                
                if (mediaitem["album_name"] as? String) != nil{
                    self.lblAlbumName.text = mediaitem["album_name"] as? String
                }else{
                    self.lblAlbumName.text = musicPlayer?.strAlbumName
                }
                
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
            tblBottom.isActive = false
            viewPlayer.isHidden = true
            viewPlayerHeight.constant = 0
        }
        
        let query = "SELECT * from audio ORDER BY created DESC"
        ArrSong = DataBase.sharedInstance().getDataFor(query)
        tblMusicList.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(fileDownloadComplete), name: NSNotification.Name.init(rawValue: Constant.appConstants.kDownloadCompleteNotification), object: nil)
        
        Playlists.view.frame = containerView.bounds
        containerView.addSubview(Playlists.view)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        CAMusicViewController.sharedInstance().remove(self)
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController == tabBarController.viewControllers?[3] {
            
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            if strUID == nil{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                sideMenuViewController?.contentViewController = UINavigationController(rootViewController: vc)
                sideMenuViewController?.hideMenuViewController()
                return false
            }else{
                return true
            }
        } else {
            return true
        }
    }
    
    func fileDownloadComplete() -> Void {
        DispatchQueue.main.async {
            let query = "SELECT * from audio ORDER BY created DESC"
            self.ArrSong = DataBase.sharedInstance().getDataFor(query)
            self.tblMusicList.reloadData()
        }
    }
    
    func timedJob() {
        if CAMusicViewController.sharedInstance().currentPlaybackTime > 0 {
            SVProgressHUD.dismiss()
        }
        if !isPanning {
            playerSlider.value = Float(CAMusicViewController.sharedInstance().currentPlaybackTime)
        }
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
//        controller.isFromMyMusic = true
        
        let trackData2  = UserDefaults.standard.object(forKey: "trackData")
        
        if trackData2 != nil{
            let trackData3 = NSKeyedUnarchiver.unarchiveObject(with: trackData2 as! Data) as? [String: Any]
            
            controller.genreData = trackData3!
            controller.arrAlbumData.append(trackData3 as! [String : AnyObject])
            controller.intValue = 0
            //controller.arrAlbumData = trackData3
        }
        
        controller.mode = "offline"
        
        self.navigationController?.pushViewController(controller, animated: true)
        
//        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func btnCloseSearch(_ sender: Any){
        
        viewSearch.isHidden = true
        //heightView.constant = 0
        txtSearch.text = ""
        let query = "SELECT * from audio ORDER BY created DESC"
        ArrSong = DataBase.sharedInstance().getDataFor(query)
        tblMusicList.reloadData()
    }
    
    @IBAction func btnPrevious(_ sender: Any) {
        CAMusicViewController.sharedInstance().skipToPreviousItem()
    }
    
    @IBAction func btnNext(_ sender: Any) {
        CAMusicViewController.sharedInstance().skipToNextItem()
    }
    //MARK:- UITextFieldDelegate
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text as NSString? {
            let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
            
            let query = NSString(format: "SELECT * from audio where title LIKE \"%%%@%%\" ORDER BY created DESC;", txtAfterUpdate)
//            let query = "SELECT * from audio where title LIKE '\(txtAfterUpdate)' ORDER BY created DESC"
            ArrSong = DataBase.sharedInstance().getDataFor(query as String?)
            tblMusicList.reloadData()
        }
        return true
    }
    
    //MARK:- Table Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if CADownloadManager.shared.arrFileInfo!.count > 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if CADownloadManager.shared.arrFileInfo!.count > 0 {
            if section == 0 {
                return CADownloadManager.shared.arrFileInfo!.count
            } else {
                return ArrSong.count
            }
        } else {
            return ArrSong.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:MyMusic_TBLCell = tableView.dequeueReusableCell(withIdentifier: "MyMusic_TBLCell") as! MyMusic_TBLCell
        cell.selectionStyle = .none
        
        if CADownloadManager.shared.arrFileInfo!.count > 0 {
            if indexPath.section == 0 {

                let data = CADownloadManager.shared.arrFileInfo![indexPath.row].dataDict!
                cell.lblSongTitle.text = data["title"] as? String
                cell.lblSongDescription.text = CADownloadManager.shared.arrFileInfo![indexPath.row].albumName//data["albumName"] as? String
                var strImgeUrl = data["image_url"] as? String
                
                cell.imgAlbum.sd_setShowActivityIndicatorView(true)
                cell.imgAlbum.sd_setIndicatorStyle(.gray)
                cell.imgAlbum.layer.cornerRadius = 15
                cell.imgAlbum.layer.masksToBounds = true
                if(strImgeUrl == nil){
                    strImgeUrl = ""
                }
                
                cell.imgAlbum.sd_setImage(with: URL(string: strImgeUrl!), placeholderImage: UIImage(named: "default album"))
                
//TopCa7s.png"
                return cell
            }
        }
        
        cell.lblSongTitle.text = (ArrSong[indexPath.row] as! [String:Any])["title"] as? String
        cell.lblSongDescription.text = (ArrSong[indexPath.row] as! [String:Any]) ["albumName"] as? String
        let strImgeUrl = (ArrSong[indexPath.row] as! [String:Any])["image_url"] as? String
        
        cell.imgAlbum.layer.cornerRadius = 15
        cell.imgAlbum.layer.masksToBounds = true
        cell.imgAlbum.sd_setShowActivityIndicatorView(true)
        cell.imgAlbum.sd_setIndicatorStyle(.gray)
        
        cell.imgAlbum.sd_setImage(with: URL(string: strImgeUrl!), placeholderImage: UIImage(named: "default album"))
        
        cell.btnMenu.tag = indexPath.row

        cell.btnMenu.addTarget(self, action: #selector(btnTableMenu(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MusicPlayerVC") as! MusicPlayerVC
        controller.isForLocalPlayList = true
        controller.mode = "offline"
          controller.arrAlbumData = ArrSong as! [[String : AnyObject]]
        if CADownloadManager.shared.arrFileInfo!.count > 0 {
            if indexPath.section == 1 {
                if CAMusicViewController.sharedInstance().playbackState == .playing{
                    CAMusicViewController.sharedInstance().pause()
                }
                CAMusicViewController.sharedInstance().add(self)
                CAMusicViewController.sharedInstance().playerType = .local
                CAMusicViewController.sharedInstance().setQueueWithItemCollection(ArrSong)
                if CAMusicViewController.sharedInstance().shuffleMode {
                    let item = self.ArrSong[indexPath.row]
                    let index = (CAMusicViewController.sharedInstance().queue! as NSArray).index(of: item)
                    CAMusicViewController.sharedInstance().playItem(at: UInt(index))
                } else {
                    CAMusicViewController.sharedInstance().playItem(at: UInt(indexPath.row))
                }
                
                let dic = ArrSong[indexPath.row] as! [String:Any]
              
                controller.strFROMTOP = "YES"
                controller.isFromMyMusic = true
//                controller.strGenreID = dic["albumName"] as? String ?? ""
                CAMusicViewController.sharedInstance().strAlbumID = dic["albumName"] as? String ?? ""
//                self.present(controller, animated: true, completion: nil)

                controller.genreData = ArrSong[indexPath.row] as! [String : Any]
              
                controller.arrAlbumData = ArrSong as! [[String : AnyObject]]
                
            }
        } else {
            CAMusicViewController.sharedInstance().add(self)
            if CAMusicViewController.sharedInstance().playbackState == .playing{
                CAMusicViewController.sharedInstance().pause()
            }
            CAMusicViewController.sharedInstance().playerType = .local
            CAMusicViewController.sharedInstance().setQueueWithItemCollection(ArrSong)
       
            if CAMusicViewController.sharedInstance().shuffleMode {
                let item = self.ArrSong[indexPath.row]
                let index = (CAMusicViewController.sharedInstance().queue! as NSArray).index(of: item)
                CAMusicViewController.sharedInstance().playItem(at: UInt(index))
            } else {
                CAMusicViewController.sharedInstance().playItem(at: UInt(indexPath.row))
            }
            
            let dic = ArrSong[indexPath.row] as! [String:Any]
            let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "MusicPlayerVC") as! MusicPlayerVC
            controller.strFROMTOP = "YES"
            controller.isFromMyMusic = true
//            controller.strGenreID = dic["albumName"] as? String ?? ""
            CAMusicViewController.sharedInstance().strAlbumID = dic["albumName"] as? String ?? ""
//            self.present(controller, animated: true, completion: nil)
            
            controller.genreData = ArrSong[indexPath.row] as! [String:Any]
            controller.intValue = indexPath.row
            
            
          
        }
          self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return NSLocalizedString("", comment: "")
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = Constant.ColorConstant.lightPink
        let header = view as! UITableViewHeaderFooterView
        header.frame = CGRect(x: 0, y: 0, width: tblMusicList.frame.size.width, height: 40)
        header.textLabel?.textColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: NSLocalizedString("Remove", comment: "")) { (action, indexPath) in
            if !(self.ArrSong.count > indexPath.row){return}
            let dictData = self.ArrSong[indexPath.row]
            let intMsgID = (dictData as! [String:Any])["id"]
            
            // create the alert
            let alert = UIAlertController(title: "", message: NSLocalizedString("Are_you_sure_you_want_to_delete_this_music?", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.default, handler: { action in
                let query = NSString(format: "delete from audio where id=\"%@\"", intMsgID as! String)
                DataBase.sharedInstance().performTask(withQuery: query as String)
                
                let getQuery = "SELECT * from audio ORDER BY created DESC"
                self.ArrSong = DataBase.sharedInstance().getDataFor(getQuery)
                self.tblMusicList.reloadData()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        }
        
        delete.backgroundColor = .red
        return [delete]
    }
    

    
    @objc func btnTableMenu(_ sender: UIButton) {
        self.addChildViewController(popUpVC)
        popUpVC.view.frame = self.view.frame
        popUpVC.mode = "offline"
        popUpVC.isForLocalPlayList = true
        popUpVC.trackData = ArrSong[sender.tag] as! [String : Any]
        self.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParentViewController: self)
    }

    //MARK:- Button Actions
    
    @IBAction func btnFilter(_ sender: Any) {
        self.displayAlertMessage(messageToDisplay: NSLocalizedString("Under_Development", comment: ""))
    }
    
    @IBAction func btnSearch(_ sender: Any) {
        viewSearch.isHidden = false
        //heightView.constant = 50
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
                
                if let imageURL = mediaitem["image_url"] as? String{
                    self.imgAlbum.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "default album"))
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
    
    
    //MARK:- CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        
        return ArrFavourites.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Favourites_CLVCell", for: indexPath) as! Favourites_CLVCell
        
        cell.lbl_Name.text = ArrFavourites[indexPath.row] as? String
        
        if Str_Song == "YES"{
            
            if indexPath.row == 0
            {
                //                cell.lbl_Name.textColor = Constant.ColorConstant.VioletColor
                cell.lbl_UnderLine.backgroundColor = Constant.ColorConstant.lightPink
            }
            else
            {
                //                cell.lbl_Name.textColor = Constant.ColorConstant.VioletColor
                cell.lbl_UnderLine.backgroundColor = UIColor.clear
            }
            
        }
        
        if Str_Playlist == "YES"{
            
            if indexPath.row == 1
            {
                //                cell.lbl_Name.textColor = Constant.ColorConstant.VioletColor
                cell.lbl_UnderLine.backgroundColor = Constant.ColorConstant.lightPink
            }
            else
            {
                //                cell.lbl_Name.textColor = Constant.ColorConstant.VioletColor
                cell.lbl_UnderLine.backgroundColor = UIColor.clear
            }
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         if indexPath.row == 0 {
            Str_Song = "YES"
            Str_Playlist = "NO"
            containerView.isHidden = true
            CollectionView_Header.reloadData()
        }
        if indexPath.row == 1 {
            Str_Song = "NO"
            Str_Playlist = "YES"
           containerView.isHidden = false
            NotificationCenter.default.post(name: Notification.Name("reloadPlaylist"), object: nil)
            CollectionView_Header.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: ((self.CollectionView_Header.frame.size.width - 170)/2)-5 , height: 55)
    }
}
