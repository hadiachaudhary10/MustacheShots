//
//  Shot+CoreDataProperties.swift
//  MustacheShots
//
//  Created by Dev on 17/12/2023.
//
//

import Foundation
import CoreData

extension Shot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Shot> {
        return NSFetchRequest<Shot>(entityName: "Shot")
    }

    @NSManaged public var duration: String?
    @NSManaged public var id: String
    @NSManaged public var tag: String?
    @NSManaged public var videoURL: String?

}

extension Shot: Identifiable {}
