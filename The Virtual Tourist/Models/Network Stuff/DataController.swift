//
//  DataController.swift
//  The Virtual Tourist
//
//  Created by Venkata Sai Pavan Teja Kona on 19/03/23.
//

import Foundation
import CoreData

class DataController{
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    var backGroundContext: NSManagedObjectContext{
        return persistentContainer.newBackgroundContext()
    }
    
    init(modelName:String) {
        self.persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func configureContexts(){
        viewContext.automaticallyMergesChangesFromParent = true
        backGroundContext.automaticallyMergesChangesFromParent = true
        
        backGroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (()->Void)? = nil){
        
        persistentContainer.loadPersistentStores { (storesDescription, error) in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
}

extension DataController{
    func autoSaveViewContext(interval: TimeInterval = 30){
        print("AutoSaving")
        guard interval > 0 else{
            print("Cannot set negative autosave intervals")
            return
        }
        
        if viewContext.hasChanges{
            try? viewContext.save()
            print("Updated latest changes to the database")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval){
            self.autoSaveViewContext(interval: interval)
        }
    }
}
