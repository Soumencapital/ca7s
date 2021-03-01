//
//  Broadcast_JoinVC.swift
//  CA7S
//

import UIKit

class Broadcast_JoinVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var tblUserList: UITableView!
    
    var ArrImgUser = NSMutableArray()
    var ArrUsername = NSMutableArray()

    var Index : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SetArrayValues()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func SetArrayValues() {
        
        ArrUsername.add("Mac Arora")
        ArrUsername.add("Mac Arora")
        ArrUsername.add("Mac Arora")
        ArrUsername.add("Mac Arora")
        ArrUsername.add("Mac Arora")
        ArrUsername.add("Mac Arora")
        ArrUsername.add("Mac Arora")
        
        ArrImgUser.add("profile_user")
        ArrImgUser.add("profile_user")
        ArrImgUser.add("profile_user")
        ArrImgUser.add("profile_user")
        ArrImgUser.add("profile_user")
        ArrImgUser.add("profile_user")
        ArrImgUser.add("profile_user")
    }
    
    //MARK:- Table Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArrUsername.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:Broadcast_Join_TBLCell = tableView.dequeueReusableCell(withIdentifier: "Broadcast_Join_TBLCell") as! Broadcast_Join_TBLCell
        
        cell.selectionStyle = .none
        
        cell.lblUsername.text = ArrUsername[indexPath.row] as? String
        
        cell.btnJoin.isUserInteractionEnabled = false
//        cell.btnJoin.addTarget(self, action: #selector(btnJoin(_:)), for: .touchUpInside)
        
        cell.imgUser.image = UIImage(named: (ArrImgUser[indexPath.row] as? String)!)
        
        if Index == indexPath.row{
            
            if cell.btnJoin.currentTitle == "+ Join"{
                cell.btnJoin.setTitle("Connected", for: .normal)
                cell.btnJoin.setTitleColor(Constant.ColorConstant.darkPink, for: .normal)
            }else{
                cell.btnJoin.setTitleColor(UIColor.darkGray, for: .normal)
                cell.btnJoin.setTitle("+ Join", for: .normal)
            }
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Index = indexPath.row
        tblUserList.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    
    @objc func btnJoin(_ sender: UIButton) {
        self.displayAlertMessage(messageToDisplay: "Under Development")
    }

    //MARK:- Button Actions
    
    @IBAction func btnBack(_ sender: Any){
        self.navigationController?.popViewController(animated: true)
    }

}
