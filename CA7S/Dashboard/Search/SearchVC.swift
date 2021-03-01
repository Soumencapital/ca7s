//
//  SearchVC.swift
//  CA7S
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD
import SwiftGifOrigin
import YXWaveView


extension String{
    func toDictionary() -> NSDictionary {
        let blankDict : NSDictionary = [:]
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
            } catch {
                print(error.localizedDescription)
            }
        }
        return blankDict
    }
}

class SearchVC: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var btnSearch: UIButton!
    
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var viewSearch: UIView!
    
    @IBOutlet weak var lblTapToScan: UILabel!
    @IBOutlet weak var lblOR: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var gifImage: UIImageView!
    
    @IBOutlet var recordingTimeLabel: UILabel!
    @IBOutlet var record_btn_ref: UIButton!
    @IBOutlet var play_btn_ref: UIButton!
    @IBOutlet var viewLogo:UIControl!
    @IBOutlet var viewBG:UIControl!
    @IBOutlet var imgHeadPhone:UIImageView!
    @IBOutlet var imgGroup767:UIImageView!
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var isPlaying = false
    var arrSearchSongDetails:[[String:Any]]?
    @IBOutlet weak var staticWaveView: UIImageView!
    
    //ACR Cloud 
    var _start = false
    var _client: ACRCloudRecognition?
    
    //MARK:-
    //MARK:- ViewController LifeCycle
     fileprivate var waterView: YXWaveView?
    @IBOutlet weak var viewForanimatiom: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.initialUI()
        gifImage.loadGif(name: "recognize_button_animation")
        gifImage.isHidden = true
        btnMenu.addTarget(self, action:#selector(SSASideMenu.presentLeftMenuViewController), for: .touchUpInside)
        SetUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTable(notification:)), name: Notification.Name("searchPopUp"), object: nil)
        check_record_permission()
        cancel.isHidden = true
        if (UserDefaults.standard.bool(forKey: Constant.isTapToScanFirstTime)) == false{
            let txtLabel = PureTitleModel(title: NSLocalizedString("Tap_To_Scan", comment: ""))
            let vc = PopoverTableViewController(items: [txtLabel])
            vc.pop.isNeedPopover = true
            vc.pop.popoverPresentationController?.sourceView = self.viewBG
            vc.pop.popoverPresentationController?.sourceRect = self.viewBG.bounds
            vc.pop.popoverPresentationController?.arrowDirection = .down
            //  vc.delegate = self
            present(vc, animated: true, completion: nil)
            
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: Constant.isTapToScanFirstTime)
            defaults.synchronize()
        }else{
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.initialUI()
        
        self.setLocalizationString()
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                self.lblTapToScan.font = self.lblTapToScan.font.withSize(16)
            default:
                self.lblTapToScan.font = self.lblTapToScan.font.withSize(20)
            }
        }
        
        
        let frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: viewForanimatiom.bounds.height)
        waterView = YXWaveView(frame: frame, color: UIColor.init(hexString: "#FF95FB"))
      // waterView?.waveHeight = 30
        //waterView?.waveCurvature = 2.5
       
        waterView!.backgroundColor = UIColor.clear
        
        waterView?.waveHeight = 30
        waterView?.waveCurvature = 2.5
        waterView?.waveSpeed = 1.0
        // Add WaveView
        self.viewForanimatiom.addSubview(waterView!)
        //self.viewForanimatiom.isHidden = true
        
        // Start wave
       
        
        
        
    }
    
    //MARK:-
    //MARK:- InitialUI
    
    func initialUI(){
        let config = ACRCloudConfig();
        
        config.accessKey = "581fd0f0ee35ff8ea38202a80c1a77a8";
        config.accessSecret = "NVsTiw1YAj0PA9Z7eyIRj5p3aLemzWsYEI1klHD3";
        config.host = "identify-ap-southeast-1.acrcloud.com";
        //if you want to identify your offline db, set the recMode to "rec_mode_local"
        config.recMode = rec_mode_remote;
        config.audioType = "recording";
        config.requestTimeout = 10;
        config.protocol = "https";
        config.keepPlaying = 2;  //1 is restore the previous Audio Category when stop recording. 2 (default), only stop recording, do nothing with the Audio Category.
        
        /* used for local model */
        if (config.recMode == rec_mode_local || config.recMode == rec_mode_both) {
            config.homedir = Bundle.main.resourcePath!.appending("/acrcloud_local_db");
        }
        
        config.stateBlock = {[weak self] state in
            self?.handleState(state!);
        }
        config.volumeBlock = {[weak self] volume in
            //do some animations with volume
            self?.handleVolume(volume);
        };
        config.resultBlock = {[weak self] result, resType in
            self?.handleResult(result!, resType:resType);
        }
        self._client = ACRCloudRecognition(config: config);
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
    
    func handleResult(_ result: String, resType: ACRCloudResultType) -> Void
    {
        
        DispatchQueue.main.async {
            //            self.resultView.text = result;
            
            print(result);
            
           
            
            if result != ""{
                let dictResponse = result.toDictionary()
                
                print("\(dictResponse)")
                
              
                let dicSuccess = dictResponse["status"] as? [String: AnyObject]
                let strSuccess = dicSuccess!["msg"] as! String
                
                if  strSuccess == "Success"{
                    
                    if let data = dictResponse["metadata"] {
                        
                        if (data as! [String:Any])["music"] != nil {
                            
                            self.arrSearchSongDetails = (data as! [String:Any])["music"] as? [[String:Any]]
                            
                            self.view.isUserInteractionEnabled = true
                            
                            if self.arrSearchSongDetails?.count == 0 {
                                let strMsg = (data as! [String:Any])["message"] as! String
                                self.displayAlertMessage(messageToDisplay: strMsg)
                            }else{
                                let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
                                let controller = storyboard.instantiateViewController(withIdentifier: "SearchPopUpVC") as! SearchPopUpVC
                                controller.modalTransitionStyle = .crossDissolve
                                controller.modalPresentationStyle = .overFullScreen
                                controller.from = self
                                controller.arrSong = self.arrSearchSongDetails //(data as! [String:Any])["data"] as? [[String:Any]]
                                self.present(controller, animated: true, completion: nil)
                            }
                            
                        }else{
                            self.view.isUserInteractionEnabled = true
                            let strMsg = (data as! [String:Any])["message"] as! String
//                            self.displayAlertMessage(messageToDisplay: strMsg)
                        }
                    }else{
                        self.view.isUserInteractionEnabled = true
//                        self.displayAlertMessage(messageToDisplay: NSLocalizedString("Something_went_wrong", comment: ""))
                    }
                }else{
                    self.view.isUserInteractionEnabled = true
                    let strMessage = dicSuccess!["msg"] as! String
//                    self.displayAlertMessage(messageToDisplay: NSLocalizedString(strMessage, comment: ""))
                    let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "SerachEmptyViewController") as! SerachEmptyViewController
                    _ = self.view
                    controller.modalTransitionStyle = .crossDissolve
                    controller.modalPresentationStyle = .overFullScreen
                    controller.onTryAgain = {
                        self.start_recording(self)
                    }
                    self.present(controller, animated: true, completion: nil)
                }
            }
            self.cancelBtn(self)
        }
    }
    
    
    
    func handleVolume(_ volume: Float) -> Void {
        DispatchQueue.main.async {
            //            self.volumeLabel.text = String(format: "Volume: %f", volume)
            print("\(String(format: "Volume: %f", volume))")
        }
    }
    
    func handleState(_ state: String) -> Void
    {
        DispatchQueue.main.async {
            //            self.stateLabel.text = String(format:"State : %@",state)
            print("\(String(format:"State : %@",state))")
        }
    }
    
    func setLocalizationString(){
       
        lblTitle.text = NSLocalizedString("Recognize", comment: "")
        txtSearch.placeholder = NSLocalizedString("Song_Name", comment: "")
        lblOR.text = NSLocalizedString("OR", comment: "")
        lblTapToScan.text = NSLocalizedString("Tap To recognize", comment: "")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reloadTable(notification: NSNotification) {
        txtSearch.text = (arrSearchSongDetails![0] )["title"] as? String
    }
    
    func SetUI() {
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        viewSearch.layer.borderWidth = 1
        viewSearch.layer.borderColor = Constant.ColorConstant.lightPink.cgColor
        viewSearch.layer.cornerRadius = viewSearch.layer.frame.size.height / 2
        viewSearch.clipsToBounds = true
        
        self.view.bringSubview(toFront: viewLogo)
    }
    
    //MARK:- Audio Recording Start
    func check_record_permission()
    {
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSessionRecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.isAudioRecordingGranted = true
                    } else {
                        self.isAudioRecordingGranted = false
                    }
                }
            }
            break
        default:
            break
        }
    }
    
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getFileUrl() -> URL
    {
        let filename = "myRecording.m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        return filePath
    }
    
    func setup_recorder()
    {
        if isAudioRecordingGranted
        {
            let session = AVAudioSession.sharedInstance()
            do
            {
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                
                audioRecorder.prepareToRecord()
            }
            catch let error {
                display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: NSLocalizedString("OK", comment:""))
            }
        }
        else
        {
            display_alert(msg_title: "Error", msg_desc: NSLocalizedString("Don't_have_access_to_use_your_microphone.", comment: ""), action_title: NSLocalizedString("OK", comment: ""))
        }
    }
    
    func updateAudioMeter(timer: Timer)
    {
        if audioRecorder.isRecording
        {
            let hr = Int((audioRecorder.currentTime / 60) / 60)
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            //            recordingTimeLabel.text = totalTimeString
            audioRecorder.updateMeters()
        }
    }
    
    func finishAudioRecording(success: Bool)
    {
        if success
        {
            audioRecorder.stop()
            meterTimer.invalidate()
            print("recorded successfully.")
            
        }
        else
        {
            display_alert(msg_title: "Error", msg_desc: NSLocalizedString("Recording_failed.", comment: ""), action_title: NSLocalizedString("OK", comment: ""))
        }
    }
    
    func prepare_play()
    {
        do
        {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileUrl())
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        }
        catch{
            print("Error")
        }
    }
    
    @IBAction func start_recording(_ sender: Any) {
        if lblTapToScan.text == NSLocalizedString("Listening...", comment: "") {
            cancelBtn(sender)
            return
        }
        
        lblTapToScan.text = NSLocalizedString("Listening...", comment: "")
        lblOR.text = ""
        gifImage.isHidden = false
        waterView?.start()
        self.staticWaveView.isHidden = true
        //self.viewForanimatiom.isHidden = false
        //self.view.isUserInteractionEnabled = false
        cancel.isHidden = false
        
        self.viewLogo.isHidden = true
        //self.imgGroup767.isHidden = false
        
        UIView.animate(withDuration: 0.5, delay: 1.0, options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat], animations: {
           // self.imgGroup767.isHidden = true
            self.viewBG.isHidden = false
            self.viewBG.transform = CGAffineTransform(scaleX: 0.55, y: 0.55)
            //            self.imgHeadPhone.transform = CGAffineTransform(translationX: 10, y: 10)
        }, completion: nil)
        
      
        
        if(isRecording)
        {
            //            finishAudioRecording(success: true)
            //            record_btn_ref.setTitle("Record", for: .normal)
            //            play_btn_ref.isEnabled = true
            //            isRecording = false
        }
        else
        {
            
            if (_start) {
                return;
            }
            //                self.resultView.text = "";
            
            
            self.setup_recorder()
            
            self._client?.startRecordRec();
            self._start = true;
            
            
            //
            //                audioRecorder.record(forDuration: TimeInterval(15))
            //                meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            //                isRecording = true
        }
        
    }
    
    @IBAction func play_recording(_ sender: Any)
    {
        if(isPlaying)
        {
            audioPlayer.stop()
            record_btn_ref.isEnabled = true
            play_btn_ref.setTitle("Play", for: .normal)
            isPlaying = false
        }
        else
        {
            if FileManager.default.fileExists(atPath: getFileUrl().path)
            {
                record_btn_ref.isEnabled = false
                play_btn_ref.setTitle(NSLocalizedString("Pause", comment: ""), for: .normal)
                prepare_play()
                audioPlayer.play()
                isPlaying = true
            }
            else
            {
                display_alert(msg_title: "Error", msg_desc: NSLocalizedString("Audio_file_is_missing.", comment: ""), action_title: NSLocalizedString("OK", comment: ""))
            }
        }
    }
    
    
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
        })
        present(ac, animated: true)
    }
    
    //MARK:- Button Actions
    
    @IBAction func btnHistory(_ sender: Any) {
        self.PushToController(StroyboardName: "Dashboard", "SearchHistoryVC")
    }
    
    @IBAction func btnSearch(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ManuallySearchVC") as! ManuallySearchVC
        controller.strSearchText = txtSearch.text!
        //        controller.nav = UINavigationController()
//        self.present(controller, animated: true, completion: nil)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        self.lblTapToScan.text = NSLocalizedString("Tap To recognize", comment: "")
        self.gifImage.isHidden = true
        self.viewLogo.isHidden = false
        self.lblOR.text = NSLocalizedString("OR", comment: "")
        self.cancel.isHidden = true
        self.viewBG.layer.removeAllAnimations()
        self.viewLogo.layer.removeAllAnimations()
        self.imgHeadPhone.layer.removeAllAnimations()
        self.viewBG.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self._client?.stopRecordRec();
        self._start = false;
        self.waterView?.stop()
        self.staticWaveView.isHidden = false
       // self.viewForanimatiom.isHidden = true
    }
    
    
    @IBAction func btnTapToScan(_ sender: Any) {
        self.displayAlertMessage(messageToDisplay: NSLocalizedString("Under_Development", comment: ""))
    }
    
    //MARK:- API Calling
    
    func SearchRecognizeSongAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)
            
            let parameters: Parameters = [
                "user_id" : "\(strUID!)"
            ]
            
            let audioData:Data = try! Data.init(contentsOf: getFileUrl())
            print("Para",parameters)
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                
                multipartFormData.append(audioData, withName: "filefield",fileName: "file.m4a", mimeType: "mp3")
                
                for (key, value) in parameters {
                    
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            },to:Constant.APIs.SEARCH_RECOGNIZE_API,method:.post,headers:nil)
            { (result) in
                switch result {
                case .success(let upload,_,_):
                   
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress: \(progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON(completionHandler: { (response) in
                        self.lblTapToScan.text = NSLocalizedString("Tap_To_Scan", comment: "")
                        self.lblOR.text = NSLocalizedString("OR", comment: "")
                        
                        self.viewBG.layer.removeAllAnimations()
                        self.viewLogo.layer.removeAllAnimations()
                        self.imgHeadPhone.layer.removeAllAnimations()
                        self.viewBG.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        
                        if let data = response.result.value {
                            
                            if ((data as! [String:Any])["status"] as! String == "success" && (data as! [String:Any])["data"] != nil) {
                                
                                self.arrSearchSongDetails = (data as! [String:Any])["data"] as? [[String:Any]]
                                self.view.isUserInteractionEnabled = true
                                if self.arrSearchSongDetails?.count == 0 {
                                    let strMsg = (data as! [String:Any])["message"] as! String
                                    self.displayAlertMessage(messageToDisplay: strMsg)
                                }else{
                                    let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
                                    let controller = storyboard.instantiateViewController(withIdentifier: "SearchPopUpVC") as! SearchPopUpVC
                                    controller.modalTransitionStyle = .crossDissolve
                                    controller.modalPresentationStyle = .overFullScreen
                                    controller.arrSong = (data as! [String:Any])["data"] as? [[String:Any]]
                                    self.present(controller, animated: true, completion: nil)
                                }
                                
                                
                            }else{
                                self.view.isUserInteractionEnabled = true
                                let strMsg = (data as! [String:Any])["message"] as! String
                                self.displayAlertMessage(messageToDisplay: strMsg)
                            }
                        }else{
                            self.view.isUserInteractionEnabled = true
                            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Something_went_wrong", comment: ""))
                        }
                    })
                    
                    //                        self.displayAlertMessage(messageToDisplay: (((response.result.value as! [String:Any])["data"] as! [String:Any])["status"] as! [String:Any])["msg"] as! String)
                    SVProgressHUD.dismiss()
                    
                case .failure(let encodingError):
                    SVProgressHUD.dismiss()
                    print ("Fail......")
                    print(encodingError)
                    self.view.isUserInteractionEnabled = true
                }
            }
        }else{
            
            self.displayAlertMessageWithTitle(title: Constant.APIs.InternetConnectionTitle, alertMessage: Constant.APIs.InternetConnectionMessage)
        }
    }
}
