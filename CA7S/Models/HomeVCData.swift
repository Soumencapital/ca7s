//
//  HomeVCData.swift
//  CA7S
//
//  Created by Crinoid Mac Mini on 08/10/19.
//  Copyright © 2019 Bhargav. All rights reserved.
//

import UIKit
import ObjectMapper


class AvailableGenresData: BaseImageData {}
class BannerData: BaseImageData {
    
   var image_url = ""
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        image_url <- map["image_url"]
    }
    
    
}
