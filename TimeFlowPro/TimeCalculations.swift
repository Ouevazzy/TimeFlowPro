// TimeCalculations.swift
import Foundation

func netOvertimeSeconds(for workDay: WorkDayEntity) -> Int {
    let totalSeconds = totalWorkedSeconds(for: workDay)
    let standardSeconds = calculateStandardSeconds(for: workDay)
    return totalSeconds - standardSeconds
}

func totalWorkedSeconds(for workDay: WorkDayEntity) -> Int {
    guard let type = WorkDayType(rawValue: workDay.type ?? "") else { return 0 }

    // Retourner 0 pour les journées autres que "Travail"
    if type != .work {
        return 0
    }

    guard let startTime = workDay.startTime, let endTime = workDay.endTime else { return 0 }
    return Int(endTime.timeIntervalSince(startTime) - workDay.breakDuration)
}

func calculateStandardSeconds(for workDay: WorkDayEntity) -> Int {
    let userSettings = UserSettings.shared
    let standardSeconds = Int(round(userSettings.standardDailyHours * 3600))

    guard userSettings.isWorkingDay(workDay.date ?? Date()) else {
        return 0
    }

    switch WorkDayType(rawValue: workDay.type ?? "") {
    case .work:
        // Pour une journée de travail normale, on utilise les heures standard positives
        return standardSeconds
    case .compensatory:
        // Pour une journée de compensation, on utilise les heures standard positives
        return standardSeconds
    case .vacation, .holiday, .sickLeave:
        // Pour ces types de journée, on n'ajoute ni ne soustrait des heures supplémentaires
        return 0
    default:
        return 0
    }
}

func formattedTimeInterval(_ seconds: Int) -> String {
    let hours = abs(seconds) / 3600
    let minutes = (abs(seconds) % 3600) / 60
    let sign = seconds < 0 ? "-" : ""
    return String(format: "%@%dh%02d", sign, hours, minutes)
}

