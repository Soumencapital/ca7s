//
//  PlaylistPopupViewController.swift
//  CA7S
//
//  Created by Crinoid Mac Mini on 13/12/19.
//  Copyright © 2019 Anshul. All rights reserved.
//

import UIKit
import Gallery

class PlaylistPopupViewController: UIViewController, GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        images.first?.resolve(completion: { (image) in
            self.imageView.image = image!
        })
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playListName: UITextField!
    @IBOutlet weak var create: UIButton!
    var forEdit = false
    var playlistImageUrl: String!
    var createPlayList: ((_ name: String, _ image: UIImage?) -> Void)!
var previousPlayList = ""
    var editPlayListImage = UIImage(named: "app-logo")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
       
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
       playListName.placeholder = NSLocalizedString("Playlist Name", comment: "")
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         create.setTitle( !forEdit ? NSLocalizedString("Add New Playlist", comment: ""): NSLocalizedString("Edit Playlist", comment: ""), for: .normal)
        self.playListName.text = previousPlayList
        self.imageView.image = editPlayListImage
        if forEdit && playlistImageUrl != nil{
            self.imageView.sd_setImage(with: URL(string: playlistImageUrl ?? ""), placeholderImage: UIImage(named: "app-logo"))
        }
        
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        
       intialPicker()
        
        // Your action
    }
    
    @IBAction func onCreate(_ sender: UIButton) {
        if (playListName.text?.isEmpty)!{
            
        }else{
            createPlayList(playListName.text!, imageView.image)
            self.dismiss(animated: true, completion: nil)
        }
        
        
    }
    @IBAction func onDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func intialPicker() {
        let gallery = GalleryController()
        gallery.delegate = self
        Config.Camera.imageLimit = 1
        Config.tabsToShow = [.imageTab, .cameraTab]
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.mainTabBarController?.present(gallery, animated: true, completion: nil)
        }

    }
    

}
