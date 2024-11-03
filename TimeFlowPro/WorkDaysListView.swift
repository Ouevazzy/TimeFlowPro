// WorkDaysListView.swift
import SwiftUI
import CoreData

struct WorkDaysListView: View {
    @EnvironmentObject private var viewModel: WorkDaysViewModel
    @State private var searchText = ""
    @State private var showingAddWorkDay = false
    @State private var workDayToEdit: WorkDayEntity?
    @State private var selectedDate = Date()

    var body: some View {
        VStack(spacing: 0) {
            // Navigateur de mois
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .padding()
                }

                Text(monthYearString(from: selectedDate))
                    .font(.headline)
                    .frame(maxWidth: .infinity)

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .cornerRadius(10)
            .padding([.horizontal, .top])

            List {
                ForEach(groupedAndFilteredWorkDays, id: \.0) { date, days in
                    Section(header: dateHeader(for: date)) {
                        ForEach(days) { workDay in
                            WorkDayRow(workDay: workDay)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    workDayToEdit = workDay
                                }
                        }
                        .onDelete { indexSet in
                            deleteWorkDays(for: date, at: indexSet)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .searchable(text: $searchText, prompt: "Rechercher par date ou note")
        .navigationTitle("Journées de travail")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddWorkDay = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddWorkDay) {
            NavigationView {
                AddEditWorkDayView()
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

    private var groupedAndFilteredWorkDays: [(Date, [WorkDayEntity])] {
        let filtered = viewModel.workDays.filter { workDay in
            let date = workDay.date ?? Date()
            let isInSelectedMonth = Calendar.current.isDate(date, equalTo: selectedDate, toGranularity: .month)
            let matchesSearch = searchText.isEmpty ||
                formattedDate(date).localizedCaseInsensitiveContains(searchText) ||
                (workDay.note ?? "").localizedCaseInsensitiveContains(searchText)
            return isInSelectedMonth && matchesSearch
        }

        let grouped = Dictionary(grouping: filtered) { workDay in
            Calendar.current.startOfDay(for: workDay.date ?? Date())
        }

        return grouped.sorted { $0.key > $1.key }
    }

    private func dateHeader(for date: Date) -> some View {
        HStack {
            Text(formattedDate(date))
                .font(.subheadline)
                .fontWeight(.bold)

            Spacer()

            if Calendar.current.isDateInToday(date) {
                Text("Aujourd'hui")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }

    private func deleteWorkDays(for date: Date, at offsets: IndexSet) {
        let daysForDate = groupedAndFilteredWorkDays.first { $0.0 == date }?.1 ?? []
        let workDaysToDelete = offsets.map { daysForDate[$0] }
        for workDay in workDaysToDelete {
            viewModel.deleteWorkDay(workDay)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date).capitalized
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date).capitalized
    }

    private func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) {
            withAnimation {
                selectedDate = newDate
            }
        }
    }

    private func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) {
            withAnimation {
                selectedDate = newDate
            }
        }
    }
}

