//
//  Constant.swift
//  CA7S
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON


class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

enum PlayerType {
    case Local
    case Remote
}

class Constant: NSObject {
    
    static let AppLanguage: String = "AppLanguage"
    
    static let isUploadMusicFirstTime: String = "UploadedMusic"
    static let isTapToScanFirstTime: String = "Search"
    static let isUploadSongsStepsFirstTime1: String = "AddMusicSteps1"
    static let isUploadSongsStepsFirstTime2: String = "AddMusicSteps2"
    static let isUploadSongsStepsFirstTime3: String = "AddMusicSteps3"
    static let shownLyricsTutorial: String = "lyricsTutorial"
    static let isAwareAboutTheDownloading: String = "DownloadAware"
    static let isAwareAboutEconomicMode: String = "KnowAboutEconomicMode"
    
    
    struct DeviceInfo {
        let iOS_NAME    = UIDevice.current.systemName
        
        let iOS_VERSION = UIDevice.current.systemVersion
        
        let DEVICE_NAME     = UIDevice.current.name
        
        let DEVICE_MODEL    = UIDevice.current.model
        
        let IS_SIMULATOR    = (TARGET_IPHONE_SIMULATOR == 1)
        
        let IS_IPHONE       = UIDevice.current.model.range(of: "iPhone") != nil
        
        let IS_IPOD         = UIDevice.current.model.range(of: "iPod") != nil
        
        let IS_IPAD         = UIDevice.current.model.range(of: "iPad") != nil
        
        
        let IS_IPHONE_4     = UIDevice.current.model.range(of: "iPhone") != nil && UIScreen.main.bounds.size.height == 480
        let IS_IPHONE_5     = UIDevice.current.model.range(of: "iPhone") != nil && UIScreen.main.bounds.size.height == 568
        let IS_IPHONE_6     = UIDevice.current.model.range(of: "iPhone") != nil && UIScreen.main.bounds.size.height == 667
        let IS_IPHONE_6P    = UIDevice.current.model.range(of: "iPhone") != nil && UIScreen.main.bounds.size.height == 736
        
        let IS_IPHONE_7    = UIDevice.current.model.range(of: "iPhone") != nil && UIScreen.main.bounds.size.height == 1334
        let IS_IPHONE_7p    = UIDevice.current.model.range(of: "iPhone") != nil && UIScreen.main.bounds.size.height == 1334
        let IS_IPHONE_8    = UIDevice.current.model.range(of: "iPhone") != nil && UIScreen.main.bounds.size.height == 1334
        let IS_IPHONE_8p    = UIDevice.current.model.range(of: "iPhone") != nil && UIScreen.main.bounds.size.height == 1334
        let IS_IPHONE_X    = UIDevice.current.model.range(of: "iPhone") != nil && UIScreen.main.bounds.size.height == 2436
        let IS_IPHONE_SE    = UIDevice.current.model.range(of: "iPhone") != nil && UIScreen.main.bounds.size.height == 2436
        
        let IS_IPAD_MINI    = UIDevice.current.model.range(of: "iPad") != nil && UIScreen.main.bounds.size.height == 512
        let IS_IPAD_MINI2   = UIDevice.current.model.range(of: "iPad") != nil && UIScreen.main.bounds.size.height == 512
        let IS_IPAD_AIR     = UIDevice.current.model.range(of: "iPad") != nil && UIScreen.main.bounds.size.height == 1024
        let IS_IPAD_PRO     = UIDevice.current.model.range(of: "iPad") != nil && UIScreen.main.bounds.size.height == 1366
    }
    
    struct ColorConstant {
        static let lightPink: UIColor = UIColor(red: 226.0/255.0, green: 98.0/255.0, blue: 173.0/255.0, alpha: 1.0)
        static let darkPink: UIColor = UIColor(red: 198.0/255.0, green: 38.0/255.0, blue: 140.0/255.0, alpha: 1.0)
        static let placeHolderColor: UIColor = UIColor(red: 65.0/255.0, green: 67.0/255.0, blue: 68.0/255.0, alpha: 1.0)
        static let unSelectedIconColor: UIColor = UIColor(red: 157.0/255.0, green: 157.0/255.0, blue: 157.0/255.0, alpha: 1.0)
        static let whilte_a30: UIColor = UIColor.init(white: 1.0, alpha: 0.3)
    }
    
    struct appConstants {
        static let IS_LOGIN = "isLogin"
        static let IS_ACTIVATED = "is_updated"
        static let kPlaceholder = NSLocalizedString("Paste_lyrics_here", comment: "")
        static let kDownloadCompleteNotification = "DownloadCompleteNotification"
    }
    
    struct FontHelper {
        
        static func defaultRegularFontWithSize(size: CGFloat) -> UIFont {
            return UIFont.init(name: "segoe_regular", size: size)!
        }
        
        static func defaultSemiLightFontWithSize(size: CGFloat) -> UIFont {
            return UIFont.init(name: "segoe_light", size: size)!
        }
        
        static func defaultSemiBoldFontWithSize(size: CGFloat) -> UIFont {
            return UIFont.init(name: "SegoeUI-Semibold", size: size)!
        }
        
        static func defaultBoldFontWithSize(size: CGFloat) -> UIFont {
            return UIFont.init(name: "segue_bold", size: size)!
        }
    }
    
    
    struct USERDEFAULTS {
        static var DEVICE_TOKEN = "DEVICE_TOKEN"
        static var EMAIL_ID = "EMAIL_ID"
        static var FULL_NAME = "FULL_NAME"
        static var PROFILE_PICTURE = "PROFILE_PICTURE"
        static var DATE_OF_BIRTH = "DATE_OF_BIRTH"
        static var MOBILE_NUMBER = "MOBILE_NUMBER"
        static var USER_ID = "USER_ID"
        static var USER_CITY = "USER_CITY"
        static var USER_NAME = "USER_NAME"
        static var VIEWER_ID = "VIEWER_ID"
        static var GENRE_ID = "GENRE_ID"
        static var IS_FROM_INTERNATIONAL = "IS_FROM_INTERNATIONAL"
        static var RATE_US_URL = "RATE_US_URL"
        static var LOCAL_PLAYLIST = "LOCAL_PLAYLIST"
        static var SEARCH_HISTORY = "SEARCH_HISTORY"
        static let economicMode = "EconomicMode"
        static let showEconomicMode = "ShowEconomicmode"
    }
    
    struct APIs {
        
        //Base URL
        //static let BASE_API = "http://3.130.108.91/ca7s/public/api/"
        static let BASE_API = "https://www.ca7s.com/ca7s/api/"
        
        //Authentication Module
        static let LOGIN_API = Constant.APIs.BASE_API + "ws_login"
        static let FB_LOGIN_API = Constant.APIs.BASE_API + "ws_social_login"
        static let REGISTRATION_API = Constant.APIs.BASE_API + "ws_signup"
        static let USER_VERIFICATION_API = Constant.APIs.BASE_API + "ws_check_username"
        static let USEREMAIL_VERIFICATION_API = Constant.APIs.BASE_API + "ws_check_email"
        static let FORGOT_PASSWORD_API = Constant.APIs.BASE_API + "ws_reset_password"
        
        //Sidebar
        static let SIDEBAR_API = Constant.APIs.BASE_API + "ws_profile_sidebar"
        
        //Follow Process
        static let FOLLOWING_LIST_API = Constant.APIs.BASE_API + "ws_following_list"
        static let FOLLOWERS_LIST_API = Constant.APIs.BASE_API + "ws_followers_list"
        static let PENDING_REQUEST_LIST_API = Constant.APIs.BASE_API + "ws_request_list"
        static let ACCEPT_REQUEST_API = Constant.APIs.BASE_API + "ws_request_accept"
        static let REJECT_REQUEST_API = Constant.APIs.BASE_API + "ws_request_reject"
        static let FOLLOW_API = Constant.APIs.BASE_API + "ws_follow"
        static let UNFOLLOW_API = Constant.APIs.BASE_API + "ws_unfollow"
        static let REMOVE_FRIEND_API = Constant.APIs.BASE_API + "ws_friend_remove"
        
        //Search
        static let SEARCH_USER_API = Constant.APIs.BASE_API + "ws_search_user"
        static let SEARCH_RECOGNIZE_API = Constant.APIs.BASE_API + "ws_fileentry/track_identify"
        static let SEARCH_MANUALLY_API = Constant.APIs.BASE_API + "ws_search_international"
        static let SEARCH_HISTORY_API = Constant.APIs.BASE_API + "ws_get_history"
        static let CLEAR_SEARCH_HISTORY_API = Constant.APIs.BASE_API + "ws_clear_history_once"
        static let CLEAR_ALL_SEARCH_HISTORY_API = Constant.APIs.BASE_API + "ws_clear_history_all"
        static let SEARCCH_SONG_BY_KEYWORD = Constant.APIs.BASE_API + "song_search"
        static let SET_TRENDING = Constant.APIs.BASE_API + "trending"
        
        
        //Profile
        static let EDIT_PROFILE_API = Constant.APIs.BASE_API + "ws_profile_edit"
        static let GET_CITIES_API = Constant.APIs.BASE_API + "ws_get_cities"
        static let CHANGE_PROFILEPPICTURE_API = Constant.APIs.BASE_API + "ws_profile_change"
        static let GET_PROFILE_API = Constant.APIs.BASE_API + "ws_profile_get"
        static let VIEW_PROFILE_API = Constant.APIs.BASE_API + "ws_profile_view"
        
        //Dashboard
        static let TOP_MUSIC_API = Constant.APIs.BASE_API + "ws_music_listing_albums"
        static let TOP_LIST_API = Constant.APIs.BASE_API + "ws_music_listing_tracks"
        static let GET_GENRE_LIST_API = Constant.APIs.BASE_API + "ws_get_genres"
        static let GET_HOME_GENRE_LIST_API = Constant.APIs.BASE_API + "ws_get_available_genres"
        static let GET_RISING_STAR = Constant.APIs.BASE_API + "ws_rising_star_albums"
        static let GET_MOST_LIKELY_SONG_LIST_API = Constant.APIs.BASE_API + "ws_get_top_ca7s"
        static let GET_TOP_API = Constant.APIs.BASE_API + "ws_get_top"
        static let GET_FILENTRYGENRE_API = Constant.APIs.BASE_API + "ws_fileentry/get_list"
        static let GET_TRENDING_API = Constant.APIs.BASE_API + "get_trending"
        static let GET_NEW_RELEASE_API = Constant.APIs.BASE_API + "ws_new_release_albums"
        static let GET_TOP_CA7S_API = Constant.APIs.BASE_API + "ws_top_albums_mob"
        
        
        //Notification
        static let GET_NOTIFICATION_LIST_API = Constant.APIs.BASE_API + "ws_get_notification"
        static let DELETE_SINGLE_NOTIFICATION_API = Constant.APIs.BASE_API + "ws_notification_clear_ones"
        static let CLEAR_ALL_NOTIFICATION_API = Constant.APIs.BASE_API + "ws_notification_clear_all"
        
        //Favourite
        static let GET_FAVOURITE_LIST_API = Constant.APIs.BASE_API + "ws_get_favorite"
        static let GET_PLAYLIST_LIST_API = Constant.APIs.BASE_API + "ws_get_playlist"
        static let GET_FAVOURITE_ALBUM_API = Constant.APIs.BASE_API + "ws_get_favorite_album"
        static let GET_FAVOURITE_BY_ALBUM_API = Constant.APIs.BASE_API + "ws_get_favorite_by_album"
        
        //Add music
        static let ADD_MUSIC = Constant.APIs.BASE_API + "ws_fileentry/add"
        static let UPLOADED_MUSIC = Constant.APIs.BASE_API + "ws_fileentry_self/get_list"
        static let LIKE_TRACK = Constant.APIs.BASE_API + "ws_track_like"
        static let UNLIKE_TRACK = Constant.APIs.BASE_API + "ws_track_unlike"
        static let FAVORITE_TRACK = Constant.APIs.BASE_API + "ws_track_favorite"
        static let UNFAVORITE_TRACK = Constant.APIs.BASE_API + "ws_track_remove_favorite"
        static let ADD_PLAYLIST_TRACK = Constant.APIs.BASE_API + "ws_add_to_playlist"
        static let Get_SINGLE_Track = Constant.APIs.BASE_API + "ws_get_track"
        
        
        //Playlist
        enum PlayListUrl: String {
            case CREATE_PLAYLIST_API =   "ws_create_playlist"
            case UPDATE_PLAYLIST_API =   "ws_update_playlist"
            case GET_USER_PLAYLIST =  "ws_get_user_playlist"
            case ADD_SONG_IN_PLAYLIST_API =   "ws_add_song_playlist"
            case REMOVE_SONG_FROM_PLAYLIST_API =   "ws_remove_song_playlist"
            case REMOVE_PLAYLIST_API =    "ws_remove_playlist"
            case GET_SONG_FROM_PLAYLIST =   "ws_get_playlist_song"
        }
        
        enum DiscoverDeatilUrl: String {
            case topGenereAtZero = "ws_get_top"
            case topAfterZero = "ws_get_top_ca7s"
            case newReleaseAtZero = "new_release"
            case newReleaseAfterZero = "ws_new_release_by_albums"
            case risingStarAtZero = "rising_star"
            case risingStarAfterZero = "ws_rising_star_by_albums"
            case none = ""
        }
        
        
        //Share Music
        static let SHARE_MUSIC = Constant.APIs.BASE_API + "ws_make_share"
        
        //Delete uploaded music
        static let DELETE_UPLOADED_MUSIC = Constant.APIs.BASE_API + "ws_fileentry/soft_delete"
        
        //Settings
        static let GET_SETTINGS_STATUS = Constant.APIs.BASE_API + "ws_get_setting"
        static let CHANGE_PASSWORD = Constant.APIs.BASE_API + "ws_change_password"
        
        //Logout
        static let LOGOUT_API = Constant.APIs.BASE_API + "ws_logout"
        
        //Status Message
        static let InternetConnectionTitle = NSLocalizedString("No_internet_connection", comment: "")
        static let InternetConnectionMessage = NSLocalizedString("Try_again_later_when_there_is_a_better_internet_connection", comment: "")
        
    }
}


class txtPadding: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 35);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}

extension UIImage {
    convenience init?(url: URL?) {
        guard let url = url else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            self.init(data: data)
        } catch {
            print("Cannot load image from url: \(url) with error: \(error)")
            return nil
        }
    }
}

extension NSMutableAttributedString {
    
    public func setAsLink(textToFind:String, linkURL:String) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(NSLinkAttributeName, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
}
extension UIViewController {
    
    
    
    func setAttributedTextToTabbar(str: String) -> NSAttributedString {
        let myString = "Swift Attributed String"
        
        var myAttribute = [String : UIFont]()
        
        if UIDevice.current.model.range(of: "iPhone") != nil && UIScreen.main.bounds.size.height == 568{
            myAttribute = [ NSFontAttributeName: UIFont.systemFont(ofSize: 13.0) ]
        }else{
            myAttribute = [ NSFontAttributeName: UIFont.systemFont(ofSize: 16.0)]
        }
        
        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
        
        
        
        return myAttrString
    }
    
    func PushToController(StroyboardName : String,  _ StroyboardID:String) {
        let storyboard = UIStoryboard(name: StroyboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: StroyboardID)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func PushToViewProfileController(StroyboardName : String,  _ StroyboardID:String, isFromFollowers: Bool) {
        let storyboard = UIStoryboard(name: StroyboardName, bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "ViewProfileVC") as! ViewProfileVC
        myVC.isFromFollowers = isFromFollowers
        self.navigationController?.pushViewController(myVC, animated: true)
        
        
    }
    
    
    func displayAlertMessage(messageToDisplay: String){
        
        let alertController = UIAlertController(title:"", message: messageToDisplay, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
            if messageToDisplay == "re-login or try again."{
                CAMusicViewController.sharedInstance().stop()
                let defaults = UserDefaults.standard
                defaults.set(false, forKey: Constant.appConstants.IS_LOGIN)
                defaults.synchronize()
                self.sideMenuViewController?.panGestureEnabled = false
                let sb = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                let vc = sb.instantiateViewController(withIdentifier: "LoginVC")
                self.navigationController?.setViewControllers([vc], animated: false)
                //                self.PushToController(StroyboardName: "Main", "LoginVC")
            }
            
            if messageToDisplay == "login first"{
                CAMusicViewController.sharedInstance().stop()
                let defaults = UserDefaults.standard
                defaults.set(false, forKey: Constant.appConstants.IS_LOGIN)
                defaults.synchronize()
                self.sideMenuViewController?.panGestureEnabled = false
                let sb = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                let vc = sb.instantiateViewController(withIdentifier: "LoginVC")
                self.navigationController?.setViewControllers([vc], animated: false)
                //                self.PushToController(StroyboardName: "Main", "LoginVC")
            }
            
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
    
    func displayAlertMessageWithTitle(title:String, alertMessage messageToDisplay: String){
        
        let alertController = UIAlertController(title:title, message: messageToDisplay, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
    
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    func isValidPassword(Password: String) -> Bool {
        
        if Password.count < 6 {return false}
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        guard texttest.evaluate(with: Password) else { return false }
        
        let numberRegEx  = ".*[0-9]+.*"
        let texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        guard texttest1.evaluate(with: Password) else { return false }
        
        let specialCharacterRegEx  = ".*[!&^%$#@()/_*+-]+.*"
        let texttest2 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        guard texttest2.evaluate(with: Password) else { return false }
        
        return true
    }
    
}
extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: newValue!])
        }
    }
}

extension UIApplication {
    var statusBarView: UIView? {
        if responds(to: Selector("statusBar")) {
            return value(forKey: "statusBar") as? UIView
        }
        return nil
    }
}

//extension UIColor {
//    @objc class var App_Color: UIColor {
//        if #available(iOS 11.0, *) {
//            return UIColor(named: "App_Color")!
//        } else {
//            return UIColor.init(red: 171.0/255.0, green: 0/255.0, blue: 146.0/255.0, alpha: 1)
//        }
//    }
//}
