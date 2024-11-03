// SummaryCardView.swift
import SwiftUI

struct SummaryCardView: View {
    let title: String
    let hours: Double // Heures travaillées en heures
    let overtime: Int // Heures supplémentaires en secondes
    let icon: String
    let color: Color
    var isVacationCard: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Text(title)
                    .font(.headline)
            }

            Divider()

            HStack {
                VStack(alignment: .leading) {
                    if !isVacationCard {
                        Text("Heures travaillées")
                            .font(.caption)
                        Text(formattedTimeInterval(Int(hours * 3600)))
                            .font(.title3)
                    }
                }

                Spacer()

                VStack(alignment: .trailing) {
                    if isVacationCard {
                        Text("Jours restants")
                            .font(.caption)
                        Text("\(Int(overtime))")
                            .font(.title3)
                    } else {
                        Text(overtime >= 0 ? "Heures supp." : "Heures manquantes")
                            .font(.caption)
                        Text(formattedTimeInterval(overtime))
                            .font(.title3)
                            .foregroundColor(overtime >= 0 ? .green : .red)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        )
    }
}

