//
//  AddMusicVC.swift
//  CA7S
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD
import Localize_Swift
import ActionSheetPicker_3_0


class AddMusicVC: UIViewController, MPMediaPickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet var uploadView:CircularView!
    @IBOutlet var btnAddMusic:UIButton!
    @IBOutlet var lblProcess:UILabel!
    @IBOutlet weak var txtGenre: UITextField!
    @IBOutlet weak var txtSongTitle: UITextField!
    @IBOutlet weak var txtAlbumName: UITextField!
    @IBOutlet weak var txtArtistName: UITextField!
    @IBOutlet weak var txtReleaseYear: UIButton!
    
    
    @IBOutlet var btnPublic:UIButton!
    @IBOutlet var btnPrivate:UIButton!
    @IBOutlet var btnOnlyMe:UIButton!
   
    var strPrivacy : String = "2"
    
    var arrGenre = [[String:AnyObject]]()
    var arrGenreName = NSMutableArray()
    var myPickerView : UIPickerView!
    
    var Nav : UINavigationController!
    var genreID:String?
    var selectedIndex:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
//
//
//            let txtLabel = PureTitleModel(title: NSLocalizedString("Touch_here_to_search_for_music_on_your_device", comment: ""))
//
//            let vc = PopoverTableViewController(items: [txtLabel])
//            vc.pop.isNeedPopover = true
//            vc.pop.popoverPresentationController?.sourceView = uploadView
//            vc.pop.popoverPresentationController?.sourceRect = uploadView.bounds
//            vc.pop.popoverPresentationController?.arrowDirection = .down
//            //  vc.delegate = self
//            present(vc, animated: true, completion: nil)
//
//
//
//
//
////            let defaults = UserDefaults.standard
////            defaults.set(true, forKey: Constant.isUploadSongsStepsFirstTime)
////            defaults.synchronize()
//        }
        
        
        
        GetGenreListAPI()
        
        strPrivacy = "2"
        btnPrivate.isSelected = false
        btnPublic.isSelected = true
        btnOnlyMe.isSelected = false
        
        self.btnAddMusic.isHidden = false
        self.lblProcess.isHidden = true
        uploadView.isUserInteractionEnabled = false
        uploadView.currentValue = 0
        setLocalizationString()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setLocalizationString()
    }
    
    func setLocalizationString(){
        
        txtGenre.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("Genre", comment: ""), attributes: [NSForegroundColorAttributeName: Constant.ColorConstant.placeHolderColor])
        txtSongTitle.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("Song_Title", comment: ""), attributes: [NSForegroundColorAttributeName: Constant.ColorConstant.placeHolderColor])
        txtAlbumName.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("Album_Name", comment: ""), attributes: [NSForegroundColorAttributeName: Constant.ColorConstant.placeHolderColor])
        txtArtistName.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("Artist_Name", comment: ""), attributes: [NSForegroundColorAttributeName: Constant.ColorConstant.placeHolderColor])
txtReleaseYear.setAttributedTitle(NSAttributedString(string:NSLocalizedString("Release_year", comment: ""), attributes: [NSForegroundColorAttributeName: Constant.ColorConstant.placeHolderColor]), for: .normal)
        btnPublic.setTitle(NSLocalizedString("Public", comment: ""), for: .normal)
        btnPrivate.setTitle(NSLocalizedString("Private", comment: ""), for: .normal)
        btnOnlyMe.setTitle(NSLocalizedString("Only_Me", comment: ""), for: .normal)
        
    }
    
    @IBAction func btnPrivacyPressed(_ sender: UIButton) {
        
        if sender.tag == 123 {
            strPrivacy = "1"
            btnPrivate.isSelected = true
            btnPublic.isSelected = false
            btnOnlyMe.isSelected = false
        }else if sender.tag == 124 {
            strPrivacy = "2"
            btnPrivate.isSelected = false
            btnPublic.isSelected = true
            btnOnlyMe.isSelected = false
        }else  if sender.tag == 125 {
            strPrivacy = "3"
            btnPrivate.isSelected = false
            btnPublic.isSelected = false
            btnOnlyMe.isSelected = true
        }
    }
    
    //MARK:- Custom Picker
    
    func pickUp(_ textField : UITextField){
        
        // UIPickerView
        self.myPickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.myPickerView.delegate = self
        self.myPickerView.dataSource = self
        txtGenre.inputView = self.myPickerView
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 79/255, green: 90/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .plain, target: self, action: #selector(AddMusicVC.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(AddMusicVC.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        txtGenre.inputAccessoryView = toolBar
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return arrGenreName.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return arrGenreName[row] as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedIndex = row
        self.txtGenre.text = "\(arrGenreName[row])"
    }
    
    func doneClick() {
        if txtReleaseYear.titleLabel?.text!.count != 4 {
            return
        }
        genreID = "\(String(describing: (arrGenre[selectedIndex] as [String:Any])["id"]!))"
        txtGenre.resignFirstResponder()
    }
    
    func cancelClick() {
        
        txtGenre.resignFirstResponder()
    }
    
    //MARK:- TextFiled Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == txtGenre{
            self.pickUp(txtGenre)
        }
    }
    
    //MARK:- API Calling
    
    func GetGenreListAPI() {
        
        if Connectivity.isConnectedToInternet() {
            
            //SVProgressHUD.show()
            
            Alamofire.request(Constant.APIs.GET_GENRE_LIST_API, method: .get, parameters: nil , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
        
                SVProgressHUD.dismiss()
                
                if let data = response.result.value {
                    
                    if data["status"] == "success" {
                        
                        if let arrSearchResponse =  data["data"].arrayObject{
                            
                            if self.arrGenre.count == 0 {
                                self.arrGenre = arrSearchResponse as! [[String:AnyObject]]
                                
                                for i in 0..<self.arrGenre.count {
                                    self.arrGenreName.add((self.arrGenre[i]["type"]?.description)!)
                                }
                                
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
    @IBAction func selectReleaseYear(_ sender: UIButton) {
        var years:[String] = []
        for i in 1880...2020 {
            years.append(i.description)
        }
        
        ActionSheetMultipleStringPicker.show(withTitle: "", rows: [years], initialSelection: [0], doneBlock: {
                picker, indexes, values in
            if let v = values as? [Int] {
                sender.setTitle(v.first?.description, for: .normal)
            }
            
                return
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
    }
    
}

