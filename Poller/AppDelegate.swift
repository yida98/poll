//
//  AppDelegate.swift
//  Poller
//
//  Created by Yida Zhang on 2020-06-23.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        ViewModel.deleteAllRecords(of: RecordType.all)
        AppDelegate.decodeMockPolls()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    static private func decodeMockPolls() {
        let url = Bundle.main.url(forResource: "MockPolls", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decodedJSON = try! JSONSerialization.jsonObject(with: data, options: [])

        var polls: [Poll] = [Poll]()

        if let listOfPolls = decodedJSON as? [Dictionary<String, Any>] {
            for pollDictionary in listOfPolls {
                var title = ""
                var creator: CKRecord?
                var pollItems = Array<String>()
                for key in pollDictionary.keys {
                    switch(key){
                    case "title":
                        title = pollDictionary[key] as! String
                    case "creator":
                        guard let name = pollDictionary[key] as? String else {
                            fatalError("Poll Items not iterable")
                        }
                        creator = User.create(with: name)
                    case "pollItems":
                        guard let items = pollDictionary[key] as? Array<String> else {
                            fatalError("Poll Items not iterable")
                        }
                        pollItems = items
                    default:
                        break
                    }
                }
                let pollRecord = Poll.create(title: title, creator: creator!)
                var pollItemRecord = [CKRecord]()
                for item in pollItems {
                    pollItemRecord.append(PollItem.create(title: item, parent: pollRecord))
                    debugPrint("second")
                }
                let poll = Poll(record: pollRecord)
                poll.addPollItems(itemRecords: pollItemRecord)
                polls.append(poll)
            }
            ViewModel.mockPolls = polls
        }
    }


}

