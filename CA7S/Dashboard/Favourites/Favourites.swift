//
//  Favourites.swift
//  CA7S
//

import UIKit
import SVProgressHUD

class Favourites: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, MusicPlayerControllerDelegate {

    @IBOutlet weak var btnMenu: UIButton!

    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet var CollectionView_Header: UICollectionView!
    
    @IBOutlet var ContainerView: UIView!
    
    @IBOutlet weak var imgAlbum: UIImageView!
    @IBOutlet var viewPlayer:UIControl!
    @IBOutlet var playerSlider:UISlider!
    @IBOutlet var lblSongTitle: UILabel!
    @IBOutlet var lblAlbumName: UILabel!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var btnPrevious: UIButton!
    @IBOutlet var btnNext: UIButton!
    @IBOutlet weak var viewPlayerHeight: NSLayoutConstraint!
    
    var Str_Album = String()
    var Str_Song = String()
    var Str_Playlist = String()
    
    var ArrFavourites = NSMutableArray()
    
    var timer : Timer?
    var isPanning:Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnMenu.addTarget(self, action:#selector(SSASideMenu.presentLeftMenuViewController), for: .touchUpInside)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        imgAlbum.layer.cornerRadius = 10
        imgAlbum.layer.masksToBounds = true
        Str_Album = "YES"
        
        ArrFavourites.add(NSLocalizedString("Collections", comment: ""))
        ArrFavourites.add(NSLocalizedString("Songs", comment: ""))
        ArrFavourites.add(NSLocalizedString("Playlist", comment: ""))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setLocalizationString()
        
        CollectionView_Header.reloadData()
        let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
      
        if strUID == nil{
            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
//            //            present(vc, animated: true, completion: nil)
//            self.navigationController?.pushViewController(vc, animated: false)
            
        }else{
        
            Album.view.frame = ContainerView.bounds
            ContainerView.addSubview(Album.view)
        }
        
        if (CAMusicViewController.sharedInstance().playbackState == MPMusicPlaybackState.playing || CAMusicViewController.sharedInstance().playbackState == MPMusicPlaybackState.paused) {
          
            CAMusicViewController.sharedInstance().add(self)
           // containerViewBottom.isActive = true
            viewPlayer.isHidden = false
            viewPlayerHeight.constant = 80
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timedJob), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: .commonModes)
            
            /*playerSlider.maximumTrackTintColor = UIColor.init(red: 254.0/255, green: 142.0/255, blue: 211.0/255, alpha: 1)
            playerSlider.minimumTrackTintColor = UIColor.white*/
            
            playerSlider.setMaximumTrackImage(#imageLiteral(resourceName: "max_track"), for: .normal)
            playerSlider.setMinimumTrackImage(#imageLiteral(resourceName: "min_track").stretchableImage(withLeftCapWidth: 5, topCapHeight: 5), for: .normal)
          //playerSlider.setThumbImage(#imageLiteral(resourceName: "slider_thumb"), for: .normal)
            //playerSlider.setThumbImage(#imageLiteral(resourceName: "slider_thumb"), for: .highlighted)
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
            //containerViewBottom.isActive = false
            viewPlayer.isHidden = true
            viewPlayerHeight.constant = 0
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        CAMusicViewController.sharedInstance().remove(self)
    }
    
    func setLocalizationString(){
        //self.tabBarItem.title = NSLocalizedString("Favorites", comment: "")
        self.lblTitle.text = NSLocalizedString("Favourites", comment: "")
        ArrFavourites.removeAllObjects()
        ArrFavourites.add(NSLocalizedString("Collections", comment: ""))
        ArrFavourites.add(NSLocalizedString("Songs", comment: ""))
        ArrFavourites.add(NSLocalizedString("Playlist", comment: ""))
    }
    
    private lazy var Album: AlbumVC =
    {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle.main)
        var Controller = storyboard.instantiateViewController(withIdentifier: "AlbumVC") as! AlbumVC
        Controller.Nav = self.navigationController
        
        return Controller
    }()
    
    
    private lazy var Songs: SongsVC =
    {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle.main)
        var Controller = storyboard.instantiateViewController(withIdentifier: "SongsVC") as! SongsVC
        Controller.Nav = self.navigationController
        
        return Controller
    }()
    
    private lazy var Playlists: PlaylistsVC =
    {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle.main)
        var Controller = storyboard.instantiateViewController(withIdentifier: "PlaylistsVC") as! PlaylistsVC
        Controller.Nav = self.navigationController
        
        return Controller
    }()
    
    
    //MARK:- UIButton Action
    @IBAction func btnPlay(_ sender: Any){
        if CAMusicViewController.sharedInstance().playbackState == MPMusicPlaybackState.playing {
            CAMusicViewController.sharedInstance().pause()
            btnPlay.isSelected = false
        } else {
            CAMusicViewController.sharedInstance().play()
            btnPlay.isSelected = true
        }
    }
    
    @IBAction func btnNext(_ sender: Any){
        CAMusicViewController.sharedInstance().skipToNextItem()
    }
    
    @IBAction func btnPrevious(_ sender: Any){
        CAMusicViewController.sharedInstance().skipToPreviousItem()
    }
    
    @IBAction func btnOpenPlayer(_ sender: UIControl) {
        
        let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MusicPlayerVC") as! MusicPlayerVC
        controller.isFrom = GenreViewController()
        
        let trackData2  = UserDefaults.standard.object(forKey: "trackData")
        
        if trackData2 != nil{
            let trackData3 = NSKeyedUnarchiver.unarchiveObject(with: trackData2 as! Data) as? [String: Any]
            
            controller.genreData = trackData3!
            controller.arrAlbumData.append(trackData3 as! [String : AnyObject])
            controller.intValue = 0
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
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
        
        if Str_Album == "YES"{
            
            if indexPath.row == 0
            {
                //                cell.lbl_Name.textColor = Constant.ColorConstant.lightPink
                cell.lbl_UnderLine.backgroundColor = Constant.ColorConstant.lightPink//Constant.ColorConstant.whilte_a30
            }
            else
            {
                //                cell.lbl_Name.textColor = Constant.ColorConstant.VioletColor
                cell.lbl_UnderLine.backgroundColor = UIColor.clear
            }
            
        }
        
        if Str_Song == "YES"{
            
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
        
        if Str_Playlist == "YES"{
            
            if indexPath.row == 2 {
             
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        //        CollectionView_Header.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally , animated: true)
        
        
        if indexPath.row == 0
        {
            Str_Album = "YES"
            Str_Song = "NO"
            Str_Playlist = "NO"
            
            NotificationCenter.default.post(name: Notification.Name("reloadAlbumList"), object: nil)
            
            Album.view.frame = ContainerView.bounds
            ContainerView.addSubview(Album.view)
            CollectionView_Header.reloadData()
            Album.view.isHidden = false
            Songs.view.isHidden = true
            Playlists.view.isHidden = true
        }
        if indexPath.row == 1 {
            Str_Album = "NO"
            Str_Song = "YES"
            Str_Playlist = "NO"
            
            NotificationCenter.default.post(name: Notification.Name("reloadFavList"), object: nil)
            
            Songs.view.frame = ContainerView.bounds
            ContainerView.addSubview(Songs.view)
            CollectionView_Header.reloadData()
            Album.view.isHidden = true
            Songs.view.isHidden = false
            Playlists.view.isHidden = true
        }
        if indexPath.row == 2
        {
            Str_Album = "NO"
            Str_Song = "NO"
            Str_Playlist = "YES"
            
            NotificationCenter.default.post(name: Notification.Name("reloadPlaylist"), object: nil)
            
            Playlists.view.frame = ContainerView.bounds
            ContainerView.addSubview(Playlists.view)
            CollectionView_Header.reloadData()
            Album.view.isHidden = true
            Songs.view.isHidden = true
            Playlists.view.isHidden = false
           
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (self.CollectionView_Header.frame.size.width - 40)/3 , height: 55)
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

}
