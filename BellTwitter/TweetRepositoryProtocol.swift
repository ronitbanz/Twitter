//
//  TweetRepositoryProtocol.swift
//  BellTwitter
//
//  Created by Ronit Banze on 2019-10-05.
//  Copyright © 2019 Ronit Banze. All rights reserved.
//

import Foundation

protocol TweetRepositoryProtocol {
    
    func addTweet(dictionary: [String: Any])
    func getTweets() -> [Tweet]
    
}
