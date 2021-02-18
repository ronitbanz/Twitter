//
//  TweetDomain.swift
//  BellTwitter
//
//  Created by Ronit Banze on 2019-10-05.
//  Copyright © 2019 Ronit Banze. All rights reserved.
//

import Foundation
class TweetDomain {
    
    var tweetRemoteRepository: TweetRepositoryProtocol?
    
    init(tweetRemoteRepository: TweetRepositoryProtocol) {
        self.tweetRemoteRepository = tweetRemoteRepository
    }
    
    func addTweet(dictionary: [String: Any]) {
        tweetRemoteRepository?.addTweet(dictionary: dictionary)
    }
    
    func getTweets() -> [Tweet]{
        return tweetRemoteRepository!.getTweets()
    }
    
}
