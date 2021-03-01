//
//  LyricsViewController.swift
//  CA7S
//
//  Created by YOGESH BANSAL on 08/10/19.
//  Copyright © 2019 Bhargav. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LyricsViewController: UIViewController {
    @IBOutlet var lblLyricsTrackTitle:UILabel!
    @IBOutlet var lblLyricsAlbumTitle:UILabel!
//    @IBOutlet weak var vwLyrics: UIView!
//    @IBOutlet weak var vwInnerLyrics: UIView!
    
    
     @IBOutlet var txtVLyrics:UITextView!
    var lyrics = ""
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var dictData: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblLyricsTrackTitle.text = dictData["title"] as? String
        lblLyricsAlbumTitle.text = dictData["artist_name"] as? String
        txtVLyrics.text = lyrics
        if lyrics == NSLocalizedString("No Lyrics Found", comment: "") {
            getLyrics((dictData["title"] as! String).replacingOccurrences(of: " ", with: "%20"), by: (dictData["artist_name"] as! String).replacingOccurrences(of: " ", with: "%20"))
        }
        // Do any additional setup after loading the view.
    }
    
    
    func getLyrics(_ ofTitle: String, by artist: String) {
        let endpoint = "https://api.musixmatch.com/ws/1.1/matcher.lyrics.get?format=jsonp&callback=callback&q_track=\(ofTitle)&q_artist=\(artist)&apikey=8355f17e8db00c7768301ab25a3f7488"
        //let endpoint = "https://api.musixmatch.com/ws/1.1/matcher.lyrics.get?format=jsonp&callback=callback&q_track=Tum%20hi%20aana&apikey=8355f17e8db00c7768301ab25a3f7488"
        Alamofire.request(endpoint, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseString{ (response) in
            self.txtVLyrics.text = self.lyrics
            if response.description.contains("SUCCESS:") {
                var validString = response.description.replacingOccurrences(of: "callback(", with: "")
               validString = validString.replacingOccurrences(of: ");", with: "")
                validString = validString.replacingOccurrences(of: "SUCCESS:", with: "")
                var json = JSON.init(parseJSON:validString)
                let message  = json["message"].dictionary!
                
                guard let body  = message["body"]?.dictionary else{return}
                guard let lyrics = body["lyrics"]? .dictionary else{return}
                self.txtVLyrics.text = lyrics["lyrics_body"]!.string
                
            }
        }
        
        
        
        
    }

   

}
