# DataStore
Simple CoreData setup for iOS.

## Usage

### Initialization
If you're happy with the default options (see options below), then all you need to get CoreData up and running is:

```swift
let dataStore = DataStore(
  storeName: "WhattaStore", 
  managedObjectModelName: "WhattaManagedObjectModel"
)

do {
  try dataStore.setup()
}
catch let error {
  print("Uh oh: \(error)")
}
```

### Available Properties and Methods
The parent / child context setup can be used out of the box for most applications. Feel free to extend the `CoreDataStore` protocol to add more functionality.

#### Contexts
- `mainContext` is for all of your read-only UI needs
- `newEditingContext()` is for user input on the main thread
- `newBackgroundContext()` is for computationally intensive tasks

#### Methods
- `func setup() throws` sets up the stack and throws a `CoreDataStoreError` if something goes wrong
- `func save(context: NSManagedObjectContext?) throws`
- `func purge() throws` resets the main and root contexts and deletes the store files
- `func delete() throws` deletes the store files

### Options
Any of these can be provided to the DataStore's intializer (some have default values):

```swift
storeName: String,
storeType: String = NSSQLiteStoreType,
storeExtension: String = ".sqlite",
managedObjectModelName: String,
storeOptions: [NSObject : AnyObject] = DataStore.defaultStoreOptions, // see defaults below
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

