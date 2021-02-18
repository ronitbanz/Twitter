//
//  DetailView.swift
//  BellTwitter
//
//  Created by Ronit Banze on 2019-10-05.
//  Copyright © 2019 Ronit Banze. All rights reserved.
//

import UIKit
import AlamofireImage

class DetailView: UIView {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    /**
    setter for tweet metadata
    */
    var tweetViewModel: TweetViewModel! {
        willSet(newTweetViewModel) {
            
            print("New tweet about to be set.")
            
            // user
            
            if let profileImageURL = newTweetViewModel.tweet?.user?.profileImageURL {
                print(profileImageURL)
                profileImageView.af_setImage(withURL: profileImageURL)
            }
            nameLabel.text = newTweetViewModel.tweet?.user?.name
            screenNameLabel.text = newTweetViewModel.tweet?.user?.screenName
            createdAtLabel.text = newTweetViewModel.tweet?.createdAtString
            
            tweetTextLabel.text = newTweetViewModel.tweet?.text
            
            // retweet
            retweetButton.setImage(UIImage(named: "retweet-icon"), for: .normal)
            retweetButton.setImage(UIImage(named: "retweet-icon-green"), for: .selected)
            retweetCountLabel.text = String(newTweetViewModel.tweet!.retweetCount!)
            
            // favorite
            favoriteButton.setImage(UIImage(named: "favor-icon"), for: .normal)
            favoriteButton.setImage(UIImage(named: "favor-icon-red"), for: .selected)
            favoriteCountLabel.text = String(newTweetViewModel.tweet!.favoriteCount!)
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.layer.masksToBounds = true
        
        tweetTextLabel.layer.cornerRadius = 4.0
        tweetTextLabel.layer.masksToBounds = true
    }
    
    func refreshData() {
        
        print("New tweet info about to be set.")
        
        // user
        if let profileImageURL = tweetViewModel.tweet?.user?.profileImageURL {
            print(profileImageURL)
            profileImageView.af_setImage(withURL: profileImageURL)
        }
        nameLabel.text = tweetViewModel.tweet?.user?.name
        screenNameLabel.text = tweetViewModel.tweet?.user?.screenName
        createdAtLabel.text = tweetViewModel.tweet?.createdAtString
        
        tweetTextLabel.text = tweetViewModel.tweet?.text
        
        // retweet
        if tweetViewModel.tweet!.retweeted! {
            retweetButton.isSelected = true
        } else {
            retweetButton.isSelected = false
        }
        retweetCountLabel.text = String(tweetViewModel.tweet!.retweetCount!)
        
        // favorite
        if tweetViewModel.tweet!.favorited! {
            favoriteButton.isSelected = true
        } else {
            favoriteButton.isSelected = false
        }
        favoriteCountLabel.text = String(tweetViewModel.tweet!.favoriteCount!)
    }
    
    @IBAction func didTapRetweet(_ sender: Any) {
        if let user = User.current {
            print(user)
            retweet()
        }
        else {
            APIManager.shared.login(success: {
                self.retweet()
            }) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func retweet() {
        // Updating tweet
        if !tweetViewModel.tweet!.retweeted! {
            tweetViewModel.tweet?.retweeted = true
            tweetViewModel.tweet?.retweetCount! += 1
            retweetButton.isSelected = true
        } else {
            tweetViewModel.tweet?.retweeted = false
            tweetViewModel.tweet?.retweetCount! -= 1
            retweetButton.isSelected = false
        }
        
        // Update cell
        self.refreshData()
        
        // POST to statuses/retweet or statuses/unretweet
        if (tweetViewModel.tweet!.retweeted!) {
            APIManager.shared.retweet(tweetViewModel.tweet!) { (tweet: Tweet?, error: Error?) in
                if let  error = error {
                    print("Error updating retweet status: \(error.localizedDescription)")
                } else if let tweet = tweet {
                    print("Successfully updated retweet status for the following Tweet: \n\(String(describing: tweet.text))")
                }
            }
        } else {
            APIManager.shared.unfavorite(tweetViewModel.tweet!) { (tweet: Tweet?, error: Error?) in
                if let  error = error {
                    print("Error updating unretweet status: \(error.localizedDescription)")
                } else if let tweet = tweet {
                    print("Successfully updated unretweet status for the following Tweet: \n\(String(describing: tweet.text))")
                }
            }
        }
    }
    
    @IBAction func didTapFavorite(_ sender: Any) {
        if let user = User.current {
            print(user)
            favorite()
        }
        else {
            APIManager.shared.login(success: {
                self.favorite()
            }) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func favorite() {
        // Updating tweet
        if !tweetViewModel.tweet!.favorited! {
            tweetViewModel.tweet?.favorited = true
            tweetViewModel.tweet?.favoriteCount! += 1
            favoriteButton.isSelected = true
        } else {
            tweetViewModel.tweet?.favorited = false
            tweetViewModel.tweet?.favoriteCount! -= 1
            favoriteButton.isSelected = true
        }
        
        // Update cell
        self.refreshData()
        
        // POST to favorites/create or favorites/destroy
        if (tweetViewModel.tweet!.favorited!) {
            APIManager.shared.favorite(tweetViewModel.tweet!) { (tweet: Tweet?, error: Error?) in
                if let  error = error {
                    print("Error favoriting tweet: \(error.localizedDescription)")
                } else if let tweet = tweet {
                    print("Successfully favorited the following Tweet: \n\(String(describing: tweet.text))")
                }
            }
        } else {
            APIManager.shared.unfavorite(tweetViewModel.tweet!) { (tweet: Tweet?, error: Error?) in
                if let  error = error {
                    print("Error unfavoriting tweet: \(error.localizedDescription)")
                } else if let tweet = tweet {
                    print("Successfully unfavorited the following Tweet: \n\(String(describing: tweet.text))")
                }
            }
        }
    }
    
}
