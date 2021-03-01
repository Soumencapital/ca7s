//
//  Broadcast_Request_TBLCell.swift
//  CA7S
//

import UIKit

class Broadcast_Request_TBLCell: UITableViewCell {
    
    @IBOutlet var lblUsername: UILabel!
    
    @IBOutlet var btnAccept: UIButton!
    @IBOutlet var btnDecline: UIButton!
    
    @IBOutlet var imgUser: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
