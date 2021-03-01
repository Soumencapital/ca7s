//
//  HomeAlbumVC.swift
//  CA7S
//
//  Created by Omika Garg on 08/09/19.
//  Copyright © 2019 Bhargav. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD

class HomeAlbumVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MusicPlayerControllerDelegate {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var CV_Album: UICollectionView!
    @IBOutlet weak var lblNoDataFound: UILabel!
    var arrData = [[String:AnyObject]]()

    //*********For music mini view*********///////
    
    @IBOutlet weak var imgAlbum: UIImageView!
    @IBOutlet var viewPlayer:UIView!
    @IBOutlet var playerSlider:UISlider!
    @IBOutlet var lblSongTitle: UILabel!
    @IBOutlet var lblAlbumName: UILabel!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var btnPrevious: UIButton!
    @IBOutlet var btnNext: UIButton!
    @IBOutlet var tblBottom: NSLayoutConstraint!
  
    var timer : Timer?
    var isPanning:Bool = false
    /////////////////////////////////////
    
    var header = ""
    var selectionType: Constant.APIs.DiscoverDeatilUrl = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if arrData.isEmpty {
            lblNoDataFound.isHidden = false
        }
        else {
            lblNoDataFound.isHidden = true
        }
        lblNoDataFound.text = NSLocalizedString("No_Data_Found", comment: "")
        lblTitle.text = NSLocalizedString(header, comment: "")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initMusicView()
    }
    
    
    func initMusicView() {
        
        if (CAMusicViewController.sharedInstance().playbackState == MPMusicPlaybackState.playing || CAMusicViewController.sharedInstance().playbackState == MPMusicPlaybackState.paused) {
          
            CAMusicViewController.sharedInstance().add(self)
            tblBottom.isActive = true
            viewPlayer.isHidden = false
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timedJob), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: .commonModes)
            playerSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
            
            let musicPlayer = CAMusicViewController.sharedInstance()
            
            if let mediaitem = musicPlayer?.nowPlayingItem {
                
                //   var img:UIImage?
                
                SDImageCache.shared().clearMemory()
                SDImageCache.shared().clearDisk()
                
                let imageURL = mediaitem["image_url"] as? String
                self.imgAlbum.sd_setImage(with: URL(string: imageURL ?? ""), placeholderImage: UIImage(named: "default album"))
                //                let imgData = try? Data.init(contentsOf: URL.init(string: imageURL)!)
                //                if let data = imgData {
                //                    img = UIImage.init(data: data)
                //                    self.imgAlbum.image = img;
                //                }
                
                self.lblSongTitle.text = mediaitem["title"] as? String
                
                if (mediaitem["album_name"] as? String) != nil{
                    self.lblAlbumName.text = mediaitem["album_name"] as? String
                }else{
                    self.lblAlbumName.text = musicPlayer?.strAlbumName
                }
                
                //                self.lblAlbumName.text = musicPlayer?.strAlbumName
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
            tblBottom.isActive = false
            viewPlayer.isHidden = true
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
    
    @IBAction func btnPrevious(_ sender: Any) {
        CAMusicViewController.sharedInstance().skipToPreviousItem()
    }
    
    @IBAction func btnNext(_ sender: Any) {
        CAMusicViewController.sharedInstance().skipToNextItem()
    }
    
    @IBAction func btnBack(_ sender: Any){
        
        self.navigationController?.popViewController(animated: true)
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
        
        var dictData = arrData[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GenreViewController") as! GenreViewController
        vc.strGenreID =  (dictData["id"]?.description)!
        vc.strGenreName =  (dictData["type"]?.description)!
        //            vc.strArtistName =  (dictData["artist_name"]?.description)!
        vc.strGenreIsFrom = NSLocalizedString("Genre", comment: "")
        vc.strIsFromTop = "NO"
        vc.strHeaderGenre = (dictData["type"]?.description)!
        vc.selectionType = selectionType
    vc.gereInfoData = dictData
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 100, height: 100)
    }
}
