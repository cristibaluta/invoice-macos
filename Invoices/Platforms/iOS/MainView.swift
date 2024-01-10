//
//  ContentView.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 04.01.2022.
//

import Foundation
import SwiftUI
import Combine

struct MainView: View {

    @EnvironmentObject var projectsState: ProjectsState
    @EnvironmentObject var companiesState: CompaniesState
    
    var body: some View {
        TabView {
            //
            //
            NavigationView {
                if $projectsState.projects.count > 0 {
                    ProjectsListScreen()
                } else {
                    NoProjectsScreen()
                }
            }
            .tabItem { Label("Invoices", systemImage: "list.bullet") }
            .tag(0)
            .onAppear {
                projectsState.refresh()
            }
            //
            //
            NavigationView {
                if $companiesState.companies.count > 0 {
                    CompaniesListScreen()
                } else {
                    NoCompaniesScreen()
                }
            }
            .tabItem { Label("Companies", systemImage: "heart.fill") }
            .tag(1)
            .onAppear() {
                companiesState.refresh()
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
