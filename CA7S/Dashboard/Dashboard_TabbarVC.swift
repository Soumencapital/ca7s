//
//  Dashboard_TabbarVC.swift
//  CA7S
//

import UIKit

class Dashboard_TabbarVC: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        //     self.tabBarController?.viewControllers?.remove(at:3)
        
        
        if let tabBarController = self.tabBarController {
            let indexToRemove = 3
            if indexToRemove < (tabBarController.viewControllers?.count)! {
                var viewControllers = tabBarController.viewControllers
                viewControllers?.remove(at: indexToRemove)
                tabBarController.viewControllers = viewControllers
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBar.items![0].title = NSLocalizedString("Discover", comment: "")
        self.tabBar.items![1].title = NSLocalizedString("Recognize", comment: "")
        self.tabBar.items![2].title = NSLocalizedString("Downloads", comment: "")
        self.tabBar.items![3].title = NSLocalizedString("Favourites", comment: "")
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
