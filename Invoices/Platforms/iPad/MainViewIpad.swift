//
//  MainViewIpad.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 22.07.2022.
//

import Foundation
import SwiftUI
import Combine

struct MainViewIpad: View {

    @EnvironmentObject var projectsState: ProjectsState
    @EnvironmentObject var companiesState: CompaniesState

    var body: some View {
        NavigationView {
            if $projectsState.projects.count > 0 {
                ProjectsListScreen()
            } else {
                NoProjectsScreen()
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .tag(0)
        .onAppear {
            projectsState.refresh()
            companiesState.refresh()
        }
//        TabView {
//            //
//            //
//
//            //
//            //
//            NavigationView {
//                if $companiesState.companies.count > 0 {
//                    CompaniesListScreen()
//                } else {
//                    NoCompaniesScreen()
//                }
//            }
//            .tabItem { Label("Companies", systemImage: "heart.fill") }
//            .tag(1)
//            .onAppear() {
//                companiesState.refresh()
//            }
//            //
//            //
//            NavigationView {
//
//            }
//            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
//            .tag(2)
//        }
    }
}

extension UISplitViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.show(.primary)
    }
}
