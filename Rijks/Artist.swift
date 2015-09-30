//
//  Artist.swift
//  Rijks
//
//  Created by Twelker on Sep/23/15.
//  Copyright © 2015 Twelker. All rights reserved.
//

import UIKit

// 1. Import CoreData
import CoreData

// 2. Make Artist available to Objective-C code
@objc(Artist)

// 3. Make Artist a subclass of NSManagedObject
class Artist : NSManagedObject {
    
    struct Keys {
        static let Name        = "name"
        static let Artworks    = "artworks"
    }
    
    @NSManaged var name     : String!
    @NSManaged var artworks : [Artwork]
    
    // 5. Include this standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /**
    * 6. The two argument init method
    *
    * The Two argument Init method. The method has two goals:
    *  - insert the new Artist into a Core Data Managed Object Context
    *  - initialze the Artist's properties from a dictionary
    */
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Get the entity associated with the "Artist" type.  This is an object that contains
        // the information from the Model.xcdatamodeld file.
        let entity =  NSEntityDescription.entityForName("Artist", inManagedObjectContext: context)!
        
        // Now we can call an init method that we have inherited from NSManagedObject. Remember that
        // the Artist class is a subclass of NSManagedObject. This inherited init method does the
        // work of "inserting" our object into the context that was passed in as a parameter
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        // After the Core Data work has been taken care of we can init the properties from the
        // dictionary. This works in the same way that it did before we started on Core Data
        name = dictionary[Keys.Name]             as! String
    }

    
}