//
//  FileDownloadInfo.swift
//  CA7S
//


import UIKit

class FileDownloadInfo: NSObject {

    var isDownloading:Bool?
    var downloadComplete:Bool?
    var fileTitle:String?
    var downloadSource:String?
    var downloadSource2:String?
    var downloadTask:URLSessionDownloadTask?
    var taskResumeData:Data?
    var downloadProgress:Double?
    var taskIdentifier:Int
    var fileID:String?
    var dataDict:[String:Any]?
    var albumName:String?
    var lyrics:String?
    var albumImageUrl: String?
    
//    var like_count: String
//    var is_like: Bool?
//    var is_favorite: Bool?
//    
    init(title:String, downloadSource source:String,downloadSource2 source2:String,andFile fileID:String, data:[String:Any], album:String, lyrics:String, albumImageUrl: String) {
//    init(title:String, downloadSource source:String,andFile fileID:String, data:[String:Any], album:String, lyrics:String, is_like: Bool, is_favorite: Bool, like_count: String){
        
        self.isDownloading = false
        self.downloadComplete = false
        self.fileTitle = title
        self.downloadSource = source
        self.downloadSource2 = source2
        self.downloadProgress = 0.0
        self.taskIdentifier = -1
        self.fileID = fileID
        self.dataDict = data
        self.albumName = album
        self.lyrics = lyrics
        self.albumImageUrl = albumImageUrl
        
//        self.like_count = like_count
//        self.is_like = is_like
//        self.is_favorite = is_favorite
    }
    
}
