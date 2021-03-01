//
//  CADownloadManager.swift
//  CA7S
//

import UIKit
import Alamofire
import SVProgressHUD
import SDWebImage


class CADownloadManager: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    static let shared = CADownloadManager()
    
    var backgroundTransferCompletionHandler: ()?
    
    static private let kResumeCurrentRequest = "NSURLSessionResumeCurrentRequest"
    static private let kResumeOriginalRequest = "NSURLSessionResumeOriginalRequest"
    
    var arrIDs:[String]?
    var arrDownloadRequests:[DownloadRequest]?
    var arrFileInfo:[FileDownloadInfo]?
    var directoryURL:URL?
    var session:URLSession?
    var progress: ((_ progress: Float) -> Void)! = {arg in}
    
    override init() {
        arrIDs = [String]()
        arrDownloadRequests = [DownloadRequest]()
        arrFileInfo = [FileDownloadInfo]()

        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        directoryURL = paths[0]
        
        // Configure Session
        //        let sessionConfiguration = URLSessionConfiguration.backgroundSessionConfiguration("com.app.ca7s")
        let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: "com.app.ca7s")
        sessionConfiguration.httpMaximumConnectionsPerHost = 9999;
        
        super.init()
        
        session = URLSession.init(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
    }
    
    func addDelegate() {
//        let sessionConfiguration = URLSessionConfiguration.backgroundSessionConfiguration("com.app.ca7s")
        let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: "com.app.ca7s")
        sessionConfiguration.httpMaximumConnectionsPerHost = 9999;
        session = URLSession.init(configuration: sessionConfiguration, delegate: CADownloadManager.shared, delegateQueue: nil)
    }
    
    
    func downloadFile(_ downloadInfo:FileDownloadInfo) {
        
        // The isDownloading property of the fdi object defines whether a downloading should be started
        // or be stopped.
        if downloadInfo.isDownloading == false {
            // This is the case where a download task should be started.
            
            // Create a new task, but check whether it should be created using a URL or resume data.
            if downloadInfo.taskIdentifier == -1 {
                // If the taskIdentifier property of the fdi object has value -1, then create a new task
                // providing the appropriate URL as the download source.
                let url = downloadInfo.downloadSource!
                downloadInfo.downloadTask = session?.downloadTask(with: URL.init(string: url)!)
                // Keep the new task identifier.
                downloadInfo.taskIdentifier = (downloadInfo.downloadTask?.taskIdentifier)!
                // Start the task.
                downloadInfo.downloadTask?.resume()
            } else {
                var data = self.correctResumeData(downloadInfo.taskResumeData)
                
                if data == nil {
                    data = downloadInfo.taskResumeData;
                }
                
                downloadInfo.downloadTask = session?.downloadTask(withResumeData: data!)
                if self.getResumeDictionary(data!) != nil {
                    let dict = self.getResumeDictionary(data!)
                    if downloadInfo.downloadTask?.originalRequest == nil {
                        let originalData = dict![CADownloadManager.kResumeOriginalRequest] as! Data
                        downloadInfo.downloadTask?.setValue(NSKeyedUnarchiver.unarchiveObject(with: originalData) , forKey: "originalRequest")
                    }
                    if downloadInfo.downloadTask?.currentRequest == nil {
                        let originalData = dict![CADownloadManager.kResumeCurrentRequest] as! Data
                        downloadInfo.downloadTask?.setValue(NSKeyedUnarchiver.unarchiveObject(with: originalData) , forKey: "currentRequest")
                    }
                }
                downloadInfo.downloadTask?.resume()
            }
        }  else {
            downloadInfo.downloadTask?.cancel(byProducingResumeData: { (resumeData) in
                downloadInfo.taskResumeData = resumeData!
            })
        }
        
        downloadInfo.isDownloading = !downloadInfo.isDownloading!        
    }
    
    func correct(requestData data: Data?) -> Data? {
        guard let data = data else {
            return nil
        }
        if NSKeyedUnarchiver.unarchiveObject(with: data) != nil {
            return data
        }
        guard let archive = (try? PropertyListSerialization.propertyList(from: data, options: [.mutableContainersAndLeaves], format: nil)) as? NSMutableDictionary else {
            return nil
        }
        // Rectify weird __nsurlrequest_proto_props objects to $number pattern
        var k = 0
        while ((archive["$objects"] as? NSArray)?[1] as? NSDictionary)?.object(forKey: "$\(k)") != nil {
            k += 1
        }
        var i = 0
        while ((archive["$objects"] as? NSArray)?[1] as? NSDictionary)?.object(forKey: "__nsurlrequest_proto_prop_obj_\(i)") != nil {
            let arr = archive["$objects"] as? NSMutableArray
            if let dic = arr?[1] as? NSMutableDictionary, let obj = dic["__nsurlrequest_proto_prop_obj_\(i)"] {
                dic.setObject(obj, forKey: "$\(i + k)" as NSString)
                dic.removeObject(forKey: "__nsurlrequest_proto_prop_obj_\(i)")
                arr?[1] = dic
                archive["$objects"] = arr
            }
            i += 1
        }
        if ((archive["$objects"] as? NSArray)?[1] as? NSDictionary)?.object(forKey: "__nsurlrequest_proto_props") != nil {
            let arr = archive["$objects"] as? NSMutableArray
            if let dic = arr?[1] as? NSMutableDictionary, let obj = dic["__nsurlrequest_proto_props"] {
                dic.setObject(obj, forKey: "$\(i + k)" as NSString)
                dic.removeObject(forKey: "__nsurlrequest_proto_props")
                arr?[1] = dic
                archive["$objects"] = arr
            }
        }
        /* I think we have no reason to keep this section in effect
         for item in (archive["$objects"] as? NSMutableArray) ?? [] {
         if let cls = item as? NSMutableDictionary, cls["$classname"] as? NSString == "NSURLRequest" {
         cls["$classname"] = NSString(string: "NSMutableURLRequest")
         (cls["$classes"] as? NSMutableArray)?.insert(NSString(string: "NSMutableURLRequest"), at: 0)
         }
         }*/
        // Rectify weird "NSKeyedArchiveRootObjectKey" top key to NSKeyedArchiveRootObjectKey = "root"
        if let obj = (archive["$top"] as? NSMutableDictionary)?.object(forKey: "NSKeyedArchiveRootObjectKey") as AnyObject? {
            (archive["$top"] as? NSMutableDictionary)?.setObject(obj, forKey: NSKeyedArchiveRootObjectKey as NSString)
            (archive["$top"] as? NSMutableDictionary)?.removeObject(forKey: "NSKeyedArchiveRootObjectKey")
        }
        // Reencode archived object
        let result = try? PropertyListSerialization.data(fromPropertyList: archive, format: PropertyListSerialization.PropertyListFormat.binary, options: PropertyListSerialization.WriteOptions())
        return result
    }
    
    func getResumeDictionary(_ data: Data) -> NSMutableDictionary? {
        // In beta versions, resumeData is NSKeyedArchive encoded instead of plist
        var iresumeDictionary: NSMutableDictionary? = nil
        if #available(iOS 10.0, OSX 10.12, *) {
            var root : AnyObject? = nil
            let keyedUnarchiver = NSKeyedUnarchiver(forReadingWith: data)
            
            do {
                root = try keyedUnarchiver.decodeTopLevelObject(forKey: "NSKeyedArchiveRootObjectKey") ?? nil
                if root == nil {
                    root = try keyedUnarchiver.decodeTopLevelObject(forKey: NSKeyedArchiveRootObjectKey)
                }
            } catch {}
            keyedUnarchiver.finishDecoding()
            iresumeDictionary = root as? NSMutableDictionary
            
        }
        
        if iresumeDictionary == nil {
            do {
                iresumeDictionary = try PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.ReadOptions(), format: nil) as? NSMutableDictionary;
            } catch {}
        }
        
        return iresumeDictionary
    }
    
    func correctResumeData(_ data: Data?) -> Data? {
        let kResumeCurrentRequest = "NSURLSessionResumeCurrentRequest"
        let kResumeOriginalRequest = "NSURLSessionResumeOriginalRequest"
        
        guard let data = data, let resumeDictionary = getResumeDictionary(data) else {
            return nil
        }
        
        resumeDictionary[kResumeCurrentRequest] = correct(requestData: resumeDictionary[kResumeCurrentRequest] as? Data)
        resumeDictionary[kResumeOriginalRequest] = correct(requestData: resumeDictionary[kResumeOriginalRequest] as? Data)
        
        let result = try? PropertyListSerialization.data(fromPropertyList: resumeDictionary, format: PropertyListSerialization.PropertyListFormat.xml, options: PropertyListSerialization.WriteOptions())
        return result
    }
    
    //MARK: NSURLSession Delegate method implementation
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        let index = getFileDownloadInfoIndexWithTaskIdentifier(taskID: downloadTask.taskIdentifier)
        let fdi = CADownloadManager.shared.arrFileInfo![index]
        
        let manager = FileManager.default
        let destinationFilename = fdi.fileTitle! + ".mp3"
        let destinationURL = directoryURL?.appendingPathComponent(destinationFilename)
      
        
        if manager.fileExists(atPath: (destinationURL?.path)!) {
            try! manager.removeItem(at: destinationURL!)
        }
        do {
            try? manager.copyItem(at: location, to: destinationURL!)

            
            var title = ""
            var like = ""
            var favourite = ""
            var like_count = ""
            var image_url = ""
            var id = ""
            var albumName = ""
            var lyrics = ""
            var stream_url = ""
            
            if(fdi.fileTitle != nil){
                title = fdi.fileTitle!
            }
            
            //            if(fdi.is_like != nil){
            //                like = fdi.is_like!
            //            }
            //
            //
            //            if(fdi.favourite != nil){
            //                favourite = fdi.is_favourite!
            //            }
            //
            //
            //            if(fdi.like_count != nil){
            //                like_count = fdi.like_count
            //            }
            
            if(fdi.dataDict![image_url] != nil){
                image_url = fdi.dataDict![image_url] as! String
            }
            
            if(fdi.fileID != nil){
                id = fdi.fileID!
            }
            
            if(fdi.albumName != nil){
                albumName = fdi.albumName!
            }
            
            if(fdi.lyrics != nil){
                lyrics = fdi.lyrics!
            }
            
            if(fdi.dataDict!["stream_url"] != nil){
                stream_url = fdi.dataDict!["stream_url"] as! String
            }
            
            
//            let query = NSString(format: "INSERT INTO audio (title, image_url, filename, id, albumName, lyrics, created, stream_url) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", %f,\"%@\");", fdi.fileTitle!, fdi.dataDict!["image_url"] as! String, destinationFilename, fdi.fileID!, fdi.albumName!, fdi.lyrics!, NSDate().timeIntervalSince1970,fdi.dataDict!["stream_url"] as! String)
//
            
            let desinationForImage = Date().timeIntervalSince1970.description + "_image" + ".jpeg"
            let imageDesinationURL = directoryURL!.appendingPathComponent(desinationForImage)
            SDWebImageDownloader.shared().downloadImage(with: URL(string: fdi.albumImageUrl!), options: .highPriority, progress: { (_, _, _) in
                
            }) { (image, imageData, error, isSave) in
                
              try? imageData?.write(to: imageDesinationURL)
            }
        

            let query = NSString(format: "INSERT INTO audio (title, image_url, filename, id, albumName, lyrics, created, stream_url) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", %f,\"%@\");", title, fdi.albumImageUrl!, destinationFilename, id, albumName, fdi.lyrics!, NSDate().timeIntervalSince1970,stream_url)
            
            
//            let query = NSString(format: "INSERT INTO audio (title, is_like,is_favorite, like_count , image_url, filename, id, albumName, lyrics, created) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", %f);", fdi.fileTitle!, fdi.is_like!, fdi.is_favorite!, fdi.like_count,fdi.dataDict!["image_url"] as! String, destinationFilename, fdi.fileID!, fdi.albumName!, fdi.lyrics!, NSDate().timeIntervalSince1970)

            DataBase.sharedInstance().insertData(query as String?)

            CADownloadManager.shared.arrFileInfo?.remove(at: index)
            CADownloadManager.shared.arrIDs?.remove(at: index)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.appConstants.kDownloadCompleteNotification), object: self)
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            print("Download completed with error: " + (error?.localizedDescription)!)
        }
        else{
            SVProgressHUD.dismiss()
            print("Download finished successfully.")
        }
    }
    
    func urlSession(_ session:URLSession, downloadTask: URLSessionDownloadTask, didWriteData: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64 ) {
        
        if totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown {
            print("Unknown transfer size")
        } else {
            // Locate the FileDownloadInfo object among all based on the taskIdentifier property of the task.
            
            let index = getFileDownloadInfoIndexWithTaskIdentifier(taskID: downloadTask.taskIdentifier)
            
            
            let fdi = CADownloadManager.shared.arrFileInfo![index]
            OperationQueue.main.addOperation({
                fdi.downloadProgress = Double(totalBytesWritten)/Double(totalBytesExpectedToWrite)
                print( fdi.downloadProgress)
                self.progress(Float(fdi.downloadProgress!))
               
            })
        }
    }
    
    func getTheProgess(_ progress: Float) {
        
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            if downloadTasks.count == 0 {
                if CADownloadManager.shared.backgroundTransferCompletionHandler != nil {
                    () = CADownloadManager.shared.backgroundTransferCompletionHandler!
                    CADownloadManager.shared.backgroundTransferCompletionHandler = nil
                    
                    let localNotification = UILocalNotification()
                    localNotification.alertBody = NSLocalizedString("All_files_have_been_downloaded!", comment: "")
                    UIApplication.shared.presentLocalNotificationNow(localNotification)
                }
            }
        }
    }
    
    func getFileDownloadInfoIndexWithTaskIdentifier(taskID:Int) -> Int {
        var index:Int = -1
        var i = 0
        for fdi in CADownloadManager.shared.arrFileInfo! {
            if fdi.taskIdentifier == taskID {
                index = i
                break
            }
            i += 1
        }
        return index
    }
}
