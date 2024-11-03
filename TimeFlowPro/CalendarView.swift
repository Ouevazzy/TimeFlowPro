// CalendarView.swift
import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var viewModel: WorkDaysViewModel
    @State private var selectedDate: Date?
    @State private var showingAddWorkDay = false
    @State private var workDayToEdit: WorkDayEntity?

    private let calendar = Calendar.current
    @State private var currentMonth = Date()

    var body: some View {
        VStack(spacing: 20) {
            // En-tête du calendrier
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }

                Text(monthYearString(from: currentMonth))
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)

            // Jours de la semaine
            HStack {
                ForEach(getWeekDaySymbols(), id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)

            // Grille du calendrier
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(getDaysInMonth(), id: \.self) { date in
                    if let date = date {
                        let isSelected = selectedDate != nil && Calendar.current.isDate(selectedDate!, inSameDayAs: date)
                        DayCell(
                            date: date,
                            hasWorkDay: hasWorkDay(on: date),
                            isSelected: isSelected
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
            .padding(.horizontal)

            // Liste des entrées pour la date sélectionnée
            if let selectedDate = selectedDate {
                List {
                    let workDaysForDate = getWorkDays(for: selectedDate)
                    ForEach(workDaysForDate) { workDay in
                        WorkDayRow(workDay: workDay)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                workDayToEdit = workDay
                            }
                    }
                    .onDelete { indexSet in
                        deleteWorkDays(workDaysForDate, at: indexSet)
                    }
                }
            }

            Spacer()
        }
        .navigationTitle("Calendrier")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddWorkDay = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddWorkDay) {
            NavigationView {
                AddEditWorkDayView(initialDate: selectedDate ?? Date())
                    .environmentObject(viewModel)
            }
        }
        .sheet(item: $workDayToEdit) { workDay in
            NavigationView {
                AddEditWorkDayView(workDayToEdit: workDay)
                    .environmentObject(viewModel)
            }
        }
    }

    private func getWeekDaySymbols() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.veryShortWeekdaySymbols
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date).capitalized
    }

    private func previousMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }

    private func nextMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }

    private func getDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end) else {
            return []
        }

        var days: [Date?] = []
        var currentDate = monthFirstWeek.start

        while currentDate < monthLastWeek.end {
            if calendar.component(.month, from: currentDate) != calendar.component(.month, from: currentMonth) {
                days.append(nil)
            } else {
                days.append(currentDate)
            }

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return days
    }

    private func hasWorkDay(on date: Date) -> Bool {
        return viewModel.workDays.contains { calendar.isDate($0.date ?? Date(), inSameDayAs: date) }
    }

    private func getWorkDays(for date: Date) -> [WorkDayEntity] {
        return viewModel.workDays
            .filter { calendar.isDate($0.date ?? Date(), inSameDayAs: date) }
            .sorted { ($0.startTime ?? Date()) < ($1.startTime ?? Date()) }
    }

    private func deleteWorkDays(_ workDays: [WorkDayEntity], at indexSet: IndexSet) {
        for index in indexSet {
            viewModel.deleteWorkDay(workDays[index])
        }
    }
}

