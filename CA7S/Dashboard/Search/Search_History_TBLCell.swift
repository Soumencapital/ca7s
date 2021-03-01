//
//  Search_History_TBLCell.swift
//  CA7S
//

import UIKit

class Search_History_TBLCell: UITableViewCell {
    
    @IBOutlet var lblSongTitle: UILabel!
    
    
    @IBOutlet var imgSong: UIImageView!
    var tapOnRemove: (()->Void)!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func tapOnremoveButton(_ sender: UIButton) {
        tapOnRemove()
    }
    
}
