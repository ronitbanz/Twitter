//
//  Tweet.swift
//  BellTwitter
//
//  Created by Ronit Banze on 2019-10-05.
//  Copyright © 2019 Ronit Banze. All rights reserved.
//

import Foundation

class Tweet : Codable {
    
    // Properties
    var id: Int64? // For favoriting, retweeting & replying
    var text: String? // Text content of tweet
    var favoriteCount: Int? // Update favorite count label
    var favorited: Bool? // Configure favorite button
    var retweetCount: Int? // Update favorite count label
    var retweeted: Bool? // Configure retweet button
    var user: User? // Author of the Tweet
    var createdAtString: String? // String representation of date posted
    var photoUrl: String? // String representation of photo url
    var videoUrl: String? // String representation of video url
    var latitude: Double? // Double representation of latitude
    var longitude: Double? // Double representation of longitude
    
    // For Retweets
    var retweetedByUser: User?  // user who retweeted if tweet is retweet
    
    init(dictionary: [String: Any]) {
        var dictionary = dictionary
        
        // Is this a re-tweet?
        if let originalTweet = dictionary["retweeted_status"] as? [String: Any] {
            let userDictionary = dictionary["user"] as! [String: Any]
            self.retweetedByUser = User(dictionary: userDictionary)
            
            // Change tweet to original tweet
            dictionary = originalTweet
        }
        
        id = dictionary["id"] as? Int64
        text = dictionary["text"] as? String
        favoriteCount = dictionary["favorite_count"] as? Int
        favorited = dictionary["favorited"] as? Bool
        retweetCount = dictionary["retweet_count"] as? Int
        retweeted = dictionary["retweeted"] as? Bool
        
        // set user
        let user = dictionary["user"] as! [String: Any]
        self.user = User(dictionary: user)
        
        // Format createdAt date string
        let createdAtOriginalString = dictionary["created_at"] as! String
        let formatter = DateFormatter()
        // Configure the input format to parse the date string
        formatter.dateFormat = "E MMM d HH:mm:ss Z y"
        // Convert String to Date
        let date = formatter.date(from: createdAtOriginalString)!
        // Configure output format
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        // Convert Date to String and set the createdAtString property
        createdAtString = formatter.string(from: date)
        
        //Configuring coordinates from coordinates,place and geo in dictionary
        if (((dictionary as NSDictionary).value(forKey: "coordinates")) is NSNull == false) {
            let coordinates = ((((((dictionary as NSDictionary).value(forKey: "coordinates"))as! NSDictionary).value(forKey: "coordinates"))as! NSArray))
            latitude = coordinates[1] as? Double
            longitude = coordinates[0] as? Double
        } else if (((dictionary as NSDictionary).value(forKey: "place")) is NSNull == false) {
            let place = ((((((((((dictionary as NSDictionary).value(forKey: "place"))as! NSDictionary).value(forKey: "bounding_box"))as! NSDictionary).value(forKey: "coordinates"))as! NSArray))[0] as! NSArray)[0] as! NSArray)
            latitude = place[1] as? Double
            longitude = place[0] as? Double
        } else if (((dictionary as NSDictionary).value(forKey: "geo")) is NSNull == false) {
            let geo = ((((((dictionary as NSDictionary).value(forKey: "geo"))as! NSDictionary).value(forKey: "coordinates"))as! NSArray))
            latitude          = geo[1] as? Double
            longitude         = geo[0] as? Double
        }
        
        // For Photo Url
        if (((dictionary as NSDictionary).value(forKey: "entities")) is NSNull == false) {
            if (((((dictionary as NSDictionary).value(forKey: "entities"))as! NSDictionary).value(forKey: "media")) is NSNull == false) {
                if let media = ((((dictionary as NSDictionary).value(forKey: "entities"))as! NSDictionary).value(forKey: "media")) {
                    let type = ((((media as! NSArray)[0] as! NSDictionary).value(forKey: "type"))as! String)
                    if type == "photo" {
                        photoUrl = (((((((dictionary as NSDictionary).value(forKey: "entities"))as! NSDictionary).value(forKey: "media"))as! NSArray)[0] as! NSDictionary).value(forKey: "media_url_https"))as? String
                    }
                }
            }
        }
        
        //For video url
        if (((dictionary as NSDictionary).value(forKey: "extended_entities")) is NSNull == false) {
            let extendedEntity = ((dictionary as NSDictionary).value(forKey: "extended_entities"))
            if extendedEntity != nil {
                if (((((dictionary as NSDictionary).value(forKey: "extended_entities"))as! NSDictionary).value(forKey: "media")) is NSNull == false) {
                    if let media = ((((dictionary as NSDictionary).value(forKey: "extended_entities"))as! NSDictionary).value(forKey: "media")) {
                        let type = ((((media as! NSArray)[0] as! NSDictionary).value(forKey: "type"))as! String)
                        if type == "video" {
                            videoUrl = ((((((((((((dictionary as NSDictionary).value(forKey: "extended_entities"))as! NSDictionary).value(forKey: "media"))as! NSArray)[0] as! NSDictionary).value(forKey: "video_info"))as! NSDictionary).value(forKey: "variants"))as! NSArray)[0] as! NSDictionary).value(forKey: "url"))as? String
                        }
                    }
                }
            }
        }
    }
    
    static func tweets(with array: [[String: Any]]) -> [Tweet] {
        var tweets: [Tweet] = []
        for tweetDictionary in array {
            let tweet = Tweet(dictionary: tweetDictionary)
            tweets.append(tweet)
        }
        return tweets
    }
    
}
