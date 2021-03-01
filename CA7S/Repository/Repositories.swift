//
//  Repositories.swift
//  CA7S
//
//  Created by Crinoid Mac Mini on 13/10/19.
//  Copyright © 2019 Bhargav. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SVProgressHUD




struct PlaylistRepositories {
    func playList(params: Parameters, operation: Constant.APIs.PlayListUrl, onCompletion: @escaping ((_ item: JSON?) -> Void)) {
        if Connectivity.isConnectedToInternet() {
            //SVProgressHUD.show()
            if operation == .CREATE_PLAYLIST_API || operation == .UPDATE_PLAYLIST_API {
                Alamofire.upload(multipartFormData: { multipartFormData in
                    
                    for (key, value) in params {
                        if key == "image" {
                            multipartFormData.append((value as! Data), withName: key, fileName: Date().timeIntervalSince1970.description, mimeType: "image/jpg")
                           
                        }else{
                            multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
                        }
                        
                    } //Optional for extra parameters
                },
                                 to: Constant.APIs.BASE_API + operation.rawValue)
                { (result) in
                    switch result {
                    case .success(let upload, _, _):
                        
                        upload.uploadProgress(closure: { (progress) in
                            SVProgressHUD.showProgress(Float(progress.fractionCompleted))
                        })
                        
                        upload.responseSwiftyJSON { response in
                            onCompletion((response.result.value))
                        }
                        
                    case .failure(let encodingError):
                        print(encodingError)
                    }
                }
                
            }else{
                Alamofire.request(Constant.APIs.BASE_API + operation.rawValue, method: .post, parameters: params , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                    SVProgressHUD.dismiss()
                    onCompletion((response.result.value))
                })
            }
            
        }
    }
}


struct DiscoverRepositories {
    func playList(params: Parameters, operation: Constant.APIs.DiscoverDeatilUrl, onCompletion: @escaping ((_ item: JSON?) -> Void)) {
        if Connectivity.isConnectedToInternet() {
            //SVProgressHUD.show()
            Alamofire.request(Constant.APIs.BASE_API + operation.rawValue, method: .post, parameters: params , encoding: URLEncoding.default, headers: nil).responseSwiftyJSON(completionHandler: { (response) in
                SVProgressHUD.dismiss()
                onCompletion((response.result.value))
            })
        }
    }
}


