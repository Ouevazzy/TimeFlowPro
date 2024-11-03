// StatisticsOverview.swift
import SwiftUI

struct StatisticsOverview: View {
    let workDays: [WorkDayEntity]

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                StatBox(
                    title: "Jours travaillés",
                    value: "\(workDays.filter { $0.type == WorkDayType.work.rawValue }.count)"
                )
                StatBox(
                    title: "Heures totales",
                    value: formattedTimeInterval(totalWorkedSecondsSum)
                )
                StatBox(
                    title: "Moyenne/jour",
                    value: formattedTimeInterval(averageWorkedSeconds)
                )
            }

            HStack {
                StatBox(
                    title: "Heures supp.",
                    value: formattedTimeInterval(totalOvertimeSeconds),
                    color: totalOvertimeSeconds >= 0 ? .green : .red
                )
                StatBox(
                    title: "Jours congés",
                    value: "\(workDays.filter { $0.type == WorkDayType.vacation.rawValue }.count)"
                )
                StatBox(
                    title: "Jours maladie",
                    value: "\(workDays.filter { $0.type == WorkDayType.sickLeave.rawValue }.count)"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        )
    }

    // Renommé pour éviter le conflit avec la fonction totalWorkedSeconds(for:)
    private var totalWorkedSecondsSum: Int {
        workDays.filter { $0.type == WorkDayType.work.rawValue }
            .reduce(0) { $0 + totalWorkedSeconds(for: $1) }
    }

    private var totalOvertimeSeconds: Int {
        workDays.reduce(0) { $0 + netOvertimeSeconds(for: $1) }
    }

    private var averageWorkedSeconds: Int {
        let workDaysCount = workDays.filter { $0.type == WorkDayType.work.rawValue }.count
        guard workDaysCount > 0 else { return 0 }
        return totalWorkedSecondsSum / workDaysCount
    }
}

