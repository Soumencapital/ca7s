//
//  DiscoverTVCell.swift
//  CA7S
//
//  Created by Omika Garg on 05/09/19.
//  Copyright © 2019 Bhargav. All rights reserved.
//

import UIKit


class DiscoverTVCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var CV_Album: UICollectionView!
    
    @IBOutlet weak var lblLeftTitle: UILabel!
    
    @IBOutlet weak var btnBrowseAll: UIButton!
    
    var intIndex = Int()
    
    var arrDataTop = [[String:AnyObject]]()
    
    var newRelease = [[String:AnyObject]]()
    
    var arrRisingStar = [[String:AnyObject]]()
    var selectionType: Constant.APIs.DiscoverDeatilUrl! = .none
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func setData(index: Int, topCA7s: [[String:AnyObject]], arrRisingStar: [[String:AnyObject]], arrNewRelease: [[String:AnyObject]]) {
        intIndex = index
        self.CV_Album!.register(UINib(nibName: "DiscoverCVCell", bundle: nil), forCellWithReuseIdentifier: "discoverCVCell")
        self.newRelease = arrNewRelease
        self.arrRisingStar = arrRisingStar
        self.arrDataTop = topCA7s
        self.CV_Album.delegate = self
        self.CV_Album.dataSource = self
        self.CV_Album.reloadData()
    }
    
    
    //MARK:- CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if intIndex == 0 {
            return arrDataTop.count + 1
        }
        if intIndex == 1 {
            return newRelease.count + 1
        }
        if intIndex  == 2 {
            return arrRisingStar.count + 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "discoverCVCell", for: indexPath) as! DiscoverCVCell
        cell.layer.cornerRadius = 15
        cell.layer.masksToBounds = true
        cell.imgGenreSong.image = UIImage(named: "bannerTop")
        if indexPath.row == 0 {
            if intIndex == 0 {
                cell.lblGenreSongTitle.text = "Top"
                cell.imgGenreSong.image = UIImage(named: "bannerTop")
            }
            else if intIndex == 1 {
                cell.lblGenreSongTitle.text = NSLocalizedString("New", comment: "")
                cell.imgGenreSong.image = UIImage(named: "bannerNew")
            }
            else {
                cell.lblGenreSongTitle.text = NSLocalizedString("Rising Stars", comment: "")
                cell.imgGenreSong.image = UIImage(named: "bannerRising")
            }
        }
        else {
            
            var dictData = [String:AnyObject]()
            switch self.intIndex {
            case 0:
                dictData = self.arrDataTop[indexPath.row - 1]
                break
            case 1:
                dictData = self.newRelease[indexPath.row - 1]
                break
                
            case 2:
                dictData = self.arrRisingStar[indexPath.row - 1]
                break
            default:
                break
                
            }
            cell.lblGenreSongTitle.text = dictData["type"]?.description
            let strImgeUrl = dictData["image_icon"]?.description
            cell.imgGenreSong.sd_setShowActivityIndicatorView(true)
            cell.imgGenreSong.sd_setIndicatorStyle(.gray)
            if !UserDefaults.standard.bool(forKey: Constant.USERDEFAULTS.economicMode) {
            cell.imgGenreSong.sd_setImage(with: URL(string: strImgeUrl ?? ""), placeholderImage: UIImage(named: "default album-1"))
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // if intIndex != 0 {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GenreViewController") as! GenreViewController
        if indexPath.row == 0 {
            if self.arrRisingStar.isEmpty {return}
            var dictData = arrRisingStar[indexPath.row]
            
            
            vc.strGenreID =  "0"//(dictData["type"]?.description)!
            vc.strGenreName =  ""//(dictData["album_name"]?.description)!
            //            vc.strArtistName =  (dictData["artist_name"]?.description)!
         
            vc.strIsFromTop = "NO"
            vc.strHeaderGenre = "Top Ca7s"
            vc.isFromZeroIndex = true
            switch intIndex {
            case 0:
                self.selectionType = .topGenereAtZero
                   vc.strGenreIsFrom = NSLocalizedString("The most voted songs", comment: "")
            case 1:
                self.selectionType = .newReleaseAtZero
                  vc.strGenreIsFrom = NSLocalizedString("The latest releases", comment: "")
            case 2:
                self.selectionType = .risingStarAtZero
                  vc.strGenreIsFrom = NSLocalizedString("Our next stars", comment: "")
            default: break
                
            }
            
            
        }
        else {
             var dictData = [String:AnyObject]()
            switch intIndex {
            case 0:
                dictData = self.arrDataTop[indexPath.row - 1]
                break
            case 1:
                dictData = self.newRelease[indexPath.row - 1]
                break
            case 2:
                dictData = self.arrRisingStar[indexPath.row - 1]
                break
            default:
                break
            }
            
            
           
            vc.strGenreID =  (dictData["id"]?.description)!
            vc.strGenreName =  (dictData["type"]?.description)!
            vc.gereInfoData = dictData
            //            vc.strArtistName =  (dictData["artist_name"]?.description)!
            vc.strGenreIsFrom = NSLocalizedString("Genre", comment: "")
            vc.strIsFromTop = "NO"
            vc.strHeaderGenre = (dictData["type"]?.description)!//"Genre"
            switch intIndex {
            case 0:
                self.selectionType = .topAfterZero
            case 1:
                self.selectionType = .newReleaseAfterZero
            case 2:
                self.selectionType = .risingStarAfterZero
            default: break
            }
            
        }
        vc.selectionType = self.selectionType
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
        
        // }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 90, height: 90)
    }
}
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
