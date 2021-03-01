//
//  ShowPlaylistViewController.swift
//  CA7S
//
//  Created by Crinoid Mac Mini on 21/10/19.
//  Copyright © 2019 Anshul. All rights reserved.
//

import UIKit

class ShowPlaylistViewController: PlaylistsVC {
  
    var onSelect: (()->Void)!
    var isAdded = false
    var data: [String: Any] = [:]
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isForDownlaod {
            if self.localPlaylist.data[indexPath.row].songsInPlaylist == nil {
                addToLocalSong(atIndex: indexPath.row)
            }else{
                let index = self.localPlaylist.data[indexPath.row].songsInPlaylist.index(where: { dictionary in
                    guard let value = dictionary["created"] as? String
                        else { return false }
                    return value == data["created"] as! String
                })
                
                if index == nil {
                    addToLocalSong(atIndex: indexPath.row)
                }else{
                   self.displayAlertMessage(messageToDisplay: NSLocalizedString("Songs is already added in playlist", comment: ""))
                }
            }
            
            
           
        }else{
            let playListId = self.arrData[indexPath.row]
            let params = ["track_id": "\(data["id"]!)", "playlist_id": "\(playListId["id"]!)"]
            repo.playList(params: params, operation: .ADD_SONG_IN_PLAYLIST_API) { (item) in
                guard let data = item else {return}
                self.displayAlertMessage(messageToDisplay: data["message"].string ?? "Something Went wrong")
               
            }
        }
         self.onSelect()
        
        
    }
    
    func addToLocalSong(atIndex: Int) {
        // to show only the presence of the song in selected playlist
        data["playlist_id"] = "999"
        data["is_playlist"] = true
        
        if self.localPlaylist.data[atIndex].songsInPlaylist == nil {
            self.localPlaylist.data[atIndex].songsInPlaylist = [data]
        }else {
            self.localPlaylist.data[atIndex].songsInPlaylist.append(data)
        }
        self.saveLocalPlayListData()
    }
    
    
    
    
   
    
    @IBAction func onCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
