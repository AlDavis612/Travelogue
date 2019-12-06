//
//  Log+CoreDataProperties.swift
//  Travelogue
//
//  Created by Alex Davis on 12/4/19.
//  Copyright © 2019 Alex Davis. All rights reserved.
//
//

import Foundation
import CoreData


extension Log {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Log> {
        return NSFetchRequest<Log>(entityName: "Log")
    }

    @NSManaged public var body: String?
    @NSManaged public var rawAddDate: Date?
    @NSManaged public var rawImage: Data?
    @NSManaged public var title: String?

}
