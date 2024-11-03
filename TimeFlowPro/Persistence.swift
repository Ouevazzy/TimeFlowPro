// Persistence.swift
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    init() {
        container = NSPersistentCloudKitContainer(name: "TimeFlowPro") // Assurez-vous que "TimeFlowPro" correspond au nom de votre modèle Core Data

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Erreur lors du chargement du store: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

