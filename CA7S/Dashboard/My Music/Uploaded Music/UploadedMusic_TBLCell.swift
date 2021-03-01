//
//  UploadedMusic_TBLCell.swift
//  CA7S
//


import UIKit

class UploadedMusic_TBLCell: UITableViewCell {
    
    @IBOutlet var lblCount:UILabel!
    @IBOutlet var imgAlbum:UIImageView!
    @IBOutlet var lblSongTitle:UILabel!
    @IBOutlet var lblDescriptionTitle:UILabel!
    @IBOutlet var btnOptions:UIButton!
    
    @IBOutlet weak var downloadCount: UIButton!
    @IBOutlet weak var listenCount: UIButton!
    
    
    var onDelete: (()->Void)!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        lblCount.clipsToBounds = true
        lblCount.layer.cornerRadius = lblCount.frame.size.height/2.0
        lblCount.layer.borderColor = UIColor.black.cgColor
        lblCount.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func onDelete(_ sender: UIButton) {
        self.onDelete()
    }
    
}
