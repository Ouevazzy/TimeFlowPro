// SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @ObservedObject private var userSettings = UserSettings.shared
    @AppStorage("appearanceMode") private var appearanceMode = "system"
    @State private var showingExportSheet = false
    @State private var shareItems: [Any] = []
    @EnvironmentObject private var viewModel: WorkDaysViewModel
    @State private var showingEraseConfirmation = false

    var body: some View {
        Form {
            // Apparence
            Section(header: Text("Apparence")) {
                Picker("Mode d'affichage", selection: $appearanceMode) {
                    Text("Système").tag("system")
                    Text("Clair").tag("light")
                    Text("Sombre").tag("dark")
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            // Horaires de travail
            Section(header: Text("Horaires de travail")) {
                Stepper(
                    "Heures hebdomadaires: \(userSettings.standardWeeklyHours, specifier: "%.1f")",
                    value: $userSettings.standardWeeklyHours,
                    in: 0...80,
                    step: 0.5
                )

                Text("Heures quotidiennes: \(userSettings.standardDailyHours, specifier: "%.1f")")
                    .foregroundColor(.secondary)
            }

            // Jours de travail
            Section(header: Text("Jours de travail")) {
                ForEach(Weekday.allCases) { day in
                    Toggle(day.rawValue, isOn: Binding(
                        get: { userSettings.workingDays.contains(day) },
                        set: { isOn in
                            if isOn {
                                if !userSettings.workingDays.contains(day) {
                                    userSettings.workingDays.append(day)
                                }
                            } else {
                                userSettings.workingDays.removeAll { $0 == day }
                            }
                        }
                    ))
                }
            }

            // Vacances
            Section(header: Text("Vacances")) {
                Stepper(
                    "Jours de vacances annuels: \(userSettings.annualVacationDays)",
                    value: $userSettings.annualVacationDays,
                    in: 0...60
                )
            }

            // Notifications
            Section(header: Text("Notifications")) {
                Toggle("Activer les notifications", isOn: $userSettings.notificationsEnabled)

                if userSettings.notificationsEnabled {
                    DatePicker("Heure du rappel", selection: $userSettings.reminderTime, displayedComponents: .hourAndMinute)
                        .environment(\.locale, Locale(identifier: "fr_FR"))
                }
            }

            // Données
            Section(header: Text("Données")) {
                Button(action: {
                    exportData()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Exporter les données")
                    }
                }

                Button("Effacer toutes les données", role: .destructive) {
                    showingEraseConfirmation = true
                }
            }
        }
        .navigationTitle("Paramètres")
        .sheet(isPresented: $showingExportSheet) {
            ShareSheet(items: shareItems)
        }
        .alert(isPresented: $showingEraseConfirmation) {
            Alert(
                title: Text("Confirmer"),
                message: Text("Voulez-vous vraiment effacer toutes les données ? Cette action est irréversible."),
                primaryButton: .destructive(Text("Effacer")) {
                    for workDay in viewModel.workDays {
                        viewModel.deleteWorkDay(workDay)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func exportData() {
        let csvString = createCSV()
        let fileName = "WorkDays.csv"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = documentsDirectory.appendingPathComponent(fileName)

        do {
            try csvString.write(to: path, atomically: true, encoding: .utf8)
            shareItems = [path]
            showingExportSheet = true
        } catch {
            print("Erreur lors de l'exportation : \(error)")
        }
    }

    private func createCSV() -> String {
        var csv = "Date,Heure de début,Heure de fin,Pause (s),Note,Type\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        for workDay in viewModel.workDays {
            let date = dateFormatter.string(from: workDay.date ?? Date())
            let startTime = timeFormatter.string(from: workDay.startTime ?? Date())
            let endTime = timeFormatter.string(from: workDay.endTime ?? Date())
            let breakDuration = workDay.breakDuration
            let note = (workDay.note ?? "").replacingOccurrences(of: ",", with: " ")
            let type = workDay.type ?? ""
            csv += "\(date),\(startTime),\(endTime),\(breakDuration),\(note),\(type)\n"
        }
        return csv
    }
}

