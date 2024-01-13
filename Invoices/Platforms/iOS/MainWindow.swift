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

    @EnvironmentObject var projectsData: ProjectsStore
    @EnvironmentObject var companiesData: CompaniesStore
    
    var body: some View {
        TabView {
            //
            //
            NavigationView {
                if $projectsData.projects.count > 0 {
                    ProjectsListScreen()
                } else {
                    NoProjectsScreen()
                }
            }
            .tabItem { Label("Invoices", systemImage: "list.bullet") }
            .tag(0)
            .onAppear {
                projectsData.refresh()
            }
            //
            //
            NavigationView {
                if $companiesData.companies.count > 0 {
                    CompaniesListScreen()
                } else {
                    NoCompaniesScreen()
                }
            }
            .tabItem { Label("Companies", systemImage: "heart.fill") }
            .tag(1)
            .onAppear() {
                companiesData.refresh()
            }
            //
            //
            NavigationView {
                
            }
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            .tag(2)
        }
    }
}
