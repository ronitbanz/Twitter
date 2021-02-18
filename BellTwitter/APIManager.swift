//
//  APIManager.swift
//  BellTwitter
//
//  Created by Ronit Banze on 2019-10-05.
//  Copyright © 2019 Ronit Banze. All rights reserved.
//

import Foundation
import Alamofire
import OAuthSwift
import OAuthSwiftAlamofire
import KeychainAccess

class APIManager: SessionManager {
    
    static let requestTokenURL = "https://api.twitter.com/oauth/request_token"
    static let authorizeURL = "https://api.twitter.com/oauth/authorize"
    static let accessTokenURL = "https://api.twitter.com/oauth/access_token"
    static let callbackURLString = "twitterkit-yeyWpA11zS3GOUSuMq0X1IwvV://"
    
    /**
    Needed if user favorites, retweets or the opposite
    */
    func login(success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        
        // Add callback url to open app when returning from Twitter login on web
        let callbackURL = URL(string: APIManager.callbackURLString)!
        oauthManager.authorize(withCallbackURL: callbackURL, success: { (credential, _response, parameters) in
            
            // Save Oauth tokens
            self.save(credential: credential)
            
            self.getCurrentAccount(completion: { (user, error) in
                if let error = error {
                    failure(error)
                } else if let user = user {
                    print("Welcome \(user.name ?? "user")")
                    
                    // set User.current, so that it's persisted
                    User.current = user
                    
                    success()
                }
            })
        }) { (error) in
            failure(error)
        }
    }
    
    /**
    Sets user to nil and clears credentials
    */
    static func logout() {
        // 1. Clear current user
        User.current = nil
        
        // 2. Deauthorize OAuth tokens
        shared.clearCredentials() // TODO: not sure if i'm doing this correctly
    }
    
    
    func getCurrentAccount(completion: @escaping (User?, Error?) -> ()) {
        request(URL(string: "https://api.twitter.com/1.1/account/verify_credentials.json")!)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .failure(let error):
                    completion(nil, error)
                    break;
                case .success:
                    guard let userDictionary = response.result.value as? [String: Any] else {
                        completion(nil, JSONError.parsing("Unable to create user dictionary"))
                        return
                    }
                    completion(User(dictionary: userDictionary), nil)
                }
        }
    }
    
    /**
    Searches tweet needs latitude, longitude or searchstring

    - Throws: Exception

    - Returns: Success
    */
    func searchTweets(searchString: String, latitude: Double, longitude: Double, distanceFilter: String, completion: @escaping ([Tweet]?, Error?) -> ()) {
        
        //This uses one of the many ways to use tweets from disk to avoid hitting rate limit. Comment out if you want fresh
        // tweets
        
        /*
         if let data = UserDefaults.standard.object(forKey: "hometimeline_tweets") as? Data {
         do {
         let tweetDictionaries = try  NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! [[String: Any]]
         let tweets = tweetDictionaries.compactMap({ (dictionary) -> Tweet in
         Tweet(dictionary: dictionary)
         })
         
         completion(tweets, nil)
         return
         } catch {
         //return
         }
         }
         */
        var parameters : Parameters = [:]
        if (searchString != "")
        {
            parameters = ["q": searchString, "count": "100"]
        }
        else{
            parameters = ["geocode": "\(String(describing: latitude)),\(String(describing: longitude)),\(String(describing: distanceFilter))km", "count": "100"]
        }
        
        request(URL(string: "https://api.twitter.com/1.1/search/tweets.json")!, method: .get, parameters: parameters)
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .failure(let error):
                    completion(nil, error)
                    return
                case .success:
                    let statuses = ((response.result.value as! NSDictionary).value(forKey: "statuses"))
                    guard let tweetDictionaries = statuses as? [[String: Any]] else {
                        print("Failed to parse tweets")
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Failed to parse tweets"])
                        completion(nil, error)
                        return
                    }
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: tweetDictionaries, requiringSecureCoding: true)
                        UserDefaults.standard.set(data, forKey: "hometimeline_tweets")
                    } catch {
                        //return
                    }
                    UserDefaults.standard.synchronize()
                    let tweets = tweetDictionaries.compactMap({ (dictionary) -> Tweet in
                        Tweet(dictionary: dictionary)
                    })
                    completion(tweets, nil)
                }
        }
    }
    
    /**
    Favorites a tweet needs tweet id

    - Throws: Exception

    - Returns: Success
    */
    func favorite(_ tweet: Tweet, completion: @escaping (Tweet?, Error?) -> ()) {
        let urlString = "https://api.twitter.com/1.1/favorites/create.json"
        let parameters = ["id": tweet.id]
        request(urlString, method: .post, parameters: parameters as Parameters, encoding: URLEncoding.queryString).validate().responseJSON { (response) in
            if response.result.isSuccess,
                let tweetDictionary = response.result.value as? [String: Any] {
                let tweet = Tweet(dictionary: tweetDictionary)
                completion(tweet, nil)
            } else {
                completion(nil, response.result.error)
            }
        }
    }
    
    /**
    Un-Favorites a tweet needs tweet id

    - Throws: Exception

    - Returns: Success
    */
    func unfavorite(_ tweet: Tweet, completion: @escaping (Tweet?, Error?) -> ()) {
        let urlString = "https://api.twitter.com/1.1/favorites/destroy.json"
        let parameters = ["id": tweet.id]
        request(urlString, method: .post, parameters: parameters as Parameters, encoding: URLEncoding.queryString).validate().responseJSON { (response) in
            if response.result.isSuccess,
                let tweetDictionary = response.result.value as? [String: Any] {
                let tweet = Tweet(dictionary: tweetDictionary)
                completion(tweet, nil)
            } else {
                completion(nil, response.result.error)
            }
        }
    }
    
    /**
    Retweets a tweet needs tweet id

    - Throws: Exception

    - Returns: Success
    */
    func retweet(_ tweet: Tweet, completion: @escaping (Tweet?, Error?) -> ()) {
        let baseURL = "https://api.twitter.com/1.1/statuses/retweet/"
        let parameters = ["id": tweet.id]
        let id = parameters["id"] // Int64
        let idString = String(id!!) // Create string id
        let urlString = baseURL + idString + ".json" // Concatenate
        
        request(urlString, method: .post, parameters: parameters as Parameters, encoding: URLEncoding.queryString).validate().responseJSON { (response) in
            if response.result.isSuccess,
                let tweetDictionary = response.result.value as? [String: Any] {
                let tweet = Tweet(dictionary: tweetDictionary)
                completion(tweet, nil)
            } else {
                completion(nil, response.result.error)
            }
        }
    }
    
    /**
    Un-Retweet a tweet needs tweet id

    - Throws: Exception

    - Returns: Success
    */
    func unretweet(_ tweet: Tweet, completion: @escaping (Tweet?, Error?) -> ()) {
        let baseURL = "https://api.twitter.com/1.1/statuses/unretweet/"
        let parameters = ["id": tweet.id]
        let id = parameters["id"] // Int64
        let idString = String(id!!) // Create string id
        let urlString = baseURL + idString + ".json" // Concatenate
        
        request(urlString, method: .post, parameters: parameters as Parameters, encoding: URLEncoding.queryString).validate().responseJSON { (response) in
            if response.result.isSuccess,
                let tweetDictionary = response.result.value as? [String: Any] {
                let tweet = Tweet(dictionary: tweetDictionary)
                completion(tweet, nil)
            } else {
                completion(nil, response.result.error)
            }
        }
    }
    
    static var shared: APIManager = APIManager()
    
    var oauthManager: OAuth1Swift!
    
    private init() {
        super.init()
        
        // Create an instance of OAuth1Swift with credentials and oauth endpoints
        oauthManager = OAuth1Swift(
            consumerKey: "jySI3Cfegh9OxSLRWN68YVvDW",
            consumerSecret: "C0brvuJMplUOzYS6XMV52ziPEGUSKZFP2DmruU8KmVINcSj8ZH",
            requestTokenUrl: APIManager.requestTokenURL,
            authorizeUrl: APIManager.authorizeURL,
            accessTokenUrl: APIManager.accessTokenURL
        )
        
        // Retrieve access token from keychain if it exists
        if let credential = retrieveCredentials() {
            oauthManager.client.credential.oauthToken = credential.oauthToken
            oauthManager.client.credential.oauthTokenSecret = credential.oauthTokenSecret
            print(credential.oauthToken)
            print(credential.oauthTokenSecret)
        }
        
        // Assign oauth request adapter to Alamofire SessionManager adapter to sign requests
        adapter = oauthManager.requestAdapter
    }
    
    // Handle url
    // Finish oauth process by fetching access token
    func handle(url: URL) {
        OAuth1Swift.handle(url: url)
    }
    
    // Save Tokens in Keychain
    private func save(credential: OAuthSwiftCredential) {
        
        // Store access token in keychain
        let keychain = Keychain()
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: credential, requiringSecureCoding: true)
            keychain[data: "twitter_credentials"] = data
        } catch {
            //
        }
    }
    
    // Retrieve Credentials
    private func retrieveCredentials() -> OAuthSwiftCredential? {
        let keychain = Keychain()
        
        if let data = keychain[data: "twitter_credentials"] {
            do {
                let credential = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! OAuthSwiftCredential
                return credential
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    // Clear tokens in Keychain
    private func clearCredentials() {
        // Store access token in keychain
        let keychain = Keychain()
        do {
            try keychain.remove("twitter_credentials")
        } catch let error {
            print("error: \(error)")
        }
    }
    
}

enum JSONError: Error {
    case parsing(String)
}
