# DataStore
Simple CoreData setup.

## What's Inside
- CoreData stack setup
- Root context on a background thread
- Main context on the main thread (parent is the Root Context)
- Ability to get editing contexts (main thread child contexts of the main context)
- Ability to get Background Contexts (background thread child contexts of the main context)

## Usage

### Initialization
If you're happy with the default options (see options below), then all you need to get core data up and running is:

```swift
let dataStore = DataStore(storeName: "WhattaStore", managedObjectModelName: "WhattaManagedObjectModel")

do {
  try dataStore.setup()
}
catch let error {
  print("Uh oh: \(error)")
}
```

### Options
Any of these can be provided to the DataStore's intializer (some have default values):

```swift
storeName: String,
storeType: String = NSSQLiteStoreType,
storeExtension: String = ".sqlite",
managedObjectModelName: String,
storeOptions: [NSObject : AnyObject], // see defaults below
excludeStoreFromiCloudBackup: Bool = true
```

#### Default Store Options
The default store options:  
1) Infer the mapping model automatically for lightweight migrations  
2) Disable file protection  
3) Set the journal mode to write ahead logging  

```swift
[
    NSMigratePersistentStoresAutomaticallyOption : true,
    NSInferMappingModelAutomaticallyOption : true,
    NSPersistentStoreFileProtectionKey : NSFileProtectionNone,
    "journal_mode" : "WAL"
]
```

