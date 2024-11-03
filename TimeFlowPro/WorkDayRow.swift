// WorkDayRow.swift
import SwiftUI

struct WorkDayRow: View {
    let workDay: WorkDayEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(workDay.type ?? "")
                    .font(.headline)

                Spacer()

                let overtime = netOvertimeSeconds(for: workDay)

                if workDay.type == WorkDayType.compensatory.rawValue {
                    // Afficher les heures déduites pour les journées de "Compensation"
                    Text(formattedTimeInterval(overtime))
                        .foregroundColor(.red)
                        .font(.subheadline)
                } else if workDay.type == WorkDayType.work.rawValue && overtime != 0 {
                    // Afficher les heures supplémentaires pour les journées de "Travail"
                    Text(formattedTimeInterval(overtime))
                        .foregroundColor(overtime >= 0 ? .green : .red)
                        .font(.subheadline)
                }
            }

            if workDay.type == WorkDayType.work.rawValue {
                Text("\(formattedTime(workDay.startTime)) - \(formattedTime(workDay.endTime))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if workDay.breakDuration > 0 {
                    Text("Pause: \(formattedTimeInterval(Int(workDay.breakDuration)))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Text("Total: \(formattedTimeInterval(totalWorkedSeconds(for: workDay)))")
                    .font(.subheadline)
            }

            if let note = workDay.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func formattedTime(_ date: Date?) -> String {
        guard let date = date else { return "--:--" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

