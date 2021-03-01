//
//  UploadedMusicVC.swift
//  CA7S
//

import UIKit
import Alamofire
import SVProgressHUD
import Alamofire_SwiftyJSON
import PopoverKit

class UploadedMusicVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MusicPlayerControllerDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet var tblGenre:UITableView!
    @IBOutlet var lblGenreTitle:UILabel!
    
    @IBOutlet var btnAddMusic:UIButton!
    
    var arrGenre = NSMutableArray()
    
    var strCurrentPageIndex = Int()
    var strLastPageIndex = Int()
    
    
    
    
     //*********For music mini view*********///////
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
    
    
    
    private lazy var popUpVC: PopUpViewController =
    {
        let storyboard = UIStoryboard(name: "Profile", bundle: Bundle.main)
        var Controller = storyboard.instantiateViewController(withIdentifier: "PopUpViewController") as! PopUpViewController
        return Controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (UserDefaults.standard.bool(forKey: Constant.isUploadMusicFirstTime)) == false{
            
            let txtLabel = PureTitleModel(title: NSLocalizedString("Tap_here_to_add_music", comment: ""))
            let vc = PopoverTableViewController(items: [txtLabel])
            vc.pop.isNeedPopover = true
            vc.pop.popoverPresentationController?.sourceView = btnAddMusic
            vc.pop.popoverPresentationController?.sourceRect = btnAddMusic.bounds
            vc.pop.popoverPresentationController?.arrowDirection = .up
            //  vc.delegate = self
            present(vc, animated: true, completion: nil)
            
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: Constant.isUploadMusicFirstTime)
            defaults.synchronize()
        }
        
        GetUploadedMusicAPI(CurrentPage: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    /////////Mini Player functions///////
    func initViewForMiniPlayer() {
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
    @IBAction func btnPrevious(_ sender: Any) {
        CAMusicViewController.sharedInstance().skipToPreviousItem()
    }
    
    @IBAction func btnNext(_ sender: Any) {
        CAMusicViewController.sharedInstance().skipToNextItem()
    }
    
    ///////// End mini player functions////////
    override func viewDidAppear(_ animated: Bool) {
        lblTitle.text = NSLocalizedString("Uploaded_Music", comment: "")
        
        CAMusicViewController.sharedInstance().remove(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        GetUploadedMusicAPI(CurrentPage: 1)
        initViewForMiniPlayer()
    }
    
    //MARK: UITableView Methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrGenre.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UploadedMusic_TBLCell = tableView.dequeueReusableCell(withIdentifier: "UploadedMusic_TBLCell") as! UploadedMusic_TBLCell
        
        let dic = arrGenre[indexPath.row] as! [String:Any]
        cell.selectionStyle = .none
        cell.lblCount.text = "\(indexPath.row + 1)"
        cell.lblSongTitle.text = dic["title"] as? String
        cell.lblDescriptionTitle.text = "" //dic["album_name"] as? String
        cell.downloadCount.setTitle("\((dic["download_count"] as? Int) ?? 0)", for:  .normal)
        cell.listenCount.setTitle("\((dic["stream_count"] as? Int) ?? 0)", for:  .normal)
        let str = dic["image_url"] as? String
        
        
        cell.imgAlbum.sd_setShowActivityIndicatorView(true)
        cell.imgAlbum.sd_setIndicatorStyle(.gray)
        cell.onDelete = {
            let alert = UIAlertController(title: NSLocalizedString("Alert", comment: ""), message: NSLocalizedString("Are you sure you want to delete this song?", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (_) in
                 self.deleteUploadedMusicAPI(track_id: (dic["id"] as? Int) ?? 0, indexPath1: indexPath)
            })
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
           
        }
        cell.imgAlbum.sd_setImage(with: URL(string: str!), placeholderImage: UIImage(named: "placeholder.png"))
       //cell.btnOptions.isHidden = true
        //cell.btnOptions.addTarget(self, action: #selector(btnOptionsPressed(_:)), for: UIControlEvents.touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UserDefaults.standard.set(false, forKey: Constant.USERDEFAULTS.IS_FROM_INTERNATIONAL)
        UserDefaults.standard.synchronize()
        
        if CAMusicViewController.sharedInstance().playbackState == .playing{
            CAMusicViewController.sharedInstance().pause()
        }
        CAMusicViewController.sharedInstance().add(self)
        CAMusicViewController.sharedInstance().playerType = .remote
        CAMusicViewController.sharedInstance().setQueueWithItemCollection(arrGenre)
        if CAMusicViewController.sharedInstance().shuffleMode {
            let item = self.arrGenre[indexPath.row]
            let index = (CAMusicViewController.sharedInstance().queue! as NSArray).index(of: item)
            CAMusicViewController.sharedInstance().playItem(at: UInt(index))
        } else {
            CAMusicViewController.sharedInstance().playItem(at: UInt(indexPath.row))
        }
        
        
        let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MusicPlayerVC") as! MusicPlayerVC
        controller.isFromUploadMusic = true
        controller.isPresented = true
        controller.arrAlbumData = self.arrGenre as! [[String : AnyObject]]
        self.present(controller, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: NSLocalizedString("Remove", comment: "")) { (action, indexPath) in
            
            let dictData = self.arrGenre[indexPath.row]
            let intMsgID = (dictData as! [String:Any])["id"]
            
            // create the alert
            let alert = UIAlertController(title: "", message: NSLocalizedString("Are_you_sure_you_want_to_delete_this_music?", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.default, handler: { action in
                
                self.deleteUploadedMusicAPI(track_id: intMsgID as! Int, indexPath1: indexPath)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        }
        
        delete.backgroundColor = .red
        return [delete]
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if strCurrentPageIndex == strLastPageIndex{
            
            print("Page Complated")
            
        }else{
            if maximumOffset - currentOffset <= 10.0 {
                var NewPageNo = strCurrentPageIndex
                NewPageNo = NewPageNo + 1
                
                GetUploadedMusicAPI(CurrentPage: NewPageNo)
            }
        }
    }
    
    //MARK:-
    //MARK:- API call
    
    func deleteUploadedMusicAPI(track_id: Int, indexPath1: IndexPath) {
        
        if Connectivity.isConnectedToInternet() {
      
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let parameters: Parameters = [
                
                "user_id" : "\(strUID!)",
                "track_id" : track_id
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.DELETE_UPLOADED_MUSIC, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
 
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
 
                        self.arrGenre.removeObject(at: indexPath1.row)
                        self.tblGenre.deleteRows(at: [indexPath1], with: .automatic)
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
    
    //MARK:-
    //MARK: Button Actions
    
    @IBAction func btnBackPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddMusic(_ sender: UIButton) {
          self.PushToController(StroyboardName: "Dashboard", "AddMusic_LyricsVC")
    }
    
    func btnOptionsPressed(_ sender: Any) {
        self.addChildViewController(popUpVC)
        popUpVC.trackData = arrGenre[(sender as! UIButton).tag] as? [String:Any]
        popUpVC.view.frame = self.view.frame
        self.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParentViewController: self)
    }
    
    func GetUploadedMusicAPI(CurrentPage: Int) {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let parameters: Parameters = [
                
                "user_id" : "\(strUID!)",
                "page" : CurrentPage,
            ]
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.UPLOADED_MUSIC, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                        if CurrentPage == 1{
                                self.arrGenre.removeAllObjects()
                        }
                        
                        if let arrSearchResponse =  data["list"]["data"].arrayObject{
                            
                            self.strCurrentPageIndex = data["list"]["current_page"].intValue
                            self.strLastPageIndex = data["list"]["total"].intValue
                            
                            self.arrGenre.addObjects(from: arrSearchResponse)
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
}
