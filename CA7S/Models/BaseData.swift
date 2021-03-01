//
//  BaseData.swift
//  CA7S
//
//  Created by Crinoid Mac Mini on 08/10/19.
//  Copyright © 2019 Bhargav. All rights reserved.
//

import UIKit
import ObjectMapper

class BaseData: Mappable {
    var id = 0
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
          id <- map["id"]
    }
}


class BaseImageData: BaseData {
    var type = ""
    var imageIcon = ""
    
    override func mapping(map: Map) {
        type <- map["type"]
        imageIcon <- map["image_icon"]
    }
    
    
}

class BaseResponseObject<T: BaseData>: BaseData {
    var status = true
    var data: T!
    
    override func mapping(map: Map) {
        var s = ""
        s <- map["status"]
        status = (s == "success")
        data <- map["list"]
    }
    
}


class BaseResponseList<T: BaseData> : BaseData {
    
    var status  = true
    var data: [T] = []
    
    
    override func mapping(map: Map) {
       var s = ""
        s <- map["status"]
        status = (s == "success")
        data <- map["data"]
    }
    
    
    
}


