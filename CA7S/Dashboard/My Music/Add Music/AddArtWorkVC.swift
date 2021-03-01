//
//  AddArtWorkVC.swift
//  CA7S
//


import UIKit

class AddArtWorkVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var imgArtWork:UIImageView!
    @IBOutlet var btnAddArtWork:UIButton!
    var Nav : UINavigationController?
    var imgData:Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SetUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if imgArtWork.image == nil{
            btnAddArtWork.setImage(#imageLiteral(resourceName: "add_artwork"), for: .normal)
        }else{
            btnAddArtWork.setImage(UIImage(named: ""), for: .normal)
        }
    }
    
    func SetUI() {
        imgArtWork.contentMode = .scaleAspectFill
        imgArtWork.layer.borderColor = Constant.ColorConstant.darkPink.cgColor
        imgArtWork.layer.borderWidth = 1.0;
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            
            imgArtWork.image = image
            imgData = UIImageJPEGRepresentation(image, 0.9)!
            imgArtWork.contentMode = .scaleAspectFill
            imgArtWork.clipsToBounds = true
            imgArtWork.image = image
        }else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgData = UIImageJPEGRepresentation(image, 0.9)!
            imgArtWork.contentMode = .scaleAspectFill
            imgArtWork.clipsToBounds = true
            imgArtWork.image = image
        } else {
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Button Actions
    
    @IBAction func btnChangeImage(_ sender: Any) {
        PickUpImage()
    }
}
