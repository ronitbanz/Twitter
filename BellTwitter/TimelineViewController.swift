//
//  TimelineViewController.swift
//  BellTwitter
//
//  Created by Ronit Banze on 2019-10-05.
//  Copyright © 2019 Ronit Banze. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tweetViewModels: [TweetViewModel] = []
    var searchController = UISearchController()
    
    var searchText: String? {
        didSet {
            
            searchController.searchBar.text = searchText
            searchController.searchBar.placeholder = searchText
            
            tweetViewModels.removeAll()
            tableView.reloadData()
            fetchTimeline(searchString: (searchText!.lowercased()))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.dataSource = self
        
        setupSearchController()
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = NSLocalizedString("searchTwitter", comment: "")
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
    }
    
    
    func fetchTimeline(searchString: String) {
        APIManager.shared.searchTweets(searchString: searchString, latitude: 0, longitude: 0, distanceFilter: "") { (tweets: [Tweet]?, error: Error?) in
            if let tweets = tweets {
                self.tweetViewModels = tweets.map({return TweetViewModel(tweetModel: $0)}) 
                self.tableView.reloadData()
            } else {
                let alertController = UIAlertController(title: NSLocalizedString("error", comment: ""), message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: UIAlertAction.Style.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweetViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.tweetViewModel = self.tweetViewModels[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            let tweetCell = sender as! UITableViewCell
            if let indexPath = self.tableView.indexPath(for: tweetCell) {
                let tweetViewModel = self.tweetViewModels[indexPath.row]
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.tweetViewModel = tweetViewModel
            }
        }
    }
    
}

extension TimelineViewController : UISearchBarDelegate
{
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if searchBar == searchController.searchBar {
            searchBar.placeholder = NSLocalizedString("searchTwitter", comment: "")
        }
        
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar == searchController.searchBar {
            searchText = searchBar.text
            searchController.isActive = false
        }
    }
}
