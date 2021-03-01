//
//  Broadcast_RequestVC.swift
//  CA7S
//

import UIKit

class Broadcast_RequestVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tblUserList: UITableView!

    var ArrImgUser = NSMutableArray()
    var ArrUsername = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SetUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func SetUI() {
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    //MARK:- Table Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10 //ArrUsername.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:Broadcast_Request_TBLCell = tableView.dequeueReusableCell(withIdentifier: "Broadcast_Request_TBLCell") as! Broadcast_Request_TBLCell
        
        cell.selectionStyle = .none
        
        cell.lblUsername.text = "Mac Arora"//ArrUsername[indexPath.row] as? String
        
        cell.btnAccept.layer.cornerRadius = cell.btnAccept.frame.size.height / 2
        cell.btnAccept.clipsToBounds = true
        cell.btnDecline.layer.cornerRadius = cell.btnDecline.frame.size.height / 2
        cell.btnDecline.clipsToBounds = true
        
        cell.btnAccept.addTarget(self, action: #selector(btnAccept(_:)), for: .touchUpInside)
        cell.btnDecline.addTarget(self, action: #selector(btnDecline(_:)), for: .touchUpInside)
        
        cell.imgUser.image = UIImage(named: "profile_user") //UIImage(named: (ArrImgUser[indexPath.row] as? String)!)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    
    @objc func btnAccept(_ sender: UIButton) {
        self.displayAlertMessage(messageToDisplay: "Request acceped")
    }
    
    @objc func btnDecline(_ sender: UIButton) {
        self.displayAlertMessage(messageToDisplay: "Request declined")
    }
    
    //MARK:- Button Actions
    
    @IBAction func btnBack(_ sender: Any){
        self.navigationController?.popViewController(animated: true)
    }
    
}
