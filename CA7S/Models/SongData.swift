//
//  SongData.swift
//  CA7S
//
//  Created by Crinoid Mac Mini on 08/10/19.
//  Copyright © 2019 Bhargav. All rights reserved.
//

import Foundation
import ObjectMapper

class GenreData: BaseData {
    var currentPage: Int = 0
    var lastPage: Int = 0
    var data: [SongData] = []
    
    
}


class SongData: BaseData {
    var albumId = ""
    var trackId = ""
    var streamUrl = ""
    var userId = ""
    var imageUrl = ""
    var artistName = ""
    var title = ""
    var lyrics = ""
    var privacy = ""
    var publishedAt = ""
    var likeCount = ""
    var trackCount = ""
    var isLike = false
    var isFavroite = false
    var isPlaylist = false
    
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        albumId <- map["album_id"]
        trackId <- map["track_id"]
        streamUrl <- map["stream_url"]
        userId <- map["user_id"]
        imageUrl <- map["image_url"]
        artistName <- map["artist_name"]
        title <- map["title"]
        lyrics <- map["lyrics"]
         isLike <- map["is_like"]
         isFavroite <- map["is_favorite"]
         isPlaylist <- map["is_playlist"]
        
        
        
    }
    
    
}
