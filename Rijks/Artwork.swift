//
//  Artwork.swift
//  Rijks
//
//  Created by Twelker on Sep/23/15.
//  Copyright © 2015 Twelker. All rights reserved.
//

import UIKit

// 1. Import CoreData
import CoreData

// 2. Make Artwork available to Objective-C code
@objc(Artwork)

// 3. Make Artwork a subclass of NSManagedObject
class Artwork : NSManagedObject {
    
    struct Keys {
        static let Title          = "title"
        static let LongTitle      = "long_title"
        static let TypeArt        = "typeArt"
        static let ImageUrl       = "imageUrl"
        static let FileName       = "fileName"
        static let Favorite       = "favorite"
        static let ArtworkCounter = "artworkCounter"
        static let Artist         = "artist"
    }
    
    @NSManaged var title          : String!
    @NSManaged var longTitle      : String!
    @NSManaged var typeArt        : String!
    @NSManaged var imageUrl       : String!
    @NSManaged var fileName       : String!
    @NSManaged var favorite       : String!
    @NSManaged var artworkCounter : String!
    @NSManaged var artist         : Artist
    
    // 5. Include this standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /**
    * 6. The two argument init method
    *
    * The Two argument Init method. The method has two goals:
    *  - insert the new Artwork into a Core Data Managed Object Context
    *  - initialze the Artwork's properties from a dictionary
    */
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Get the entity associated with the "Artwork" type.  This is an object that contains
        // the information from the Model.xcdatamodeld file.
        let entity =  NSEntityDescription.entityForName("Artwork", inManagedObjectContext: context)!
        
        // Now we can call an init method that we have inherited from NSManagedObject. Remember that
        // the Artwork class is a subclass of NSManagedObject. This inherited init method does the
        // work of "inserting" our object into the context that was passed in as a parameter
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        // After the Core Data work has been taken care of we can init the properties from the
        // dictionary. This works in the same way that it did before we started on Core Data
        title          = dictionary[Keys.Title]          as! String
        longTitle      = dictionary[Keys.LongTitle]      as! String
        typeArt        = dictionary[Keys.TypeArt]        as! String
        imageUrl       = dictionary[Keys.ImageUrl]       as! String
        fileName       = dictionary[Keys.FileName]       as! String
        favorite       = dictionary[Keys.Favorite]       as! String
        artworkCounter = dictionary[Keys.ArtworkCounter] as! String
    }
    
    
}