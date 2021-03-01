//
//  SearchHistoryVC.swift
//  CA7S
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SVProgressHUD


class SearchHistoryVC: UIViewController,UITableViewDelegate,UITableViewDataSource, MusicPlayerControllerDelegate {
    
    @IBOutlet var tblUserList: UITableView!
    
  

    @IBOutlet weak var lblNoDataFound = UILabel()
    
    @IBOutlet weak var lblHistory: UILabel!
    var searchKeyWords: [String] = []
    var searchData: [String] = []
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLocalizationString()
        if let searchKeywords = UserDefaults.standard.string(forKey: Constant.USERDEFAULTS.SEARCH_HISTORY) {
            self.searchKeyWords = searchKeywords.components(separatedBy: ",")
            
        }
   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setLocalizationString(){
        lblHistory.text = NSLocalizedString("History", comment: "")
        lblNoDataFound?.text = NSLocalizedString("No_Data_Found", comment: "")
    }
    
    //MARK:- Table Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return (section == 1) ? searchKeyWords.count : searchData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            let cell:Search_History_TBLCell = tableView.dequeueReusableCell(withIdentifier: "Search_History_TBLCell") as! Search_History_TBLCell
            cell.lblSongTitle.text = self.searchKeyWords[indexPath.row]
            return cell
        }
      
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searcResult") as! UITableViewCell
            cell.textLabel!.text = self.searchData[indexPath.row]
            return cell
        }
   
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    
   
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Recent Searches"
        }
        return ""
    }
  
    
    //MARK:- Button Actions
    
    @IBAction func btnBack(_ sender: Any){
        self.navigationController?.popViewController(animated: true)
    }

    //MARK:- API Calling
    
    
   
}


