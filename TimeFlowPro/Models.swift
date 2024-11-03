// Models.swift
import SwiftUI
import UserNotifications

// MARK: - WorkDayType
enum WorkDayType: String, Codable, CaseIterable, Identifiable {
    case work = "Travail"
    case vacation = "Vacances"
    case holiday = "Férié"
    case sickLeave = "Maladie"
    case compensatory = "Compensation"

    var id: String { rawValue }
}

// MARK: - Weekday
enum Weekday: String, Codable, CaseIterable, Identifiable {
    case monday = "Lundi"
    case tuesday = "Mardi"
    case wednesday = "Mercredi"
    case thursday = "Jeudi"
    case friday = "Vendredi"
    case saturday = "Samedi"
    case sunday = "Dimanche"

    var id: String { rawValue }

    static func fromCalendarWeekday(_ weekday: Int) -> Weekday {
        switch weekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .monday
        }
    }
}

// MARK: - UserSettings
class UserSettings: ObservableObject {
    static let shared = UserSettings()

    @Published var standardWeeklyHours: Double = 41 {
        didSet {
            UserDefaults.standard.set(standardWeeklyHours, forKey: "standardWeeklyHours")
        }
    }

    @Published var workingDays: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday] {
        didSet {
            if let encoded = try? JSONEncoder().encode(workingDays) {
                UserDefaults.standard.set(encoded, forKey: "workingDays")
            }
        }
    }

    @Published var annualVacationDays: Int = 25 {
        didSet {
            UserDefaults.standard.set(annualVacationDays, forKey: "annualVacationDays")
        }
    }

    @Published var reminderTime: Date = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())! {
        didSet {
            UserDefaults.standard.set(reminderTime, forKey: "reminderTime")
            scheduleDailyReminder()
        }
    }

    @Published var notificationsEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
            scheduleDailyReminder()
        }
    }

    var standardDailyHours: Double {
        let workingDaysCount = Double(workingDays.count)
        return workingDaysCount > 0 ? standardWeeklyHours / workingDaysCount : 0
    }

    private init() {
        if let savedWeeklyHours = UserDefaults.standard.object(forKey: "standardWeeklyHours") as? Double {
            self.standardWeeklyHours = savedWeeklyHours
        }

        if let savedDaysData = UserDefaults.standard.data(forKey: "workingDays"),
           let decodedDays = try? JSONDecoder().decode([Weekday].self, from: savedDaysData) {
            self.workingDays = decodedDays
        }

        if let savedVacationDays = UserDefaults.standard.object(forKey: "annualVacationDays") as? Int {
            self.annualVacationDays = savedVacationDays
        }

        if let savedReminderTime = UserDefaults.standard.object(forKey: "reminderTime") as? Date {
            self.reminderTime = savedReminderTime
        }

        if let savedNotificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool {
            self.notificationsEnabled = savedNotificationsEnabled
        }

        scheduleDailyReminder()
    }

    func isWorkingDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        return workingDays.contains(Weekday.fromCalendarWeekday(weekday))
    }

    func scheduleDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])

        guard notificationsEnabled else { return }

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus != .authorized {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                    if granted {
                        DispatchQueue.main.async {
                            self.scheduleDailyReminder()
                        }
                    }
                }
                return
            } else {
                self.createNotificationRequest()
            }
        }
    }

    private func createNotificationRequest() {
        let content = UNMutableNotificationContent()
        content.title = "N'oubliez pas d'enregistrer votre journée"
        content.body = "Pensez à saisir vos heures de travail pour aujourd'hui."
        content.sound = UNNotificationSound.default

        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        dateComponents.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erreur lors de la planification de la notification : \(error)")
            }
        }
    }
}

// MARK: - WorkDayData
struct WorkDayData {
    var date: Date
    var startTime: Date?
    var endTime: Date?
    var breakDuration: TimeInterval
    var note: String
    var type: WorkDayType
}

// MARK: - Extension de Date
extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}

