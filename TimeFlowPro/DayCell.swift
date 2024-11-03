// DayCell.swift
import SwiftUI

struct DayCell: View {
    let date: Date
    let hasWorkDay: Bool
    let isSelected: Bool

    private let calendar = Calendar.current

    var body: some View {
        VStack {
            Text("\(calendar.component(.day, from: date))")
                .frame(height: 32)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.blue.opacity(0.3) : Color.clear)
                .clipShape(Circle())

            if hasWorkDay {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 6, height: 6)
            } else {
                Color.clear
                    .frame(width: 6, height: 6)
            }
        }
    }
}

