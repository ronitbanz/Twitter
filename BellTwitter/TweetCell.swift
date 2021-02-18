//
//  TweetCell.swift
//  BellTwitter
//
//  Created by Ronit Banze on 2019-10-05.
//  Copyright © 2019 Ronit Banze. All rights reserved.
//

import UIKit
import WebKit
import AlamofireImage

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleAndcreatedAtLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var replyCountLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var mediaImageVIew: UIImageView!
    
    
    @IBOutlet weak var mediaImageVIewHeightContraint: NSLayoutConstraint!
    private var defaultMediaImageViewHeightContraint : CGFloat!
    
    var tweetViewModel: TweetViewModel! {
        willSet(newTweetViewModel) {
            
            // user
            if let profileImageURL = newTweetViewModel.tweet?.user?.profileImageURL {
                print(profileImageURL)
                profileImageView.af_setImage(withURL: profileImageURL)
            }
            nameLabel.text = newTweetViewModel.tweet?.user?.name
            
            var handleAndCreatedString = ""
            if let screenName = newTweetViewModel.tweet?.user?.screenName {
                handleAndCreatedString += screenName
            }
            if let createdAt = newTweetViewModel.tweet?.createdAtString {
                handleAndCreatedString += " " + createdAt
            }
            handleAndcreatedAtLabel.text = handleAndCreatedString
            
            tweetTextLabel.text = newTweetViewModel.tweet?.text
            
            // reply
            replyButton.setImage(UIImage(named: "reply-icon"), for: .normal)
            replyCountLabel.text = String(newTweetViewModel.tweet!.retweetCount!)
            
            // retweet
            retweetButton.setImage(UIImage(named: "retweet-icon"), for: .normal)
            retweetButton.setImage(UIImage(named: "retweet-icon-green"), for: .selected)
            retweetCountLabel.text = String(newTweetViewModel.tweet!.retweetCount!)
            
            // favorite
            favoriteButton.setImage(UIImage(named: "favor-icon"), for: .normal)
            favoriteButton.setImage(UIImage(named: "favor-icon-red"), for: .selected)
            favoriteCountLabel.text = String(newTweetViewModel.tweet!.favoriteCount!)
            
            
            if (newTweetViewModel.isPhotoTweet!) {
                if (newTweetViewModel.isVideoTweet!) {
                    let request: URLRequest = URLRequest(url: URL(string: newTweetViewModel.tweet!.photoUrl!)!)
                    let session = URLSession.shared
                    let task = session.dataTask(with: request as URLRequest, completionHandler: { (data,response,error) -> Void in
                        if error == nil {
                            if data!.count > 0 {
                                DispatchQueue.main.async {
                                    //caching images for next time
                                    let imageToCache = UIImage(data: data!)
                                    self.mediaImageVIew.image = self.drawImage(image: UIImage(named: "play-icon")!, inImage: imageToCache!)
                                }
                            }
                        }
                    })
                    task.resume()
                } else {
                    mediaImageVIew.af_setImage(withURL: URL(string: newTweetViewModel.tweet!.photoUrl!)!)
                }
            } else {
                mediaImageVIew?.image = nil
                defaultMediaImageViewHeightContraint = mediaImageVIewHeightContraint.constant
                mediaImageVIewHeightContraint.constant = 0
                layoutIfNeeded()
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageViewTapAction(_:)))
            mediaImageVIew.addGestureRecognizer(tapGesture)
        }
    }
    
    func drawImage(image foreGroundImage:UIImage, inImage backgroundImage:UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(backgroundImage.size, false, 0.0)
        backgroundImage.draw(in: CGRect.init(x: 0, y: 0, width: backgroundImage.size.width, height: backgroundImage.size.height))
        foreGroundImage.draw(in: CGRect.init(x: backgroundImage.size.width/4, y: backgroundImage.size.height/4, width: backgroundImage.size.width/2, height: backgroundImage.size.height/2))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    @objc func imageViewTapAction(_ sender: UITapGestureRecognizer) {
        let webV = WKWebView(frame: self.frame)
        
        if (tweetViewModel.isVideoTweet!) {
            //play video
            webV.load(URLRequest(url: URL(string: tweetViewModel.tweet!.videoUrl!)!))
            self.addSubview(webV)
        }
        else if (tweetViewModel.isPhotoTweet!) {
            //show photo
            let imageView = sender.view as! UIImageView
            let newImageView = UIImageView(frame: UIScreen.main.bounds)
            newImageView.image = imageView.image
            newImageView.backgroundColor = .black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullscreenImage(_:)))
            newImageView.addGestureRecognizer(tap)
            self.tableView?.superview?.addSubview(newImageView)
            if let tableViewController = self.tableView?.parentViewController as? TimelineViewController {
                tableViewController.navigationController?.isNavigationBarHidden = true
                tableViewController.tabBarController?.tabBar.isHidden = true
            }
            
        }
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
        if let tableViewController = self.tableView?.parentViewController as? TimelineViewController {
            tableViewController.navigationController?.isNavigationBarHidden = false
            tableViewController.tabBarController?.tabBar.isHidden = false
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.layer.masksToBounds = true
    }
    
    func refreshData() {
        
        // user
        if let profileImageURL = tweetViewModel.tweet?.user?.profileImageURL {
            print(profileImageURL)
            profileImageView.af_setImage(withURL: profileImageURL)
        }
        nameLabel.text = tweetViewModel.tweet?.user?.name
        var handleAndCreatedString = ""
        if let screenName = tweetViewModel.tweet?.user?.screenName {
            handleAndCreatedString += screenName
        }
        if let createdAt = tweetViewModel.tweet?.createdAtString {
            handleAndCreatedString += " " + createdAt
        }
        handleAndcreatedAtLabel.text = handleAndCreatedString
        
        tweetTextLabel.text = tweetViewModel.tweet?.text
        
        // reply
        replyCountLabel.text = String(tweetViewModel.tweet!.retweetCount!)
        
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if mediaImageVIewHeightContraint != nil && defaultMediaImageViewHeightContraint != nil {
            mediaImageVIewHeightContraint.constant = defaultMediaImageViewHeightContraint
        }
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
        // Update tweet
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
    
    func favorite() {
        // Update tweet
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
    
}

extension UIView {
    func parentView<T: UIView>(of type: T.Type) -> T? {
        guard let view = superview else {
            return nil
        }
        return (view as? T) ?? view.parentView(of: T.self)
    }
}

extension UITableViewCell {
    var tableView: UITableView? {
        return parentView(of: UITableView.self)
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
