//
//  GenreListCell.swift
//  CA7S
//
//

import UIKit

class GenreListCell: UITableViewCell {

    @IBOutlet var lblCount:UILabel!
    @IBOutlet var imgAlbum:UIImageView!
    @IBOutlet var lblSongTitle:UILabel!
    @IBOutlet var lblGenreTitle:UILabel!
    @IBOutlet var btnOptions:UIButton!
    @IBOutlet var btnLike:UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblCount.clipsToBounds = true
        lblCount.layer.cornerRadius = lblCount.frame.size.height/2.0
        lblCount.layer.borderColor = UIColor.black.cgColor
        lblCount.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
