//
//  TweetMockRepository.swift
//  BellTwitter
//
//  Created by Ronit Banze on 2019-10-05.
//  Copyright © 2019 Ronit Banze. All rights reserved.
//

import Foundation

class TweetMockRepository: TweetRepositoryProtocol {
    
    init() {
        
    }
    
    var tweetsList: [Tweet] = []
    
    func addTweet(dictionary: [String: Any]) {
        
        tweetsList.append(Tweet(dictionary: dictionary))
    }
    
    func getTweets() -> [Tweet] {
        return tweetsList
    }
    
}
