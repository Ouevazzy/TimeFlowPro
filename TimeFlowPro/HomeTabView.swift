// HomeTabView.swift
import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject private var viewModel: WorkDaysViewModel
    @ObservedObject private var userSettings = UserSettings.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SummaryCardView(
                    title: "Cette année",
                    hours: totalWorkedHoursThisYear(),
                    overtime: totalOvertimeSecondsThisYear(),
                    icon: "calendar.circle",
                    color: .blue
                )

                SummaryCardView(
                    title: "Ce mois",
                    hours: totalWorkedHoursThisMonth(),
                    overtime: totalOvertimeSecondsThisMonth(),
                    icon: "calendar",
                    color: .green
                )

                SummaryCardView(
                    title: "Cette semaine",
                    hours: totalWorkedHoursThisWeek(),
                    overtime: totalOvertimeSecondsThisWeek(),
                    icon: "calendar.badge.clock",
                    color: .orange
                )

                SummaryCardView(
                    title: "Vacances restantes",
                    hours: 0,
                    overtime: vacationDaysRemaining(),
                    icon: "airplane",
                    color: .purple,
                    isVacationCard: true
                )
            }
            .padding()
        }
        .navigationTitle("Accueil")
    }

    // Calcul des heures travaillées et des heures supplémentaires pour l'année
    private func totalWorkedHoursThisYear() -> Double {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let yearlyWorkDays = viewModel.workDays.filter {
            calendar.component(.year, from: $0.date ?? Date()) == currentYear && $0.type == WorkDayType.work.rawValue
        }
        let totalSeconds = yearlyWorkDays.reduce(0) { $0 + totalWorkedSeconds(for: $1) }
        return Double(totalSeconds) / 3600.0
    }

    private func totalOvertimeSecondsThisYear() -> Int {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let yearlyWorkDays = viewModel.workDays.filter {
            calendar.component(.year, from: $0.date ?? Date()) == currentYear
        }
        return yearlyWorkDays.reduce(0) { $0 + netOvertimeSeconds(for: $1) }
    }

    // Calcul des heures travaillées et des heures supplémentaires pour le mois
    private func totalWorkedHoursThisMonth() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)
        let monthlyWorkDays = viewModel.workDays.filter {
            let date = $0.date ?? Date()
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            return year == currentYear && month == currentMonth && $0.type == WorkDayType.work.rawValue
        }
        let totalSeconds = monthlyWorkDays.reduce(0) { $0 + totalWorkedSeconds(for: $1) }
        return Double(totalSeconds) / 3600.0
    }

    private func totalOvertimeSecondsThisMonth() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)
        let monthlyWorkDays = viewModel.workDays.filter {
            let date = $0.date ?? Date()
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            return year == currentYear && month == currentMonth
        }
        return monthlyWorkDays.reduce(0) { $0 + netOvertimeSeconds(for: $1) }
    }

    // Calcul des heures travaillées et des heures supplémentaires pour la semaine
    private func totalWorkedHoursThisWeek() -> Double {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return 0 }
        let weeklyWorkDays = viewModel.workDays.filter {
            let date = $0.date ?? Date()
            return date >= weekInterval.start && date < weekInterval.end && $0.type == WorkDayType.work.rawValue
        }
        let totalSeconds = weeklyWorkDays.reduce(0) { $0 + totalWorkedSeconds(for: $1) }
        return Double(totalSeconds) / 3600.0
    }

    private func totalOvertimeSecondsThisWeek() -> Int {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return 0 }
        let weeklyWorkDays = viewModel.workDays.filter {
            let date = $0.date ?? Date()
            return date >= weekInterval.start && date < weekInterval.end
        }
        return weeklyWorkDays.reduce(0) { $0 + netOvertimeSeconds(for: $1) }
    }

    // Calcul du nombre de jours de vacances restants
    private func vacationDaysRemaining() -> Int {
        let usedVacationDays = viewModel.workDays.filter { $0.type == WorkDayType.vacation.rawValue }.count
        return userSettings.annualVacationDays - usedVacationDays
    }
}

