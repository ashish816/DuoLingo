//
//  ServiceCommunicator.swift
//  Duolingo Word Game
//
//  Created by Ashish Mishra on 7/16/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit

class ServiceCommunicator: NSObject {
    
    var gameDataSource : [LevelDataSource] = [LevelDataSource]()
    
    func fetchWordsGameTextFile(completionHandler : @escaping ([LevelDataSource]?, Error?) -> ()) {
        let messageURL = URL(string: "https://s3.amazonaws.com/duolingo-data/s3/js2/find_challenges.txt")
        let sharedSession = URLSession.shared
        
        let downloadTask : URLSessionDownloadTask = sharedSession.downloadTask(with: messageURL!) { (location, response, error) in
            if error == nil {
                
                do {
                    let urlContents = try NSString(contentsOf: location!, encoding: String.Encoding.utf8.rawValue)
                    let components = urlContents.components(separatedBy: "\n")
                    for aComponent in components {
                        let currentLevelDataSource = LevelDataSource(jsonString : aComponent)
                        self.gameDataSource.append(currentLevelDataSource)
                        
                    }
                    completionHandler(self.gameDataSource, nil)
                  
                }
                catch {
                    completionHandler(nil, error)
                }
            }
        }
        downloadTask.resume()
    }

}
