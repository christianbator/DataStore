//
//  CoreDataStore.swift
//  Construct
//
//  Created by Christian Bator on 3/21/17.
//  Copyright © 2017 jcbator. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataStoreError: ErrorType {
    
    case managedObjectModelNotFound
    case managedObjectModelCreationFailure
    case duplicateSetupInvoked
}

protocol CoreDataStore: class {
    
    var storeName: String { get }
    var storeType: String { get }
    var storeExtension: String { get }
    var storeOptions: [NSObject : AnyObject] { get }
    var excludeStoreFromiCloudBackup: Bool { get }
    
    var managedObjectModelName: String { get }
    
    
    // MARK: Defaults Provided
    
    var storeURL: NSURL { get }
    var managedObjectModelExtension: String { get }
    
    
    // MARK: Public Interface
    
    func setup() throws
    func save(context: NSManagedObjectContext?) throws
    func purge() throws
    func delete() throws
    
    var mainContext: NSManagedObjectContext { get }
    var rootContext: NSManagedObjectContext { get }
    
    func newEditingContext() -> NSManagedObjectContext
    func newBackgroundContext() -> NSManagedObjectContext
    
    var persistentStore: NSPersistentStore? { get set }
    var persistentStoreCoordinator: NSPersistentStoreCoordinator? { get set }
    
    func managedObjectIDForURIRepresentation(url: NSURL) -> NSManagedObjectID?
}

extension CoreDataStore {
    
    var storeURL: NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let docURL = urls[urls.endIndex - 1]
        let storeURL = docURL.URLByAppendingPathComponent(storeName + storeExtension)!
        
        return storeURL
    }
    
    var managedObjectModelExtension: String {
        return "momd"
    }
    
    func newEditingContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.parentContext = mainContext
        
        return context
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.parentContext = mainContext
        
        return context
    }
    
    func setup() throws {
        let bundle = NSBundle(forClass: self.dynamicType)
        
        guard let modelURL = bundle.URLForResource(managedObjectModelName, withExtension: managedObjectModelExtension) else {
            throw CoreDataStoreError.managedObjectModelNotFound
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL) else {
            throw CoreDataStoreError.managedObjectModelCreationFailure
        }
        
        guard persistentStore == nil else {
            throw CoreDataStoreError.duplicateSetupInvoked
        }
        
        guard persistentStoreCoordinator == nil || persistentStoreCoordinator?.persistentStores.count == 0 else {
            throw CoreDataStoreError.duplicateSetupInvoked
        }
        
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        rootContext.persistentStoreCoordinator = persistentStoreCoordinator
        mainContext.parentContext = rootContext
        
        persistentStore = try persistentStoreCoordinator?.addPersistentStoreWithType(
            storeType,
            configuration: nil,
            URL: storeURL,
            options: storeOptions
        )
        
        try storeURL.setResourceValue(excludeStoreFromiCloudBackup, forKey: NSURLIsExcludedFromBackupKey)
    }
    
    func save(context: NSManagedObjectContext? = nil) throws {
        guard persistentStore != nil && persistentStoreCoordinator?.persistentStores.count > 0 else {
            return
        }
        
        var error: ErrorType?
        
        if let context = context where (context != mainContext && context != rootContext) {
            context.performBlockAndWait {
                do {
                    try context.save()
                }
                catch let coreDataError {
                    error = coreDataError
                }
            }
        }
        
        guard error == nil else {
            throw error!
        }
        
        mainContext.performBlockAndWait {
            do {
                try self.mainContext.save()
            }
            catch let coreDataError {
                error = coreDataError
            }
        }
        
        guard error == nil else {
            throw error!
        }
        
        rootContext.performBlockAndWait {
            do {
                try self.rootContext.save()
            }
            catch let coreDataError {
                error = coreDataError
            }
        }
        
        guard error == nil else {
            throw error!
        }
    }
    
    func purge() throws {
        guard let persistentStore = persistentStore else { return }
        
        rootContext.performBlockAndWait {
            self.rootContext.reset()
        }
        
        mainContext.performBlockAndWait {
            self.mainContext.reset()
        }
        
        try persistentStoreCoordinator?.removePersistentStore(persistentStore)
        self.persistentStore = nil
        
        try delete()
    }
    
    func delete() throws {
        try NSFileManager.defaultManager().removeItemAtURL(storeURL)
        
        if let journal_mode = storeOptions["journal_mode"] as? String where journal_mode == "wal" {
            if let walURL = storeURL.URLByAppendingPathComponent("-wal") {
                try NSFileManager.defaultManager().removeItemAtURL(walURL)
            }
            
            if let shmURL = storeURL.URLByAppendingPathComponent("-shm") {
                try NSFileManager.defaultManager().removeItemAtURL(shmURL)
            }
        }
    }
    
    func managedObjectIDForURIRepresentation(url: NSURL) -> NSManagedObjectID? {
        return persistentStoreCoordinator?.managedObjectIDForURIRepresentation(url)
    }
}
