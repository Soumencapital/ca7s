//
//  Following_TBLCell.swift
//  CA7S
//

import UIKit

class Following_TBLCell: UITableViewCell {

    @IBOutlet var lblUsername: UILabel!
    @IBOutlet var lblPlaceName: UILabel!
    
    @IBOutlet var btnFollowing: UIButton!
    @IBOutlet var btnOption: UIButton!
    
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
