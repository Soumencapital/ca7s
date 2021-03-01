//
//  AlbumVC.swift
//  CA7S
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD


class AlbumVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var Nav : UINavigationController!
    
    @IBOutlet weak var CV_Album: UICollectionView!
    @IBOutlet weak var lblNoDataFound: UILabel!
    
    var ArrAlbumTitle = NSMutableArray()
    var ArrImgAlbum = NSMutableArray()
    
    var arrData = [[String:AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//
//        let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
//
//        if strUID == nil{
//
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
////            present(vc, animated: true, completion: nil)
//            self.navigationController?.pushViewController(vc, animated: false)
//
//        }else{
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTable(notification:)), name: Notification.Name("reloadAlbumList"), object: nil)
        
        GetFavouriteAlbumAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setLocalizationString()
    }
    
    func setLocalizationString(){
        lblNoDataFound.text = NSLocalizedString("No_Data_Found", comment: "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reloadTable(notification: NSNotification) {
        GetFavouriteAlbumAPI()
    }
    
    
    //MARK:- CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Album_CLVCell", for: indexPath) as! Album_CLVCell
        
        cell.layer.cornerRadius = 15
        
        cell.layer.masksToBounds = true
        
        let dictData = arrData[indexPath.row]
        
        cell.lblAlbumTitle.text = dictData["type"]?.description
        let strImgeUrl = dictData["image_icon"] as? String
        
        cell.imgAlbum.sd_setShowActivityIndicatorView(true)
        cell.imgAlbum.sd_setIndicatorStyle(.gray)
        
        cell.imgAlbum.sd_setImage(with: URL(string: strImgeUrl!), placeholderImage: UIImage(named: "default album"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let dictData = arrData[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GenreViewController") as! GenreViewController
        vc.strGenreID = (dictData["genre_id"]?.description)!
        vc.strGenreName = (dictData["type"]?.description)!
        vc.strHeaderGenre = (dictData["type"]?.description)!
        vc.strGenreIsFrom = "Fav"
        Nav?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 100, height: 100)
    }
    
    //MARK:- API Calling
    
    func GetFavouriteAlbumAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            if strUID == nil {
                
                self.lblNoDataFound.isHidden = false
                
                return
            }
            
            //SVProgressHUD.show()
            
            let param : Parameters = [
                
                "user_id" : "\(strUID!)"
            ]
            
            Alamofire.request(Constant.APIs.GET_FAVOURITE_ALBUM_API, method: .post, parameters: param , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                        if let arrSearchResponse =  data["list"]["data"].arrayObject{
                            
                            if self.arrData.count == 0 {
                                self.arrData = arrSearchResponse as! [[String:AnyObject]]
                                self.CV_Album.reloadData()
                            } else {
                                
                            }
                            
                            if self.arrData.count == 0 {
                                self.lblNoDataFound.isHidden = false
                                self.setLocalizationString()
                            }else{
                                self.lblNoDataFound.isHidden = true
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
