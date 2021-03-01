//
//  Notification_TBLCell.swift
//  CA7S
//

import UIKit

class Notification_TBLCell: UITableViewCell {
    
    @IBOutlet var lblSongTitle: UILabel!
    @IBOutlet var lblSongDescription: UILabel!
    @IBOutlet var lblSongUploadBefore: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    @IBOutlet var imgSong: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
