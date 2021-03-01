//
//  HomeVC.swift
//  CA7S
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD
import ImageSlideshow
import ObjectMapper
import TTGTagCollectionView


class HomeVC: BaseMusicViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, popupDelegate, UITabBarControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ImageSlideshowDelegate {
    
    @IBOutlet weak var vwTrending: UIView!
    @IBOutlet weak var CV_Trending: UICollectionView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var heightGenreCollection: NSLayoutConstraint!
    @IBOutlet weak var CV_Genre: UICollectionView!
    @IBOutlet weak var CV_MostLikely: UICollectionView!
    
    @IBOutlet weak var lblNotificationCount: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTop: UILabel!
    @IBOutlet weak var lblGenre: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var objScrollView: UIScrollView!
    @IBOutlet weak var viewBorder: UIView!
    @IBOutlet var tblDiscover: UITableView!
    
  
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var slideShow: ImageSlideshow!
   
    
   
   
    var ArrTopSongTitle = NSMutableArray()
    var ArrImgTopSong = NSMutableArray()
    var ArrGenreSongTitle = NSMutableArray()
    var ArrImgGenreSong = NSMutableArray()
    
    var arrDataTop = [[String:AnyObject]]()
    var arrDataGenre = [[String:AnyObject]]()
    var arrDataMostLikely = [[String:AnyObject]]()
    var arrTrending = [[String:AnyObject]]()
    var arrNewReleases = [[String:AnyObject]]()
    var bannerDat: [BannerData] = []
    var hasToShowMore = false
    
    var arrTopLeftTitle = ["Top CA7s", "New Releases", "Rising Stars"]
   
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(HomeVC.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.init(red: 143.0/255.0, green: 0/255.0, blue: 107.0/255.0, alpha: 1)
        
        return refreshControl
    }()
    var currentIndex = 0
    var indexTrendingSelected = 5
    var currentImageSliderPosition = 0
   
    override func viewDidLoad() {
        super.viewDidLoad()
        slideShow.contentScaleMode = .scaleToFill
        slideShow.slideshowInterval = 5.0
        slideShow.delegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HomeVC.didTap))
        slideShow.addGestureRecognizer(gestureRecognizer)
       // tblDiscover.tableHeaderView = vwTrending
        viewBorder.layer.cornerRadius = 25
        viewBorder.layer.masksToBounds = true
        viewBorder.layer.borderColor = UIColor.init(red: 171.0/255.0, green: 0, blue: 147.0/255.0, alpha: 1).cgColor
        viewBorder.layer.borderWidth = 1.0
        imgAlbum.layer.cornerRadius = 10
        imgAlbum.layer.masksToBounds = true
        lblNotificationCount.layer.cornerRadius = lblNotificationCount.frame.size.width/2
        lblNotificationCount.layer.masksToBounds = true
        btnMenu.addTarget(self, action:#selector(SSASideMenu.presentLeftMenuViewController), for: .touchUpInside)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.objScrollView.addSubview(self.refreshControl)
        self.pageControl.hidesForSinglePage = true
        self.tabBarController?.delegate = self
        let cellNib = UINib(nibName: "DiscoverTVCell", bundle: nil)
        tblDiscover.register(cellNib, forCellReuseIdentifier: "discoverTVCell")
        self.CV_Trending!.register(UINib(nibName: "DiscoverTrandingCVCell", bundle: nil), forCellWithReuseIdentifier: "discoverTrandingCVCell")
       
        searchTextField.delegate = self
       searchTextField.placeholder = NSLocalizedString("Search song or Artist", comment: "")
        
    }
    
    
  
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setLocalizationString()
        
        print("Activated:- \(UserDefaults.standard.bool(forKey: Constant.appConstants.IS_ACTIVATED))")
        
        GetMostLikelyListAPI()
        TopMusicAPI()
        GetGenreListAPI()
        getTrendingList()
        DispatchQueue.main.async {
            self.SidebarAPI()
        }
        
       
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.timer?.invalidate()
        
        self.timer = nil
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        timerPlayer?.invalidate()
        CAMusicViewController.sharedInstance().remove(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    private lazy var Sidebar: SidebarVC =
    {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var Controller = storyboard.instantiateViewController(withIdentifier: "SidebarVC") as! SidebarVC
        //Controller.Nav = self.navigationController
        
        return Controller
    }()
    
    
    func setLocalizationString(){
       
        self.lblTitle.text = NSLocalizedString("Discover", comment: "")
        //        self.lblInternational.text = NSLocalizedString("International", comment: "")
        self.lblTop.text = NSLocalizedString("Top", comment: "")
        self.lblGenre.text = NSLocalizedString("Genre", comment: "")
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        TopMusicAPI()
        GetGenreListAPI()
        DispatchQueue.main.async {
            self.SidebarAPI()
        }
        
        refreshControl.endRefreshing()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController == tabBarController.viewControllers?[3] {
            
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            if strUID == nil {
                
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
    
    //MARK:- set trending text
    
    
    
    
    //MARK:- CollectionView Delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == CV_MostLikely {
            return arrDataMostLikely.count
        }
        else if collectionView == CV_Trending {
            
            return arrTrending.count
        }
        else{
            return arrDataGenre.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == CV_MostLikely {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Home_MostLikely_CLVCell", for: indexPath) as! Home_MostLikely_CLVCell
            
            var dictData = arrDataMostLikely[indexPath.row]
            
            cell.lblTopSongTitle.text = dictData["type"] as? String
            cell.imgTopSong.image = UIImage.init(named: "")
            let strImageUrl = dictData["image_url"] as? String
            
            print(strImageUrl)
            
            cell.imgTopSong.sd_setShowActivityIndicatorView(true)
            cell.imgTopSong.sd_setIndicatorStyle(.gray)
            
            cell.imgTopSong.sd_setImage(with: URL(string: strImageUrl ?? ""), placeholderImage: UIImage(named: ""))
            
            return cell
            
        }
        else if collectionView == CV_Trending {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "discoverTrandingCVCell", for: indexPath) as! DiscoverTrandingCVCell
            
            cell.layer.cornerRadius = 8
            cell.layer.masksToBounds = true
            cell.layer.borderColor = UIColor(hexString: "#C845B4").cgColor
            cell.layer.borderWidth = 1.0
            
            cell.lblTitle.text = (arrTrending[indexPath.row]["song_title"] as? String)
            cell.lblTitle.textColor = UIColor(hexString: "#C845B4")
            
            cell.backgroundColor = UIColor.white
            
            cell.lblTitle.textColor = UIColor.init(red: 249.0/255, green: 102.0/255, blue: 196.0/255, alpha: 1)
            
            if indexPath.row == indexTrendingSelected {
                
                cell.lblTitle.textColor = UIColor.white
                
                cell.backgroundColor = UIColor.init(red: 200.0/255, green: 69.0/255, blue: 180.0/255, alpha: 1)
            }
            
            return cell
        }
            
        else{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Home_Genre_CLVCell", for: indexPath) as! Home_Genre_CLVCell
            
            heightGenreCollection.constant = CV_Genre.contentSize.height
            
            var dictData = arrDataGenre[indexPath.row]
            
            cell.lblGenreSongTitle.text = dictData["type"]?.description
            let strImgeUrl = dictData["image_icon"]?.description
            
            
            cell.imgGenreSong.sd_setShowActivityIndicatorView(true)
            cell.imgGenreSong.sd_setIndicatorStyle(.gray)
            
            
            return cell
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == CV_Genre {
            
            UserDefaults.standard.set(false, forKey: Constant.USERDEFAULTS.IS_FROM_INTERNATIONAL)
            UserDefaults.standard.synchronize()
            
            var dictData = arrDataGenre[indexPath.row]
            
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "GenreViewController") as! GenreViewController
            vc.strGenreID =  (dictData["id"]?.description)!
            vc.strGenreName =  (dictData["type"]?.description)!
            vc.strGenreIsFrom = NSLocalizedString("Genre", comment: "")
            vc.strIsFromTop = "NO"
            vc.strHeaderGenre = NSLocalizedString("Genre", comment: "")
            
            navigationController?.pushViewController(vc, animated: true)
        }else if collectionView == CV_MostLikely {
            
            UserDefaults.standard.set(false, forKey: Constant.USERDEFAULTS.IS_FROM_INTERNATIONAL)
            UserDefaults.standard.synchronize()
            
            var dictData = arrDataMostLikely[indexPath.row]
            
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "GenreViewController") as! GenreViewController
            vc.strGenreID =  (dictData["type"]?.description)!
            vc.strGenreName =  (dictData["album_name"]?.description)!
            //            vc.strArtistName =  (dictData["artist_name"]?.description)!
            vc.strGenreIsFrom = "MostLikely"
            vc.strIsFromTop = "NO"
            vc.strHeaderGenre = "Top Ca7s"
            navigationController?.pushViewController(vc, animated: true)
            
            //            self.displayAlertMessage(messageToDisplay: "Under Development")
        }
        else if collectionView == CV_Trending {
            
            indexTrendingSelected = indexPath.row
            self.searchTextField.text = self.arrTrending[indexTrendingSelected]["song_title"] as! String
            CV_Trending.reloadData()
        }
        else{
            
            var dictData = arrDataTop[indexPath.item]
            
            let url = dictData["image_url"]?.description
            
            //            print(url)
            
            if url != nil || url != ""{
                UIApplication.shared.openURL(URL(string: url!)!)
            }
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == CV_MostLikely {
            print("CV_MostLikely Size is :::::: \(CGSize(width: self.CV_Genre.layer.frame.size.width / 2.1, height: 117))")
            
            return CGSize(width: self.CV_Genre.layer.frame.size.width / 2.1, height: 117)
        }
        else if collectionView == CV_Trending {
            
            let label = UILabel(frame: CGRect.zero)
            
            label.text = arrTrending[indexPath.item]["song_title"] as! String
            
            label.sizeToFit()
            
            if UIScreen.main.bounds.size.height > 736 {
                
                return CGSize(width: label.frame.width + 30, height: 25)
            }
            
            return CGSize(width: label.frame.width + 20, height: 25)
        }
        else{
            return CGSize(width: self.CV_Genre.layer.frame.size.width / 3.2, height: 117)
        }
    }
    
    
    func cancelPressed(isCancled: Bool) {
        if !isCancled {
            
        }
        self.dismissPopupViewControllerWithanimationType(MJPopupViewAnimationFade)
    }
    
    
    //MARK:- Table Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 3
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let c = tableView.dequeueReusableCell(withIdentifier: "trending", for: indexPath) as? TrendingCellTableViewCell
            c?.arrTrending = self.arrTrending
            c?.hasToShowMore = self.hasToShowMore
            c?.setTrendingText()
            c?.onSelectText = { item in
                    self.searchTextField.text = item
            }
            c?.onSelectMore = { item in
                self.hasToShowMore = item
                tableView.reloadSections([0], with: .automatic)
            }
            return c!
            
        }
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "discoverTVCell") as? DiscoverTVCell
        
        cell?.selectionStyle = .none
        
        cell?.lblLeftTitle.text = NSLocalizedString(arrTopLeftTitle[indexPath.row], comment: "")
        
        cell?.btnBrowseAll.isHidden = false
        
        cell?.btnBrowseAll.addTarget(self, action: #selector(btnBrowseAllAction(_:)), for: .touchUpInside)
        
        cell?.btnBrowseAll.tag = indexPath.row
        cell?.btnBrowseAll.setTitle(NSLocalizedString("Browse all", comment: ""), for: .normal)
        
        cell?.setData(index: indexPath.row, topCA7s: self.arrDataTop, arrRisingStar: self.arrDataMostLikely, arrNewRelease: self.arrNewReleases)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            // if found height 
            if self.arrTrending.isEmpty {return 0}
            return self.hasToShowMore ? (CGFloat((Double(self.arrTrending.count) / 2.25) * 60)) : 180
          
        }
        return 150
    }
    
    @objc func btnBrowseAllAction(_ sender: UIButton) {
         let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
         let vc = storyboard.instantiateViewController(withIdentifier: "HomeAlbumVC") as! HomeAlbumVC
        var arrData = [[String:AnyObject]]()
        
        if sender.tag == 0 {
            vc.header = NSLocalizedString("Top CA7s", comment: "") 
            arrData = arrDataTop
            vc.selectionType = .topAfterZero
        }
        else if sender.tag == 1 {
            vc.header = NSLocalizedString("New Releases", comment: "")
            arrData = arrNewReleases
            vc.selectionType = .newReleaseAfterZero
        }
        else if sender.tag == 2 {
            vc.header = NSLocalizedString("Rising Stars", comment: "")
            arrData = arrDataMostLikely
            vc.selectionType = .risingStarAfterZero
        }
        
        vc.arrData = arrData
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
 
    
    @IBAction func btnNotification(_ sender: Any) {
        self.lblNotificationCount.isHidden = true
        self.lblNotificationCount.text = ""
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        vc.isFrom = "HOME"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func btnSubmitPressed()  {
        
    }
    
    
  
    //MARK:- API Calling
    
    func TopMusicAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
          
            
            var parameters: Parameters = ["page": "1"]
            
            if let strUID = UserDefaults.standard.string(forKey: Constant.USERDEFAULTS.USER_ID)  {
                parameters["user_id"] = strUID
            }
            
            Alamofire.request(Constant.APIs.TOP_MUSIC_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                print(response)
                
                if let data = response.result.value {
                    
                    print(response)
                    
                    if data["status"] == "success" {
                        
                        if let data = response.data {
                            if let jsonSting = String(data: data, encoding: .utf8) {
                                if let data = Mapper<BaseResponseList<BannerData>>().map(JSONString: jsonSting) {
                                    self.bannerDat = data.data
                                    var inputs: [InputSource] = []
                                    for i in data.data {
                                        inputs.append(AlamofireSource(urlString: i.imageIcon)!)
                                    }
                                    self.slideShow.setImageInputs(inputs)
                                }
                               
                                
                            }
                            
                        }
                        
                    }
                    else{
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
    
    
    
    func GetMostLikelyListAPI() {
        if Connectivity.isConnectedToInternet() {
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            var param: Parameters = [:]
            if strUID != nil{
                param = ["user_id" : "\(strUID!)"]
            }else{
                let local = NSLocale.current.languageCode!
                var lang = "1"
                if (UserDefaults.standard.string(forKey: Constant.AppLanguage)) == "Portugese" {
                    lang = "0"
                }
                else if (UserDefaults.standard.string(forKey: Constant.AppLanguage)) == "English" {
                    lang = "1"
                }else{
                    if local == "pt"{
                        
                        lang = "0"
                        
                    }else{
                        
                        lang = "0"
                    }
                    
                }
                param = [
                    "language" : lang
                ]
            }
            Alamofire.request(Constant.APIs.GET_TOP_CA7S_API, method: .get, parameters: param , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                        if let arrSearchResponse =  data["data"].arrayObject{
                            
                            print("arrSearchResponse*********** \n \n \n \(arrSearchResponse) \n \n \n *************")
                            
                            
                            if self.arrDataTop.count == 0 {
                                self.arrDataTop = arrSearchResponse as! [[String:AnyObject]]
                                self.CV_MostLikely.reloadData()
                            } else {
                                self.CV_MostLikely.reloadData()
                                
                            }
                            self.GetNewAlbumListAPI()
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
    
    func GetNewAlbumListAPI() {
        if Connectivity.isConnectedToInternet() {
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            var param: Parameters = [:]
            if strUID != nil{
                param = ["user_id" : "\(strUID!)"]
            }else{
                let local = NSLocale.current.languageCode!
                var lang = "1"
                if (UserDefaults.standard.string(forKey: Constant.AppLanguage)) == "Portugese" {
                    lang = "0"
                }
                else if (UserDefaults.standard.string(forKey: Constant.AppLanguage)) == "English" {
                    lang = "1"
                }else{
                    if local == "pt"{
                        
                        lang = "0"
                        
                    }else{
                        
                        lang = "0"
                    }
                    
                }
                param = [
                    "language" : lang
                ]
            }
            Alamofire.request(Constant.APIs.GET_NEW_RELEASE_API, method: .get, parameters: param , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                        if let arrSearchResponse =  data["data"].arrayObject{
                            
                            print("arrSearchResponse*********** \n \n \n \(arrSearchResponse) \n \n \n *************")
                            
                            
                            if self.arrNewReleases.count == 0 {
                                self.arrNewReleases = arrSearchResponse as! [[String:AnyObject]]
                                self.CV_Genre.reloadData()
                            } else {
                                self.CV_Genre.reloadData()
                            }
                            self.GetRisingStarListAPI()
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
    
    func GetRisingStarListAPI() {
        if Connectivity.isConnectedToInternet() {
            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            var param: Parameters = [:]
            if strUID != nil{
                param = ["user_id" : "\(strUID!)"]
            }else{
                let local = NSLocale.current.languageCode!
                var lang = "1"
                if (UserDefaults.standard.string(forKey: Constant.AppLanguage)) == "Portugese" {
                    lang = "0"
                }
                else if (UserDefaults.standard.string(forKey: Constant.AppLanguage)) == "English" {
                    lang = "1"
                }else{
                    if local == "pt"{
                        
                        lang = "0"
                        
                    }else{
                        
                        lang = "0"
                    }
                    
                }
                param = [
                    "language" : lang
                ]
            }
            Alamofire.request(Constant.APIs.GET_RISING_STAR, method: .get, parameters: param , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                        if let arrSearchResponse =  data["data"].arrayObject{
                            
                            print("arrSearchResponse*********** \n \n \n \(arrSearchResponse) \n \n \n *************")
                            
                            
                            if self.arrDataMostLikely.count == 0 {
                                self.arrDataMostLikely = arrSearchResponse as! [[String:AnyObject]]
                                self.CV_MostLikely.reloadData()
                            } else {
                                self.CV_MostLikely.reloadData()
                            }
                            self.tblDiscover.reloadData()
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
    
    
    func getTrendingList() {
        if Connectivity.isConnectedToInternet() {
            //SVProgressHUD.show()
            Alamofire.request(Constant.APIs.GET_TRENDING_API, method: .get, parameters: nil , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                SVProgressHUD.dismiss()
                if let data = response.result.value {
                    if data["status"] == "success" {
                        if let arrSearchResponse =  data["data"].arrayObject{
                            self.arrTrending = arrSearchResponse as! [[String:AnyObject]]
                           
                          
                            self.CV_Trending.reloadData()
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
    
   
    
    
    func GetGenreListAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            
            Alamofire.request(Constant.APIs.GET_HOME_GENRE_LIST_API, method: .get, parameters: nil , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                        if let arrSearchResponse =  data["data"].arrayObject{
                            
                            if self.arrDataGenre.count == 0 {
                                self.arrDataGenre = arrSearchResponse as! [[String:AnyObject]]
                                let dict = [String:AnyObject]()
                                self.arrDataGenre.insert(dict, at: 0)
                                self.CV_Genre.reloadData()
                                self.CV_Trending.dataSource = self
                                self.CV_Trending.delegate = self
                                self.CV_Trending.reloadData()
                                self.tblDiscover.dataSource = self
                                self.tblDiscover.delegate = self
                                self.tblDiscover.reloadData()
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
            })
        }else{
            self.displayAlertMessageWithTitle(title: Constant.APIs.InternetConnectionTitle, alertMessage: Constant.APIs.InternetConnectionMessage)
        }
    }
    
    //MARK:- Sidebar API Calling
    
    func SidebarAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //            SVProgressHUD.show()
            
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            var strDeviceToken = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.DEVICE_TOKEN)
            
            if strDeviceToken == nil{
                self.lblNotificationCount.isHidden = true
                strDeviceToken = ""
            }else{
                strDeviceToken = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.DEVICE_TOKEN) as! String
            }
            
            var parameters: Parameters = [:]
            
            if strUID != nil{
                
                parameters = [
                    
                    "user_id" : "\(strUID!)",
                    "user_token" : "\(strDeviceToken!)"
                ]
            }
            
            print("Para",parameters)
            
            
            Alamofire.request(Constant.APIs.SIDEBAR_API, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                //                SVProgressHUD.dismiss()
                
                print(response)
                
                if let data = response.result.value {
                    print(data)
                    if data["base_count"] == 0 {
                        self.lblNotificationCount.isHidden = true
                    }else{
                        self.lblNotificationCount.isHidden = false
                        
                        let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
                        
                        //        print(strUID)
                        
                        if strUID == nil{
                            
                        }else{
                            self.lblNotificationCount.text = "\(data["base_count"])"
                        }
                        
                    }
                    
                    if data["status"] == "success" {
                        
                        UserDefaults.standard.set(data["data"][0]["full_name"].description, forKey: Constant.USERDEFAULTS.FULL_NAME)
                        UserDefaults.standard.set(data["data"][0]["user_name"].description, forKey: Constant.USERDEFAULTS.USER_NAME)
                        UserDefaults.standard.set(data["data"][0]["user_city"].description, forKey: Constant.USERDEFAULTS.USER_CITY)
                        UserDefaults.standard.set(data["data"][0]["profile_picture"].description, forKey: Constant.USERDEFAULTS.PROFILE_PICTURE)
                        UserDefaults.standard.set(data["rate_us"].description, forKey: Constant.USERDEFAULTS.RATE_US_URL)
                        
                        UserDefaults.standard.synchronize()
                        
                        let defaults = UserDefaults.standard
                        if data["language"].stringValue == "English"{
                            defaults.set("English", forKey: Constant.AppLanguage)
                            defaults.synchronize()
                            L102Language.setAppleLAnguageTo(lang: "en")
                        }else{
                            defaults.set("Portuguese", forKey: Constant.AppLanguage)
                            defaults.synchronize()
                            L102Language.setAppleLAnguageTo(lang: "pt")
                        }
                        
                    }else{
                        
                        self.lblNotificationCount.isHidden = true
                    }
                }else{
                }
            })
        }else{
        }
    }
    
    @IBAction func tapOnsearchBar(_ sender: Any) {
            let storyBoard = UIStoryboard(name: "Dashboard", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "ManuallySearchVC") as! ManuallySearchVC
         vc.strSearchText = searchTextField.text!
        
        searchTextField.text! = ""
                self.navigationController?.pushViewController(vc, animated: true)
    
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    
    
    @IBAction func onSearch(_ sender: Any) {
        
        let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ManuallySearchVC") as! ManuallySearchVC
        controller.strSearchText = searchTextField.text!
        controller.isFromReconisation = true
        //        controller.nav = UINavigationController()
        //        self.present(controller, animated: true, completion: nil)
        self.navigationController?.pushViewController(controller, animated: true)
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
    
    
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
       self.currentImageSliderPosition = page
    }
    
    func didTap() {
        guard let url = URL(string: bannerDat[currentImageSliderPosition].image_url) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
           UIApplication.shared.openURL(url)
        }
    }
    
 
}


extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}


