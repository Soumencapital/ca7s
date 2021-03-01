//
//  ManuallySearchVC.swift
//  CA7S
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD


class ManuallySearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MusicPlayerControllerDelegate, UISearchBarDelegate {

    @IBOutlet var tblGenre:UITableView!
    @IBOutlet weak var lblSearchTitle: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var strCurrentPageIndex: Int = 1
    var strLastPageIndex = Int()
    
    var strSearchText = ""
    var isFromReconisation = false
    var arrData = NSMutableArray()
    var arrResponsePaginationData = NSMutableArray()
    var searchKeyWords: [String] = []
    
    
    var isDownload: Bool = true
    
    /*******for music player*************/
    
     @IBOutlet weak var imgAlbum: UIImageView!
     @IBOutlet var viewPlayer:UIControl!
     @IBOutlet var playerSlider:UISlider!
     @IBOutlet var lblSongTitle: UILabel!
     @IBOutlet var lblAlbumName: UILabel!
     @IBOutlet var btnPlay: UIButton!
     @IBOutlet var btnPrevious: UIButton!
     @IBOutlet var btnNext: UIButton!
     @IBOutlet weak var viewPlayerHeight: NSLayoutConstraint!
     var isPanning:Bool = false
     var timer : Timer?
    
   
 
    
    
    
    
    private lazy var popUpVC: PopUpViewController =
    {
        let storyboard = UIStoryboard(name: "Profile", bundle: Bundle.main)
        var Controller = storyboard.instantiateViewController(withIdentifier: "PopUpViewController") as! PopUpViewController
        return Controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
searchBar.delegate = self
        
        //GetSearchListAPI(CurrentPage: 1)
        if isFromReconisation {
            self.searchBar.isHidden = true
             self.GetSearchListAPI(CurrentPage: 1)
            
            
        }else if strSearchText != "" {
            self.searchBar.isHidden = false
            self.searchBar.text = strSearchText
            self.GetSearchListAPI(CurrentPage: 1)
        }else{
            if let searchKeywords = UserDefaults.standard.string(forKey: Constant.USERDEFAULTS.SEARCH_HISTORY) {
                if searchKeywords != "" {
                    self.searchKeyWords = searchKeywords.components(separatedBy: ",")
                }
                
                
            }
        }
        playerSlider.setMaximumTrackImage(#imageLiteral(resourceName: "max_track"), for: .normal)
        playerSlider.setMinimumTrackImage(#imageLiteral(resourceName: "min_track").stretchableImage(withLeftCapWidth: 5, topCapHeight: 5), for: .normal)
      //playerSlider.setThumbImage(#imageLiteral(resourceName: "slider_thumb"), for: .normal)
        //playerSlider.setThumbImage(#imageLiteral(resourceName: "slider_thumb"), for: .highlighted)
        playerSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
       
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lblSearchTitle.text = NSLocalizedString("Search_Track_List", comment: "")
        if (CAMusicViewController.sharedInstance().playbackState == MPMusicPlaybackState.playing || CAMusicViewController.sharedInstance().playbackState == MPMusicPlaybackState.paused) {
          
            CAMusicViewController.sharedInstance().add(self)
          
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
                }else  if let image = mediaitem["artwork_url"] as? String {
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UITableView Methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 40
        }
        return 70
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 1) ? searchKeyWords.count : arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if  indexPath.section == 1 {
            let cell:Search_History_TBLCell = tableView.dequeueReusableCell(withIdentifier: "Search_History_TBLCell") as! Search_History_TBLCell
            cell.lblSongTitle.text = self.searchKeyWords[indexPath.row]
            cell.tapOnRemove = {
                self.searchKeyWords.remove(at: indexPath.row)
                tableView.reloadSections([1], with: .bottom)
              self.updateSearchResult()
            }
            return cell
        }
        
        
        
        let cell:ManuallySearch_TBLCell = tableView.dequeueReusableCell(withIdentifier: "ManuallySearch_TBLCell") as! ManuallySearch_TBLCell
        cell.selectionStyle = .none
//        cell.lblCount.text = "\(indexPath.row + 1)"
        cell.btnOptions.tag = indexPath.row
       
        
        
        let dictData = arrData[indexPath.row]
        
//        cell.lblSongTitle.text = (dictData as! [String:Any])["title"] as? String
//        cell.lblGenreTitle.text = ((dictData as! [String:Any])["user"] as! [String:Any])["name"] as? String
        
        let audioID = (dictData as! [String:Any])["id"] as? String
        cell.lblSongTitle.text = (dictData as! [String:Any])["title"] as? String
        if let val = (dictData as! [String:Any])["user"] as? String{
            cell.lblGenreTitle.text = ((dictData as! [String:Any])["user"] as! [String:Any])["name"] as? String
        }else{
            cell.lblGenreTitle.text = "Unknown"
        }
        
        cell.imgAlbum.sd_setShowActivityIndicatorView(true)
        cell.imgAlbum.sd_setIndicatorStyle(.gray)
        
        var strImgeUrl = ""
        if let imageUrl = (dictData as! [String:Any])["artwork_url"] as? String {
            strImgeUrl = imageUrl
        }
        
        if let imageUrl = (dictData as! [String:Any])["image_url"] as? String {
            strImgeUrl = imageUrl
        }
        let query = NSString(format: "SELECT * from audio where id = \"%@\"", audioID!)
        let ArrSong = DataBase.sharedInstance().getDataFor(query as String)
        
        if ArrSong!.count > 0 || (CADownloadManager.shared.arrIDs?.contains(audioID!))! {
             cell.btnOptions.isSelected = true
            cell.btnOptions.progress = 1.0
        }else{
            cell.btnOptions.isSelected = false
            cell.btnOptions.progress = 0
        }
        
        if(strImgeUrl != nil){
            cell.imgAlbum.sd_setImage(with: URL(string: strImgeUrl), placeholderImage: UIImage(named: "placeholder.png"))
        }else{
            
        }
        
      
        cell.btnOptions.addTarget(self, action: #selector(btnOptionsPressed(_:)), for: UIControlEvents.touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            self.searchBar.text = self.searchKeyWords[indexPath.row]
            self.strSearchText = self.searchBar.text!
            self.GetSearchListAPI(CurrentPage: 1)
            
            return
        }
        
        
      
        
        //        cell.lblSongTitle.text = (dictData as! [String:Any])["title"] as? String
        //        cell.lblGenreTitle.text = ((dictData as! [String:Any])["user"] as! [String:Any])["name"] as? String
      
      
       
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
         self.setTrendingat(strSongID as! String)
        if !self.searchKeyWords.contains(((dictData as! [String:Any])["title"] as? String)!) && !self.isFromReconisation{
            self.searchKeyWords.append(((dictData as! [String:Any])["title"] as? String)!)
        }
        
        self.updateSearchResult()
            let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "MusicPlayerVC") as! MusicPlayerVC
            controller.strSongID = "\(strSongID)"
            controller.strFROMTOP = "NO"
            controller.isFromSearch = true
            controller.isDownload = true//isDownload
        controller.arrAlbumData.append(dictData as! [String : AnyObject])
        
        if let genre_id: Int = (dictData as! [String:Any])["genre_id"] as? Int{
                controller.strGenreID = "\(genre_id)"
        }else{
            controller.strGenreID = ""
        }
        
        if let track_type: Int = (dictData as! [String:Any])["track_type"] as? Int{
            controller.strTrackTypeFromSearch = "\(track_type)"
        }else{
            controller.strTrackTypeFromSearch = ""
        }
        controller.intValue = indexPath.row
        
        controller.genreData = arrData[indexPath.row] as! [String : Any]
        
//
//            controller.strTrackType  =
//            self.present(controller, animated: true, completion: nil)
        
        self.navigationController?.pushViewController(controller, animated: true)
        
//        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
//        if strCurrentPageIndex == strLastPageIndex{
    
        if self.arrResponsePaginationData.count == 0 {
            print("Page Complated")
            
        }else{
            if indexPath.row == arrData.count-1{
                
                if strCurrentPageIndex <= 30{
                    strCurrentPageIndex = strCurrentPageIndex + 1
                    self.GetSearchListAPI(CurrentPage: strCurrentPageIndex)
                }
            }
        }
    }
    
    func updateSearchResult() {
        UserDefaults.standard.set(self.searchKeyWords.joined(separator: ","), forKey: Constant.USERDEFAULTS.SEARCH_HISTORY)
    }
    
    func btnOptionsPressed(_ sender: MyCircularProgressButton) {
        
        let item = arrData[sender.tag] as! [String: Any]
        let audioID =  "\(String(describing: item["id"] ?? ""))"
        //        let query = NSString(format: "SELECT * from audio where id = \"%@\"", audioID)
        //        let ArrSong = DataBase.sharedInstance().getDataFor(query as String)
        if sender.isSelected {
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
                
                if let str = item["lyrics"] as? String {
                    lyrics = str
                }
                
                
                //Updated By MANSI//
                
                if let strAlbum = item["album_name"] as? String{
                    CAMusicViewController.sharedInstance().strAlbumName = item["album_name"] as? String
                }else{
                    CAMusicViewController.sharedInstance().strAlbumName = ""
                }
                
                guard let downloadUrl = item["stream_url"] as? String else{
                    showEmptyMessage()
                    return
                }
                var source = downloadUrl
                if downloadUrl.contains("ca7s/storage") {
                   source = "https://www.ca7s.com" + downloadUrl
                }
               
             
          
                    
                    
                    fdi = FileDownloadInfo(title: (item["title"] as? String)!, downloadSource: source, downloadSource2: source, andFile: audioID, data: item , album:CAMusicViewController.sharedInstance().strAlbumName, lyrics:item["lyrics"] as? String ?? "", albumImageUrl: item["image_url"] as? String ?? "")
                    
                    CADownloadManager.shared.arrIDs?.append(audioID)
                    CADownloadManager.shared.arrFileInfo?.append(fdi!)
               
                
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
                sender.isSelected = true
            }
        }
    }
    
    func showEmptyMessage() {
        
        let alert = UIAlertController(title: NSLocalizedString("Alert", comment: ""), message: NSLocalizedString("Download link not found", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Button Action
    
    @IBAction func btnBack(_ sender:UIButton){
//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

    //MARK:- API Calling
    
    func GetSearchListAPI(CurrentPage: Int) {
        
        if Connectivity.isConnectedToInternet() {
            
           
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            var parameters: Parameters = [
                
                    "page" : CurrentPage,
                    "search_text" : strSearchText,
                    "per_page" : 10
                ]
                
            parameters["user_id"] = (strUID as? String) ?? "1"
            
        
            
            print("Para",parameters)
          
            Alamofire.request(Constant.APIs.SEARCH_MANUALLY_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                if let data = response.result.value {
                    if data["status"] == "success" {
                        if data["download_status"].boolValue{
                            self.isDownload = true
                        }else{
                            self.isDownload = false
                        }
                        
                        if let arrSearchResponse =  data["list"]["data"].arrayObject{
                            if CurrentPage == 1{
                                self.arrData.removeAllObjects()
                            }
                            
                            self.arrResponsePaginationData.removeAllObjects()
                            self.arrResponsePaginationData.addObjects(from: arrSearchResponse)
                                self.arrData.addObjects(from: arrSearchResponse)
                                self.tblGenre.reloadData()

                        }
                    }else{
                        
                      
                        //self.displayAlertMessage(messageToDisplay: NSLocalizedString("No_Data_Found", comment: ""))
                    }
                }else{
//                    self.displayAlertMessage(messageToDisplay: NSLocalizedString("Something_went_wrong", comment: ""))
                }
            })
        }else{
            self.displayAlertMessageWithTitle(title: Constant.APIs.InternetConnectionTitle, alertMessage: Constant.APIs.InternetConnectionMessage)
        }
    }
    
    
    func setTrendingat(_ id: String) {
        
        if Connectivity.isConnectedToInternet() {
            
            
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let parameters: Parameters = ["id": id]
            
          
            
            
            
            print("Para",parameters)
            
            Alamofire.request(Constant.APIs.SET_TRENDING, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                if let data = response.result.value {
                    
                        }
                    })
        }
    
    }
    
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        self.strSearchText = searchBar.text! + text
        self.GetSearchListAPI(CurrentPage: 1)
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
           self.view.endEditing(true)
    }
    
    
    
}
