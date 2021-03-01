//
//  AppDelegate.swift
//  CA7S
//
//http://www.redturtle.in/projects/ca7s

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD
import UserNotifications
import Firebase

import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    var mainTabBarController:Dashboard_TabbarVC?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.sharedManager().enable = true
        application.applicationIconBadgeNumber = 0

        UIApplication.shared.statusBarView?.backgroundColor = UIColor.init(red: 200.0/255.0, green: 69/255, blue: 180.0/255.0, alpha: 1)
        
//        if #available(iOS 11.0, *) {
//            UIApplication.shared.statusBarView?.backgroundColor = UIColor.init(named: "App_Color")
//
//        } else {
          //  UIApplication.shared.statusBarView?.backgroundColor = UIColor.init(red: 171.0/255.0, green: 0/255, blue: 146.0/255.0, alpha: 1)
            // Fallback on earlier versions
//        }
        //(red: 171.0/255.0, green: 0.0/255.0, blue: 146.0/255.0, alpha: 0.8)
        
        FirebaseApp.configure()
        
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()

        if let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] {
            NSLog("[RemoteNotification] applicationState: \(applicationStateString) didFinishLaunchingWithOptions for iOS9: \(userInfo)")
        }
        
//        if (UserDefaults.standard.string(forKey: Constant.AppLanguage)) == "English" {
//            L102Language.setAppleLAnguageTo(lang: "en")
//        }else{
//            L102Language.setAppleLAnguageTo(lang: "pt")
//        }

        let local = NSLocale.current.languageCode!
        if (UserDefaults.standard.string(forKey: Constant.AppLanguage)) == "Portugese" {
            L102Language.setAppleLAnguageTo(lang: "pt")
        }
        else if (UserDefaults.standard.string(forKey: Constant.AppLanguage)) == "English" {
            L102Language.setAppleLAnguageTo(lang: "en")
        }else{
            if local == "pt"{
                
                L102Language.setAppleLAnguageTo(lang: "pt")
                
                UserDefaults.standard.set("Portugese", forKey: Constant.AppLanguage)

            }else{
            
            L102Language.setAppleLAnguageTo(lang: "en")
                
            UserDefaults.standard.set("English", forKey: Constant.AppLanguage)
            
            }
            
        }
        
//        UserDefaults.standard.set(true, forKey: Constant.isUploadMusicFirstTime)
        
        
        if (UserDefaults.standard.bool(forKey: Constant.isUploadMusicFirstTime)) == false{
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: Constant.isUploadMusicFirstTime)
            defaults.synchronize()
        }else{
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: Constant.isUploadMusicFirstTime)
            defaults.synchronize()
        }
        
        if (UserDefaults.standard.bool(forKey: Constant.isTapToScanFirstTime)) == false{
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: Constant.isTapToScanFirstTime)
            defaults.synchronize()
        }else{
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: Constant.isTapToScanFirstTime)
            defaults.synchronize()
        }
        
        if (UserDefaults.standard.bool(forKey: Constant.isUploadSongsStepsFirstTime1)) == false{
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: Constant.isUploadSongsStepsFirstTime1)
            defaults.synchronize()
        }else{
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: Constant.isUploadSongsStepsFirstTime1)
            defaults.synchronize()
        }
        
        if (UserDefaults.standard.bool(forKey: Constant.isUploadSongsStepsFirstTime2)) == false{
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: Constant.isUploadSongsStepsFirstTime2)
            defaults.synchronize()
        }else{
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: Constant.isUploadSongsStepsFirstTime2)
            defaults.synchronize()
        }
        
        if (UserDefaults.standard.bool(forKey: Constant.isUploadSongsStepsFirstTime3)) == false{
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: Constant.isUploadSongsStepsFirstTime3)
            defaults.synchronize()
        }else{
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: Constant.isUploadSongsStepsFirstTime3)
            defaults.synchronize()
        }
        
//        if (UserDefaults.standard.bool(forKey: Constant.appConstants.IS_LOGIN)) {
            self.setMainTabBarControllerFor(nil)


        UIApplication.shared.statusBarStyle = .lightContent
        UINavigationBar.appearance().barStyle = .blackOpaque
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }catch {
            print(error)
        }
        
         L102Localizer.DoTheMagic()
       
        
//        NotificationCenter.default.addObserver(self, selector: Selector("languageWillChange:"), name: NSNotification.Name(rawValue: "LANGUAGE_WILL_CHANGE"), object: nil)
//        
//        let targetLang = UserDefaults.standard.object(forKey: "selectedLanguage") as? String
//        
//        Bundle.setLanguage((targetLang != nil) ? targetLang : "en")
//        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        self.checkNetworkType()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
       print(url.host as! String)
       self.GetSingleTrackDetailUsingId(url.host as! String)
        
        
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options:options) || true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        CADownloadManager.shared.backgroundTransferCompletionHandler = completionHandler()
    }
    
    func setMainTabBarControllerFor(_ navBar:UINavigationController?) {
        if mainTabBarController == nil {
            let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Dashboard_TabbarVC") as! Dashboard_TabbarVC
            mainTabBarController = vc
            if navBar == nil {
                let nav = UINavigationController.init(rootViewController: vc)
                let sideBar = self.window?.rootViewController as! SSASideMenu
                sideBar.contentViewController = nav
                sideBar.panGestureEnabled = true
                self.window?.rootViewController = sideBar
                self.window?.makeKeyAndVisible()
            } else {
                let sideBar = self.window?.rootViewController as! SSASideMenu
                sideBar.panGestureEnabled = true
                navBar!.pushViewController(vc, animated: true)
            }
        } else {
            let sideBar = self.window?.rootViewController as! SSASideMenu
            sideBar.panGestureEnabled = true
            navBar!.pushViewController(mainTabBarController!, animated: true)
        }
    }
    
    //MARK:- Notification Methods
    
    var applicationStateString: String {
        if UIApplication.shared.applicationState == .active {
            return "active"
        } else if UIApplication.shared.applicationState == .background {
            return "background"
        }else {
            return "inactive"
        }
    }
    
    func requestNotificationAuthorization(application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        
            UserDefaults.standard.set("\(fcmToken)", forKey: Constant.USERDEFAULTS.DEVICE_TOKEN)
             UserDefaults.standard.synchronize()
        
       
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        Messaging.messaging().subscribe(toTopic: "weather")
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       
        if let refreshedToken = InstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            let token = refreshedToken
            if token != "" {
                 Messaging.messaging().subscribe(toTopic: "weather")
                UserDefaults.standard.set("\(token)", forKey: Constant.USERDEFAULTS.DEVICE_TOKEN)
                
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    // iOS9, called when presenting notification in foreground
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        NSLog("[RemoteNotification] applicationState: \(applicationStateString) didReceiveRemoteNotification for iOS9: \(userInfo)")
        application.applicationIconBadgeNumber = 0
        if UIApplication.shared.applicationState == .active {
            //TODO: Handle foreground notification
        } else {
            //TODO: Handle background notification
        }
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        NSLog("[UserNotificationCenter] applicationState: \(applicationStateString) willPresentNotification: \(userInfo)")
        //TODO: Handle foreground notification
        completionHandler([.alert])
    }
    
    // iOS10+, called when received response (default open, dismiss or custom action) for a notification
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        NSLog("[UserNotificationCenter] applicationState: \(applicationStateString) didReceiveResponse: \(userInfo)")
        //TODO: Handle background notification
        completionHandler()
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
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        return true
    }
    
    
    func GetSingleTrackDetailUsingId(_ id: String){
     
   

        if Connectivity.isConnectedToInternet() {
            
            SVProgressHUD.show()
            let strUID = UserDefaults.standard.string(forKey: Constant.USERDEFAULTS.USER_ID)
            var parameters: Parameters =  [
                "track_id" : id
            ]
            
            if let str = strUID {
                parameters["user_id"] = str
            }
            
            
            
            Alamofire.request(Constant.APIs.Get_SINGLE_Track, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                SVProgressHUD.dismiss()
                  let rootViewController = self.mainTabBarController?.viewControllers![0] as! HomeVC
                if let data = response.result.value {
                    if data["status"] == "success" {
                         let item = data["data"]
                        guard let _ = item.dictionaryObject else {
                            let alert = UIAlertController(title: "Info", message: data["message"].string ?? "", preferredStyle: UIAlertControllerStyle.alert)
                            
                            // add an action (button)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            
                            // show the alert
                            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                            
                            
                            return}
                        let rootViewController = self.mainTabBarController?.viewControllers![0] as! HomeVC
                       
                        let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "MusicPlayerVC") as! MusicPlayerVC
                        //controller.isFromUploadMusic = true
                        //controller.isPresented = true
                      //  self.present(controller, animated: true, completion: nil)
                        
                        if CAMusicViewController.sharedInstance().playbackState == .playing{
                            CAMusicViewController.sharedInstance().pause()
                        }
                        
                        CAMusicViewController.sharedInstance().add(rootViewController)
                        CAMusicViewController.sharedInstance().playerType = .remote
                        CAMusicViewController.sharedInstance().setQueueWithItemCollection(NSMutableArray(object: item.dictionaryObject!))
                        if CAMusicViewController.sharedInstance().shuffleMode {
                            CAMusicViewController.sharedInstance().playItem(at: UInt(0))
                        } else {
                            CAMusicViewController.sharedInstance()?.playItem(at: 0)
                        }
                        ////////////////////////////////////////////////////////////
                       
                        
                        rootViewController.navigationController?.pushViewController(controller, animated: true)
                        //self.btnLike.isSelected = (data["data"]["is_like"] as? Bool) ?? false
                    }else{
                     
                        
                    }
                }else{
                   
                }
            })
        }else{
           
        }
    }
    

    func checkNetworkType()  {
    
        if (NetworkReachabilityManager()!.isReachableOnWWAN) &&  !UserDefaults.standard.bool(forKey: Constant.USERDEFAULTS.economicMode) {
            let alert = UIAlertController(title: "Info", message: NSLocalizedString("We_noticed_that_you_are_on_3G_mode", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Continue", comment: ""), style: .default, handler: { (_) in
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
                let centerViewController = mainStoryboard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
                centerViewController.ifFromMusic = true
                self.mainTabBarController?.selectedViewController!.navigationController?.pushViewController(centerViewController, animated: true)
               
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("continue_and_Don't_show_this_again", comment: ""), style: .default, handler: { (_) in
                UserDefaults.standard.set(true, forKey: Constant.USERDEFAULTS.showEconomicMode)
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .destructive, handler: { (_) in
                UserDefaults.standard.set(true, forKey: Constant.isAwareAboutEconomicMode)
            }))
            if !UserDefaults.standard.bool(forKey: Constant.USERDEFAULTS.showEconomicMode){
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
         }
        
        if NetworkReachabilityManager()!.isReachableOnEthernetOrWiFi {
            UserDefaults.standard.set(false, forKey: Constant.USERDEFAULTS.economicMode)
            
        }
        
    }
    
}

