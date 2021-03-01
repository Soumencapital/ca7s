//
//  Sidebar_TBLCell.swift
//  CA7S
//

import UIKit

class Sidebar_TBLCell: UITableViewCell {
    
    @IBOutlet weak var menuimage: UIImageView!
    @IBOutlet weak var menuTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
