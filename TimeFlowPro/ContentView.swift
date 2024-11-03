// ContentView.swift
import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var userSettings = UserSettings.shared
    @StateObject private var viewModel: WorkDaysViewModel
    @State private var selectedTab = 0

    init() {
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: WorkDaysViewModel(context: context))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                HomeTabView()
                    .environmentObject(viewModel)
            }
            .tabItem {
                Label("Accueil", systemImage: "house.fill")
            }
            .tag(0)

            NavigationView {
                WorkDaysListView()
                    .environmentObject(viewModel)
            }
            .tabItem {
                Label("Journées", systemImage: "list.bullet")
            }
            .tag(1)

            NavigationView {
                CalendarView()
                    .environmentObject(viewModel)
            }
            .tabItem {
                Label("Calendrier", systemImage: "calendar")
            }
            .tag(2)

            NavigationView {
                ReportsView()
                    .environmentObject(viewModel)
            }
            .tabItem {
                Label("Rapports", systemImage: "chart.bar.fill")
            }
            .tag(3)

            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label("Paramètres", systemImage: "gear")
            }
            .tag(4)
        }
    }
}

