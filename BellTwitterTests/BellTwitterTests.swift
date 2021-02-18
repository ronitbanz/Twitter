//
//  BellTwitterTests.swift
//  BellTwitter
//
//  Created by Ronit Banze on 2019-10-05.
//  Copyright © 2019 Ronit Banze. All rights reserved.
//

import XCTest
import UIKit
@testable import BellTwitter

class BellTwitterTests: XCTestCase {
    
    func testGetTweets() {

        let tweetMockRepository: TweetMockRepository = TweetMockRepository()
        let domain: TweetDomain = TweetDomain(tweetRemoteRepository: tweetMockRepository)
        let url = Bundle.main.url(forResource: "data", withExtension: "json")
        let data = NSData(contentsOf: url!)

        do {
            let object = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
            
            if let dictionary = object as? [String: AnyObject] {
                domain.addTweet(dictionary: dictionary)
            }
        } catch {
            print(error)
        }
        
        let tweetList: [Tweet] = domain.getTweets()
        let tweetViewModels = tweetList.map({return TweetViewModel(tweetModel: $0)})
        //Check to see if adding tweet works with mock data
        XCTAssertEqual(1, tweetViewModels.count)
    }
    
    func testPhotoOrVideoTweet() {

        let tweetMockRepository: TweetMockRepository = TweetMockRepository()
        let domain: TweetDomain = TweetDomain(tweetRemoteRepository: tweetMockRepository)
        let url = Bundle.main.url(forResource: "data", withExtension: "json")
        let data = NSData(contentsOf: url!)

        do {
            let object = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
            
            if let dictionary = object as? [String: AnyObject] {
                domain.addTweet(dictionary: dictionary)
            }
        } catch {
            print(error)
        }
        
        let tweetList: [Tweet] = domain.getTweets()
        let tweetViewModels = tweetList.map({return TweetViewModel(tweetModel: $0)})
        //Check to see if adding tweet works with mock data
        XCTAssertFalse(tweetViewModels[0].isPhotoTweet!)
        XCTAssertFalse(tweetViewModels[0].isVideoTweet!)
    }
    
    func testHasCoordinatesTweet() {

        let tweetMockRepository: TweetMockRepository = TweetMockRepository()
        let domain: TweetDomain = TweetDomain(tweetRemoteRepository: tweetMockRepository)
        let url = Bundle.main.url(forResource: "data", withExtension: "json")
        let data = NSData(contentsOf: url!)

        do {
            let object = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
            
            if let dictionary = object as? [String: AnyObject] {
                domain.addTweet(dictionary: dictionary)
            }
        } catch {
            print(error)
        }
        
        let tweetList: [Tweet] = domain.getTweets()
        let tweetViewModels = tweetList.map({return TweetViewModel(tweetModel: $0)})
        //Check to see if adding tweet works with mock data
        XCTAssertFalse(tweetViewModels[0].hasCoordinates!)
    }
}
