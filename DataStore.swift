//
//  DataStore.swift
//  Construct
//
//  Created by Christian Bator on 3/21/17.
//  Copyright © 2017 jcbator. All rights reserved.
//

import Foundation
import CoreData

class DataStore: CoreDataStore {
    
    let storeName: String
    let storeType: String
    let storeExtension: String
    let storeOptions: [NSObject : AnyObject]
    let excludeStoreFromiCloudBackup: Bool
    
    let managedObjectModelName: String
    
    static let defaultStoreOptions: [NSObject : AnyObject] = [
        NSMigratePersistentStoresAutomaticallyOption : true,
        NSInferMappingModelAutomaticallyOption : true,
        NSPersistentStoreFileProtectionKey : NSFileProtectionNone,
        "journal_mode" : "WAL"
    ]
    
    let mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    let rootContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    
    var persistentStore: NSPersistentStore?
    var persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    init(storeName: String,
         storeType: String = NSSQLiteStoreType,
         storeExtension: String = ".sqlite",
         managedObjectModelName: String,
         storeOptions: [NSObject : AnyObject] = DataStore.defaultStoreOptions,
         excludeStoreFromiCloudBackup: Bool = true) {
        
        self.storeName = storeName
        self.storeType = storeType
        self.storeExtension = storeExtension
        self.managedObjectModelName = managedObjectModelName
        self.storeOptions = storeOptions
        self.excludeStoreFromiCloudBackup = excludeStoreFromiCloudBackup
    }
}
