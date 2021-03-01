//
//  Playlist_TBLCell.swift
//  CA7S
//


import UIKit

class Playlist_TBLCell: UITableViewCell {

    @IBOutlet var lblSongTitle: UILabel!
    @IBOutlet var lblSongDescription: UILabel!
    
    @IBOutlet var btnMenu: UIButton!
    
    @IBOutlet var imgAlbum: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
