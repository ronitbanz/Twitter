//
//  TweetViewModel.swift
//  BellTwitter
//
//  Created by Ronit Banze on 2019-10-08.
//  Copyright © 2019 Ronit Banze. All rights reserved.
//

import Foundation

struct TweetViewModel {

    var tweet: Tweet?
    var hasCoordinates: Bool?
    var isVideoTweet: Bool?
    var isPhotoTweet: Bool?
    
    // Dependency Injection (DI)
    init(tweetModel: Tweet) {
        tweet = tweetModel
        
        if (tweetModel.latitude != nil && tweetModel.longitude != nil) {
            hasCoordinates = true
        }
        else {
            hasCoordinates = false
        }
        
        if tweetModel.videoUrl != nil {
            isVideoTweet = true
        }
        else {
            isVideoTweet = false
        }
        
        if tweetModel.photoUrl != nil {
            isPhotoTweet = true
            
        }
        else {
            isPhotoTweet = false
        }
    }
    
}
