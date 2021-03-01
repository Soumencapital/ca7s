//
//  AddMusic_LyricsVC.swift
//  CA7S
//

import UIKit
import SVProgressHUD
import Alamofire

class AddMusic_LyricsVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MPMediaPickerControllerDelegate {
    
    @IBOutlet var CollectionView_Header: UICollectionView!
    @IBOutlet var ContainerView: UIView!
    
    @IBOutlet weak var btnComplete: UIButton!

    @IBOutlet weak var lblTitle: UILabel!
    
    var Str_AddMucis = String()
    var Str_AddLyrics = String()
    var selectedIndex:Int = 0
    var audioData:Data?
    
    var ArrAddMusicTabs = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Str_AddMucis = "YES"
        
        ArrAddMusicTabs.add(NSLocalizedString("Add_Music", comment: ""))
        ArrAddMusicTabs.add(NSLocalizedString("Add_Artwork", comment: ""))
        ArrAddMusicTabs.add(NSLocalizedString("Add_Lyrics", comment: ""))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        lblTitle.text = NSLocalizedString("Add_Music", comment: "")
        MusicVC.view.frame = ContainerView.bounds
        ContainerView.addSubview(MusicVC.view)
        
        if (UserDefaults.standard.bool(forKey: Constant.isUploadSongsStepsFirstTime1)) == false{
            
            let txtLabel = PureTitleModel(title: NSLocalizedString("You_can_add_artwork_and_lyrics_from_this_menu.", comment: ""))
            let vc = PopoverTableViewController(items: [txtLabel])
            vc.pop.isNeedPopover = true
            vc.pop.popoverPresentationController?.sourceView = CollectionView_Header
            vc.pop.popoverPresentationController?.sourceRect = self.CollectionView_Header.bounds
            vc.pop.popoverPresentationController?.arrowDirection = .up
            //  vc.delegate = self
            present(vc, animated: true, completion: nil)
            
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: Constant.isUploadSongsStepsFirstTime1)
            defaults.synchronize()
        }
    }
    
    private lazy var MusicVC: AddMusicVC =
    {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle.main)
        var Controller = storyboard.instantiateViewController(withIdentifier: "AddMusicVC") as! AddMusicVC
        Controller.Nav = self.navigationController
        return Controller
    }()
    
    private lazy var LyricsVC: AddLyricsVC =
    {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle.main)
        var Controller = storyboard.instantiateViewController(withIdentifier: "AddLyricsVC") as! AddLyricsVC
        Controller.Nav = self.navigationController
        
        return Controller
    }()
    
    private lazy var artworkVC: AddArtWorkVC =
    {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: Bundle.main)
        var Controller = storyboard.instantiateViewController(withIdentifier: "AddArtWorkVC") as! AddArtWorkVC
        Controller.Nav = self.navigationController
        return Controller
    }()
    
    @IBAction func btnBackPressed(sender:UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddMusicPressed(sender:UIButton) {
        
        
//        if (UserDefaults.standard.bool(forKey: Constant.isUploadSongsStepsFirstTime)) == false{
//
//            let txtLabel = PureTitleModel(title: NSLocalizedString("Touch_here_to_identify_songs", comment: ""))
//            let vc = PopoverTableViewController(items: [txtLabel])
//            vc.pop.isNeedPopover = true
//            vc.pop.popoverPresentationController?.sourceView = CollectionView_Header
//            vc.pop.popoverPresentationController?.sourceRect = self.CollectionView_Header.bounds
//            vc.pop.popoverPresentationController?.arrowDirection = .up
//            //  vc.delegate = self
//            present(vc, animated: true, completion: nil)
//
//            //            let defaults = UserDefaults.standard
//            //            defaults.set(true, forKey: Constant.isUploadSongsStepsFirstTime)
//            //            defaults.synchronize()
//        }else{
//
//        }
        
        
        if validateAddMusic() {
        
            if (UserDefaults.standard.bool(forKey: Constant.isUploadSongsStepsFirstTime3)) == false{
                
                let txtLabel = PureTitleModel(title: NSLocalizedString("Touch_here_to_publish_your_music", comment: ""))
                let vc = PopoverTableViewController(items: [txtLabel])
                vc.pop.isNeedPopover = true
                vc.pop.popoverPresentationController?.sourceView = self.btnComplete
                vc.pop.popoverPresentationController?.sourceRect = self.btnComplete.bounds
                vc.pop.popoverPresentationController?.arrowDirection = .up
                //  vc.delegate = self
                present(vc, animated: true, completion: nil)
                
                 let defaults = UserDefaults.standard
                 defaults.set(true, forKey: Constant.isUploadSongsStepsFirstTime3)
                 defaults.synchronize()
                
            }else{
            self.view.isUserInteractionEnabled = false
            selectedIndex = 0
            CollectionView_Header.reloadData()
            MusicVC.view.isHidden = false
            LyricsVC.view.isHidden = true
            artworkVC.view.isHidden = true
            uploadMusic()
            }
        }
    }
    
    func openImagePicker()  {
            PickUpImage()
    }
    
    //MARK:- CollectionView Delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return ArrAddMusicTabs.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddMusic_Lyrics_CLVCell", for: indexPath) as! AddMusic_Lyrics_CLVCell
        
        cell.lbl_Name.text = ArrAddMusicTabs[indexPath.row] as? String
        
        if selectedIndex == indexPath.row {
            cell.lbl_UnderLine.backgroundColor = Constant.ColorConstant.whilte_a30
        } else {
            cell.lbl_UnderLine.backgroundColor = UIColor.clear
        }
        
        if selectedIndex == 0 {
            MusicVC.btnAddMusic.addTarget(self, action: #selector(pickMusic), for: .touchUpInside)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        selectedIndex = indexPath.row
        if indexPath.row == 0 {
            MusicVC.view.frame = ContainerView.bounds
            ContainerView.addSubview(MusicVC.view)
            CollectionView_Header.reloadData()
            MusicVC.view.isHidden = false
            LyricsVC.view.isHidden = true
            artworkVC.view.isHidden = true
        }
        
        if indexPath.row == 1 {
            LyricsVC.view.frame = ContainerView.bounds
            ContainerView.addSubview(artworkVC.view)
            CollectionView_Header.reloadData()
            MusicVC.view.isHidden = true
            LyricsVC.view.isHidden = true
            artworkVC.view.isHidden = false
            artworkVC.btnAddArtWork.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
        }
        
        if indexPath.row == 2 {
            LyricsVC.view.frame = ContainerView.bounds
            ContainerView.addSubview(LyricsVC.view)
            CollectionView_Header.reloadData()
            MusicVC.view.isHidden = true
            LyricsVC.view.isHidden = false
            artworkVC.view.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
     
        return CGSize(width: self.CollectionView_Header.frame.size.width/3.2 , height: 55)
    }
    
    //MARK:- Image Picker
    
    func PickUpImage() {
        
        let alert = UIAlertController(title: "", message: NSLocalizedString("Please_Select_an_Option", comment: ""), preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default , handler:{ (UIAlertAction)in
            
            self.openCamera()
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Gallery", comment: ""), style: .default , handler:{ (UIAlertAction)in
            
            self.gallery()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: UIAlertActionStyle.cancel, handler:{ (UIAlertAction)in
            
        }))
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            
            let controller = alert.popoverPresentationController
            
            controller?.sourceView = self.view
            controller?.sourceRect = CGRect(x:self.view.frame.size.width/2, y: self.view.frame.size.height/2,width: 315,height: 230)
            controller?.permittedArrowDirections = UIPopoverArrowDirection.up
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openCamera(){
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
            
        }
    }
    
    func gallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let img = UIImagePickerController()
            img.delegate = self
            img.sourceType = UIImagePickerControllerSourceType.photoLibrary
            img.allowsEditing = false
            
            self.present(img, animated: true, completion: nil)
        }
    }
    
    func pickMusic() {
        
        if (UserDefaults.standard.bool(forKey: Constant.isUploadSongsStepsFirstTime2)) == false{
            
            let txtLabel = PureTitleModel(title: NSLocalizedString("Tap_here_to_upload_a_music_file", comment: ""))
            let vc = PopoverTableViewController(items: [txtLabel])
            vc.pop.isNeedPopover = true
            vc.pop.popoverPresentationController?.sourceView = MusicVC.uploadView
            vc.pop.popoverPresentationController?.sourceRect = MusicVC.uploadView.bounds
            vc.pop.popoverPresentationController?.arrowDirection = .up
            //  vc.delegate = self
            present(vc, animated: true, completion: nil)
            
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: Constant.isUploadSongsStepsFirstTime2)
            defaults.synchronize()
        }else{
            let myMediaPickerVC = MPMediaPickerController(mediaTypes: MPMediaType.music)
            myMediaPickerVC.allowsPickingMultipleItems = false
            myMediaPickerVC.delegate = self
            self.present(myMediaPickerVC, animated: true, completion: nil)
        }
    }
    
    //MARK:- Media Picker and Delegates
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPicker.dismiss(animated: true, completion: nil)
        
        let item:MPMediaItem = mediaItemCollection.items[0]
        let assetURL = item.value(forProperty: MPMediaItemPropertyAssetURL)
        print("assetURL ->\(String(describing: assetURL))")
        
        if assetURL == nil {
            return
        }
        DispatchQueue.main.async {
            let fileTitle = item.value(forProperty: MPMediaItemPropertyTitle) as? String
            self.MusicVC.txtSongTitle.text = fileTitle
            self.MusicVC.txtAlbumName.text = item.value(forProperty: MPMediaItemPropertyAlbumTitle) as? String
            self.MusicVC.txtArtistName.text = item.value(forProperty: MPMediaItemPropertyAlbumArtist) as? String
            self.MusicVC.btnAddMusic.isHidden = true
            self.MusicVC.lblProcess.isHidden = false
            self.exportAssetAtURL(assetURL: assetURL as! URL, withTitle: "/fileTitle")
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    
    func exportAssetAtURL(assetURL:URL, withTitle title:String) {
        
        // create destination URL
        let ext = TSLibraryImport.extension(forAssetURL: assetURL)
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = paths[0]
        let outURL = URL.init(fileURLWithPath: documentsDirectory.appending(title)).appendingPathExtension(ext!)
        try? FileManager.default.removeItem(at: outURL)
        
        // create the import object
        let importFile = TSLibraryImport()
        importFile.importAsset(assetURL, to: outURL) { (fileImport) in
            /*
             * If the export was successful (check the status and error properties of
             * the TSLibraryImport instance) you know have a local copy of the file
             * at `outURL` You can get PCM samples for processing by opening it with
             * ExtAudioFile. Yay!
             *
             * Here we're just playing it with AVPlayer
             */
            if fileImport?.status != AVAssetExportSessionStatus.completed {
                print("\(fileImport?.error)")
                return
            } else {
                let data1 = try? Data.init(contentsOf: outURL) as! Data
                self.audioData = data1
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            
            artworkVC.imgArtWork.image = image
            
        }else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            artworkVC.imgArtWork.contentMode = .scaleAspectFill
            artworkVC.imgArtWork.clipsToBounds = true
            artworkVC.imgArtWork.image = image
        }
        else{
            
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func validateAddMusic() -> Bool {
        if audioData == nil {
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_select_Audio_file_to_upload", comment: ""))
            return false
        } else if MusicVC.txtSongTitle.text!.count == 0 {
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_Enter_song_title", comment: ""))
            return false
        } else if MusicVC.txtAlbumName.text!.count == 0 {
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_Enter_album_name", comment: ""))
            return false
        } else if MusicVC.txtArtistName.text!.count == 0 {
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_Enter_artist_name", comment: ""))
            return false
        } else if MusicVC.genreID == nil {
            self.displayAlertMessage(messageToDisplay: NSLocalizedString("Please_select_genre", comment: ""))
            return false
        } 
        return true
    }
    
    func uploadMusic() {
        
        if Connectivity.isConnectedToInternet() {
//            //SVProgressHUD.show()
            let strUID = UserDefaults.standard.value(forKey: Constant.USERDEFAULTS.USER_ID)

            var lyrics:String
            
            if LyricsVC.txtVLyrics == nil || LyricsVC.txtVLyrics.text == "\(Constant.appConstants.kPlaceholder)" {
                lyrics = ""
            }else{
                lyrics = LyricsVC.txtVLyrics.text
            }
            
            var strBase64: String = ""
            
            
            if self.artworkVC.imgArtWork == nil || self.artworkVC.imgArtWork.image == nil{
                print("self.artworkVC.imgArtWork is nil")
            }else{
                let image = self.artworkVC.imgArtWork.image
                let imgData = UIImageJPEGRepresentation(image!, 0.9)!
                strBase64 = imgData.base64EncodedString(options: .lineLength64Characters)
                strBase64 = strBase64.replacingOccurrences(of: "\r\n", with: "", options: NSString.CompareOptions.literal, range: nil)
            }
            
            
            let parameters: Parameters = [

                "user_id" : "\(strUID!)",
                "song_title":MusicVC.txtSongTitle.text!,
                "album_name":MusicVC.txtAlbumName.text!,
                "genre_id":MusicVC.genreID!,
                "artist_name":MusicVC.txtArtistName.text!,
                "lyrics":lyrics,
                "privacy":MusicVC.strPrivacy,
                "add_artwork":strBase64,
                "year":"2019"
            ]

//            print("Para",parameters)
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                
                multipartFormData.append(self.audioData!, withName: "filefield",fileName: self.MusicVC.txtSongTitle.text!, mimeType: "audio/mp3")
                
//                if let imgData = self.artworkVC.imgData {
//                    multipartFormData.append(imgData, withName: "add_artwork",fileName: "file.png", mimeType: "image/png")
//                }
                
                
                for (key, value) in parameters {
                    
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            },to:Constant.APIs.ADD_MUSIC,method:.post,headers:nil)
            { (result) in
                switch result {
                case .success(let upload,_,_):
                    
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress: \(progress.fractionCompleted)")
                        self.MusicVC.uploadView.currentValue = Float(progress.fractionCompleted * Double(100))
                        self.MusicVC.lblProcess.text = "\(Int(self.MusicVC.uploadView.currentValue))%"
                    })
                    
                    upload.responseJSON { response in
//                        SVProgressHUD.dismiss()
                        self.view.isUserInteractionEnabled = true
                        self.MusicVC.uploadView.currentValue = 99.1
                        self.MusicVC.lblProcess.text = "100%"
                        
                        let alertController = UIAlertController(title:"", message: NSLocalizedString("upload_successfully", comment: ""), preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action:UIAlertAction!) in
                            self.navigationController?.popViewController(animated: true)
                        }
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true, completion:nil)
                        
                        print("Sucesss.............")
                    }
                    
                case .failure(let encodingError):
                    self.view.isUserInteractionEnabled = true
                    print ("Fail......")
                    self.displayAlertMessage(messageToDisplay: NSLocalizedString("Uploading_failed", comment: ""))
                    print(encodingError)
//                    SVProgressHUD.dismiss()
                }
            }
        }else{
            self.displayAlertMessageWithTitle(title: Constant.APIs.InternetConnectionTitle, alertMessage: Constant.APIs.InternetConnectionMessage)
        }
    }
}
