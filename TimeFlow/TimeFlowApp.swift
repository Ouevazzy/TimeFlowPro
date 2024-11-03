//
//  TimeFlowApp.swift
//  TimeFlow
//
//  Created by Jordan Payez on 03/11/2024.
//

import SwiftUI

@main
struct TimeFlowApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
