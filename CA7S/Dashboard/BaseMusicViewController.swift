//
//  BaseMusicViewController.swift
//  CA7S
//
//  Created by Crinoid Mac Mini on 09/11/19.
//  Copyright © 2019 Anshul. All rights reserved.
//

import UIKit
import SVProgressHUD

class BaseMusicViewController: UIViewController, MusicPlayerControllerDelegate {

    @IBOutlet weak var imgAlbum: UIImageView!
    @IBOutlet var viewPlayer:UIControl!
    @IBOutlet var playerSlider:UISlider!
    @IBOutlet var lblSongTitle: UILabel!
    @IBOutlet var lblAlbumName: UILabel!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var btnPrevious: UIButton!
    @IBOutlet var btnNext: UIButton!
    @IBOutlet weak var viewPlayerHeight: NSLayoutConstraint!
    
    var timer: Timer?
    var timerPlayer : Timer?
    var isPanning:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        

        // Do any additional setup after loading the view.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (CAMusicViewController.sharedInstance().playbackState == MPMusicPlaybackState.playing || CAMusicViewController.sharedInstance().playbackState == MPMusicPlaybackState.paused) {
          
            CAMusicViewController.sharedInstance().add(self)
            // containerViewBottom.isActive = true
            viewPlayer.isHidden = false
            viewPlayerHeight.constant = 80
            
            timerPlayer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timedJob), userInfo: nil, repeats: true)
            RunLoop.current.add(timerPlayer!, forMode: .commonModes)
            
            playerSlider.setMaximumTrackImage(#imageLiteral(resourceName: "max_track"), for: .normal)
            /*playerSlider.maximumTrackTintColor = UIColor.init(red: 254.0/255, green: 142.0/255, blue: 211.0/255, alpha: 1)
             playerSlider.minimumTrackTintColor = UIColor.white*/
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
                }else if let image = mediaitem["artwork_url"] as? String {
                    imageURL = image
                }
               
                
                self.imgAlbum.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "default song"))
                self.lblSongTitle.text = mediaitem["title"] as? String
                // self.lblAlbumName.text = musicPlayer?.strAlbumName
                
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
    
    //MARK:- Button Actions
    @IBAction func btnPlay(_ sender: Any){
        if CAMusicViewController.sharedInstance().playbackState == MPMusicPlaybackState.playing {
            CAMusicViewController.sharedInstance().pause()
            btnPlay.isSelected = false
        } else {
            CAMusicViewController.sharedInstance().play()
            btnPlay.isSelected = true
        }
    }
    
    @IBAction func btnNext(_ sender: Any){
        CAMusicViewController.sharedInstance().skipToNextItem()
    }
    
    @IBAction func btnPrevious(_ sender: Any){
        CAMusicViewController.sharedInstance().skipToPreviousItem()
    }
    
    @IBAction func btnOpenPlayer(_ sender: UIControl){
        
        let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MusicPlayerVC") as! MusicPlayerVC
        controller.isFrom = GenreViewController()
        
        let trackData2  = UserDefaults.standard.object(forKey: "trackData")
        
        if trackData2 != nil{
            let trackData3 = NSKeyedUnarchiver.unarchiveObject(with: trackData2 as! Data) as? [String: Any]
            
            controller.genreData = trackData3!
            controller.arrAlbumData.append(trackData3 as! [String : AnyObject])
            controller.intValue = 0
        }
        
        //        self.present(controller, animated: true, completion: nil)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
}
