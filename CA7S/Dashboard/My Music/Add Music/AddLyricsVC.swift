//
//  AddLyricsVC.swift
//  CA7S
//

import UIKit

class AddLyricsVC: UIViewController, UITextViewDelegate {

    @IBOutlet var btnSave:UIButton!
    @IBOutlet var txtVLyrics:UITextView!
    var Nav : UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnSave.clipsToBounds = true
        btnSave.layer.cornerRadius = btnSave.frame.size.height/2.0
        
        txtVLyrics.layer.borderColor = UIColor.darkGray.cgColor
        txtVLyrics.layer.borderWidth = 1
        txtVLyrics.text = Constant.appConstants.kPlaceholder
        
        btnSave.setTitle(NSLocalizedString(NSLocalizedString("Save", comment: ""), comment: ""), for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.btnSave.setTitle(NSLocalizedString(NSLocalizedString("Save", comment: ""), comment: ""), for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == Constant.appConstants.kPlaceholder {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = Constant.appConstants.kPlaceholder
        }
        
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let currentText = textView.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }

            let changedText = currentText.replacingCharacters(in: stringRange, with: text)

            return changedText.count <= 10
        }
        
    }
}
