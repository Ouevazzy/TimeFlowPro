// AddEditWorkDayView.swift
import SwiftUI
import CoreData

struct AddEditWorkDayView: View {
    @EnvironmentObject private var viewModel: WorkDaysViewModel
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var userSettings = UserSettings.shared

    let workDayToEdit: WorkDayEntity?

    @State private var date: Date = Date()
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var breakDuration: TimeInterval = 3600
    @State private var note: String = ""
    @State private var type: WorkDayType = .work

    init(workDayToEdit: WorkDayEntity? = nil, initialDate: Date? = nil) {
        self.workDayToEdit = workDayToEdit
        if let initialDate = initialDate {
            _date = State(initialValue: initialDate)
        }
    }

    var body: some View {
        Form {
            Section(header: Text("Date")) {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .environment(\.locale, Locale(identifier: "fr_FR"))
            }

            Section(header: Text("Type")) {
                Picker("Type de journée", selection: $type) {
                    ForEach(WorkDayType.allCases) { dayType in
                        Text(dayType.rawValue).tag(dayType)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            if type == .work {
                Section(header: Text("Horaires")) {
                    DatePicker("Début", selection: $startTime, displayedComponents: .hourAndMinute)
                        .environment(\.locale, Locale(identifier: "fr_FR"))

                    DatePicker("Fin", selection: $endTime, displayedComponents: .hourAndMinute)
                        .environment(\.locale, Locale(identifier: "fr_FR"))

                    Stepper(value: $breakDuration, in: 0...7200, step: 300) {
                        Text("Pause : \(Int(breakDuration / 60)) minutes")
                    }
                }
            }

            Section(header: Text("Note")) {
                TextField("Note", text: $note)
            }
        }
        .navigationTitle(workDayToEdit == nil ? "Nouvelle journée" : "Modifier")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Annuler") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Enregistrer") {
                    saveWorkDay()
                }
                .disabled(!isFormValid())
            }
        }
        .onAppear {
            if let workDay = workDayToEdit {
                date = workDay.date ?? Date()
                startTime = workDay.startTime ?? Date()
                endTime = workDay.endTime ?? Date()
                breakDuration = workDay.breakDuration
                note = workDay.note ?? ""
                type = WorkDayType(rawValue: workDay.type ?? "") ?? .work
            } else {
                loadLastUsedValues()
            }
        }
    }

    private func loadLastUsedValues() {
        let now = Date()
        if let lastStartTime = UserDefaults.standard.object(forKey: "lastStartTime") as? Date {
            startTime = lastStartTime
        } else {
            startTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: now) ?? now
        }

        if let lastEndTime = UserDefaults.standard.object(forKey: "lastEndTime") as? Date {
            endTime = lastEndTime
        } else {
            endTime = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: now) ?? now
        }

        breakDuration = UserDefaults.standard.double(forKey: "lastBreakDuration")
        if breakDuration == 0 {
            breakDuration = 3600
        }
    }

    private func isFormValid() -> Bool {
        if type == .work {
            return startTime < endTime
        }
        return true
    }

    private func saveWorkDay() {
        let calendar = Calendar.current

        var finalStartTime: Date?
        var finalEndTime: Date?

        if type == .work {
            var startComponents = calendar.dateComponents([.year, .month, .day], from: date)
            let startTimeComponents = calendar.dateComponents([.hour, .minute], from: startTime)
            startComponents.hour = startTimeComponents.hour
            startComponents.minute = startTimeComponents.minute

            var endComponents = calendar.dateComponents([.year, .month, .day], from: date)
            let endTimeComponents = calendar.dateComponents([.hour, .minute], from: endTime)
            endComponents.hour = endTimeComponents.hour
            endComponents.minute = endTimeComponents.minute

            finalStartTime = calendar.date(from: startComponents)
            finalEndTime = calendar.date(from: endComponents)
        }

        let workDayData = WorkDayData(
            date: calendar.startOfDay(for: date),
            startTime: finalStartTime,
            endTime: finalEndTime,
            breakDuration: type == .work ? breakDuration : 0,
            note: note,
            type: type
        )

        if let workDayToEdit = workDayToEdit {
            // Mise à jour
            viewModel.updateWorkDay(workDayToEdit, with: workDayData)
        } else {
            // Ajout
            viewModel.addWorkDay(workDayData)
        }

        if type == .work {
            UserDefaults.standard.set(startTime, forKey: "lastStartTime")
            UserDefaults.standard.set(endTime, forKey: "lastEndTime")
            UserDefaults.standard.set(breakDuration, forKey: "lastBreakDuration")
        }

        dismiss()
    }
}

extension AddEditWorkDayView {
    init(initialDate: Date) {
        self.init(workDayToEdit: nil, initialDate: initialDate)
    }
}

