//
//  ContentView.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 04.01.2022.
//

import Foundation
import SwiftUI
import Combine

struct MainWindow: View {

    @EnvironmentObject var store: MainStore
    @EnvironmentObject var companiesData: CompaniesStore
    
    var body: some View {
        TabView {
            //
            // Projects and invoices tab
            //
            NavigationStack {
                if $store.projectsStore.projects.count > 0 {
                    ProjectsListScreen()
                } else {
                    NoProjectsScreen()
                }
            }
            .tabItem { Label("Invoices", systemImage: "list.bullet") }
            .tag(0)
            .onAppear {
                store.projectsStore.refresh()
            }
            //
            // Companies tab
            //
            NavigationStack {
                if $companiesData.companies.count > 0 {
                    CompaniesListScreen()
                } else {
                    NoCompaniesScreen()
                }
            }
            .tabItem { Label("Companies", systemImage: "c.circle") }
            .tag(1)
            .onAppear() {
                companiesData.refresh()
            }
            //
            // Settings tab
            //
            NavigationView {
                
            }
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            .tag(2)
        }
    }
}
