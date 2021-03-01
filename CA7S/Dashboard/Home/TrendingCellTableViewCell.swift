//
//  TrendingCellTableViewCell.swift
//  CA7S
//
//  Created by Crinoid Mac Mini on 12/11/19.
//  Copyright © 2019 Anshul. All rights reserved.
//

import UIKit
import TTGTagCollectionView

class TrendingCellTableViewCell: UITableViewCell, TTGTextTagCollectionViewDelegate {

    @IBOutlet weak var tagTextCollection: TTGTextTagCollectionView!
    var tagTextConfig = TTGTextTagConfig()
    var selectedTagConfig = TTGTextTagConfig()
    var hasToShowMore = false
    var arrTrending = [[String:AnyObject]]()
    var onSelectMore: ((_ item: Bool)->())!
    var onSelectText: ((_ data: String) -> Void)!
    @IBOutlet weak var trending: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTagTextView()
        // Initialization code
        trending.text = NSLocalizedString("Trending", comment: "")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureTagTextView() {
        tagTextCollection.manualCalculateHeight = true
        tagTextCollection.alignment = .fillByExpandingWidth
        tagTextCollection.selectionLimit = 0
        tagTextConfig.cornerRadius = 8
        tagTextConfig.borderColor = UIColor(hexString: "#C845B4")
        tagTextConfig.borderWidth = 1.0
        tagTextConfig.backgroundColor = UIColor.white
        tagTextConfig.textColor = UIColor.init(red: 249.0/255, green: 102.0/255, blue: 196.0/255, alpha: 1)
        tagTextConfig.selectedBorderColor = UIColor.init(red: 200.0/255, green: 69.0/255, blue: 180.0/255, alpha: 1)
        tagTextConfig.selectedBackgroundColor = UIColor(hexString: "#C845B4")
        tagTextConfig.exactHeight = 30
        tagTextConfig.selectedTextColor = UIColor.white
        tagTextConfig.maxWidth = UIScreen.main.bounds.width / 3
        tagTextCollection.delegate = self
        //self.selectedTagConfig = tagTextConfig
        self.selectedTagConfig.borderColor = tagTextConfig.selectedBorderColor
        self.selectedTagConfig.backgroundColor = tagTextConfig.selectedBackgroundColor
        self.selectedTagConfig.textColor = tagTextConfig.selectedTextColor
        
    }

    //MARK:- set trending text
    
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTapTag tagText: String!, at index: UInt, selected: Bool, tagConfig config: TTGTextTagConfig!) {
        
        switch tagText {
        case "More","Mais":
            self.hasToShowMore = true
            textTagCollectionView.setTagAt(index, selected: true)
            self.onSelectMore(hasToShowMore)
            break
        case "Less","Menos":
            self.hasToShowMore = false
            textTagCollectionView.setTagAt(index, selected: true)
            self.onSelectMore(hasToShowMore)
            
            break
        default:
            textTagCollectionView.removeAllTags()
           self.onSelectText(tagText)
            textTagCollectionView.setTagAt(index, selected: true)
           // self.searchTextField.text = tagText
            break
        }
        
       self.setTrendingText()
        
        
        
    }
    
    func setTrendingText()  {
        if self.arrTrending.isEmpty {return}
        let defaultCount = (self.arrTrending.count > 5) ? 5 : self.arrTrending.count
        let count = self.hasToShowMore ? self.arrTrending.count : defaultCount
        self.tagTextCollection.removeAllTags()
        for i in 0..<count {
            self.tagTextCollection.addTag(self.arrTrending[i]["song_title"] as? String, with: self.tagTextConfig)
        }
        if self.arrTrending.count > 5 {
            self.tagTextCollection.addTag(hasToShowMore ? NSLocalizedString("Less", comment: "") : NSLocalizedString("More", comment: ""), with: self.selectedTagConfig)
     
        }
        
    }
    
    
 
    
}
