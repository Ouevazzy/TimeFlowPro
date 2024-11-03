// WorkDaysViewModel.swift
import Foundation
import CoreData

class WorkDaysViewModel: ObservableObject {
    @Published var workDays: [WorkDayEntity] = []

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        fetchWorkDays()
    }

    func fetchWorkDays() {
        let request: NSFetchRequest<WorkDayEntity> = WorkDayEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WorkDayEntity.date, ascending: false)]

        do {
            workDays = try context.fetch(request)
        } catch {
            print("Erreur lors de la récupération des journées de travail: \(error.localizedDescription)")
        }
    }

    func addWorkDay(_ workDayData: WorkDayData) {
        let newWorkDay = WorkDayEntity(context: context)
        newWorkDay.id = UUID()
        newWorkDay.date = workDayData.date
        newWorkDay.startTime = workDayData.startTime
        newWorkDay.endTime = workDayData.endTime
        newWorkDay.breakDuration = workDayData.breakDuration
        newWorkDay.note = workDayData.note
        newWorkDay.type = workDayData.type.rawValue

        saveContext()
        fetchWorkDays()
    }

    func updateWorkDay(_ workDay: WorkDayEntity, with data: WorkDayData) {
        workDay.date = data.date
        workDay.startTime = data.startTime
        workDay.endTime = data.endTime
        workDay.breakDuration = data.breakDuration
        workDay.note = data.note
        workDay.type = data.type.rawValue

        saveContext()
        fetchWorkDays()
    }

    func deleteWorkDay(_ workDay: WorkDayEntity) {
        context.delete(workDay)
        saveContext()
        fetchWorkDays()
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Erreur lors de la sauvegarde du contexte: \(error.localizedDescription)")
        }
    }
}

