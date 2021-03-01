//
//  SearchPopUpVC.swift
//  CA7S
//

import UIKit

class SearchPopUpVC: UIViewController , MusicPlayerControllerDelegate {

    @IBOutlet weak var viewSong: UIControl!
    @IBOutlet weak var lblSongTitle: UILabel!
    @IBOutlet weak var lblArtistName: UILabel!
    @IBOutlet weak var imgSong: UIImageView!
    
    @IBOutlet weak var lblTapToCopy: UIButton!
    
    var arrSong:[[String:Any]]?
    var from: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewSong.layer.cornerRadius = 5
        viewSong.clipsToBounds = true
        
        self.lblTapToCopy.setTitle(NSLocalizedString("Tap_To_Copy", comment: ""), for: .normal)
        
        let arrArtist =  arrSong![0]["artists"] as? [[String: String]]
        
        lblSongTitle.text = (arrSong![0] )["title"] as? String
        lblArtistName.text = arrArtist![0]["name"]
        
            //(arrSong![0] )["artist_name"] as? String
        
//        let strImgeUrl = (arrSong![0] )["image_url"] as! String
//        imgSong.sd_setImage(with: URL(string: strImgeUrl), placeholderImage: UIImage(named: "placeholder.png"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        CAMusicViewController.sharedInstance().remove(self)
    }
    
    //MARK:- Button Actions
    
    @IBAction func viewSongClicked(_ sender: Any) {
        
    
        let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ManuallySearchVC") as! ManuallySearchVC
        controller.strSearchText = lblSongTitle.text!
        //        controller.nav = UINavigationController()
        //        self.present(controller, animated: true, completion: nil)
        controller.isFromReconisation = true
        from.navigationController?.pushViewController(controller, animated: true)
       
        self.dismiss(animated: false) {
            
        }
    }
    
    @IBAction func btnDismissControllerClicked(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }

}
