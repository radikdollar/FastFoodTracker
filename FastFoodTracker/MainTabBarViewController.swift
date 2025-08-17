//
//  MainTabBarViewController.swift
//  EatTime
//
//  Created by Radion Vahromeev on 8/11/25.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        let vc1 = UINavigationController(rootViewController: HomeViewController())
        let vc2 = UINavigationController(rootViewController: EatTimeViewController())
        
        vc1.tabBarItem.image = UIImage(systemName: "house")
        vc2.tabBarItem.image = UIImage(systemName: "fork.knife.circle")

        vc1.title = "Home"
        vc2.title = "Eat Time"
        
        tabBar.tintColor = .label
        
        setViewControllers([vc1, vc2], animated: true)
    }


}
