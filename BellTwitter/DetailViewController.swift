//
//  DetailViewController.swift
//  BellTwitter
//
//  Created by Ronit Banze on 2019-10-05.
//  Copyright © 2019 Ronit Banze. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailView: DetailView!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    /**
    Set a tweet to shown in detail
    */
    var tweetViewModel: TweetViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailView.tweetViewModel = tweetViewModel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        logoutButtonVisibility()
    }
    
    @objc func logoutButtonVisibility() {
        if (User.current == nil) {
            self.navigationItem.rightBarButtonItem = nil
        }
        else {
            self.navigationItem.rightBarButtonItem = self.logoutButton
        }
    }
    
    @IBAction func didTapLogout(_ sender: Any) {
        APIManager.logout()
        logoutButtonVisibility()
    }
}
