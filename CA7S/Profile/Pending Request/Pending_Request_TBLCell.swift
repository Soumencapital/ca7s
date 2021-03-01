//
//  Pending_Request_TBLCell.swift
//  CA7S
//

import UIKit

class Pending_Request_TBLCell: UITableViewCell {

    @IBOutlet var lblUsername: UILabel!
    
    @IBOutlet var btnAccept: UIButton!
    @IBOutlet var btnDecline: UIButton!
    
    @IBOutlet var imgUser: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnAccept.setTitle(NSLocalizedString("Accept", comment: ""), for: .normal)
        btnDecline.setTitle(NSLocalizedString("Decline", comment: ""), for: .normal)
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
