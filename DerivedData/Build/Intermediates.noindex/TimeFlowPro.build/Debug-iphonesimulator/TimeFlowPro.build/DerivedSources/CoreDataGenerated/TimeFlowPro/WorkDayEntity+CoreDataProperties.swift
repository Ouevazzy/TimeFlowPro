//
//  WorkDayEntity+CoreDataProperties.swift
//  
//
//  Created by Jordan Payez on 3/11/24.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension WorkDayEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkDayEntity> {
        return NSFetchRequest<WorkDayEntity>(entityName: "WorkDayEntity")
    }

    @NSManaged public var breakDuration: Double
    @NSManaged public var date: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var note: String?
    @NSManaged public var startTime: Date?
    @NSManaged public var type: String?

}

extension WorkDayEntity : Identifiable {

}
