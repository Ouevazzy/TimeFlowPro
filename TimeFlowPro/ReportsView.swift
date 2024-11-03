// ReportsView.swift
import SwiftUI

struct ReportsView: View {
    @EnvironmentObject private var viewModel: WorkDaysViewModel
    @State private var selectedPeriod = "Semaine"
    @State private var selectedDate = Date()
    @Environment(\.calendar) private var calendar

    private let periods = ["Semaine", "Mois", "Année"]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Période et Navigation
                HStack {
                    Picker("Période", selection: $selectedPeriod) {
                        ForEach(periods, id: \.self) { period in
                            Text(period).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()

                // Sélecteur de date
                DatePicker(
                    "Sélectionner une date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(CompactDatePickerStyle())
                .padding(.horizontal)

                // Statistiques
                StatisticsOverview(workDays: filteredWorkDays)
                    .padding()
            }
        }
        .navigationTitle("Rapports")
    }

    private var filteredWorkDays: [WorkDayEntity] {
        let filterStart: Date
        let filterEnd: Date

        switch selectedPeriod {
        case "Semaine":
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
                return []
            }
            filterStart = weekInterval.start
            filterEnd = weekInterval.end

        case "Mois":
            guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate) else {
                return []
            }
            filterStart = monthInterval.start
            filterEnd = monthInterval.end

        case "Année":
            guard let yearInterval = calendar.dateInterval(of: .year, for: selectedDate) else {
                return []
            }
            filterStart = yearInterval.start
            filterEnd = yearInterval.end

        default:
            return []
        }

        return viewModel.workDays.filter { workDay in
            let date = workDay.date ?? Date()
            return date >= filterStart && date < filterEnd
        }.sorted(by: { ($0.date ?? Date()) < ($1.date ?? Date()) })
    }
}

