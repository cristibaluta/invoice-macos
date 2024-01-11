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

    @EnvironmentObject var projectsData: ProjectsData
    @EnvironmentObject var companiesData: CompaniesData

    var body: some View {
        NavigationView {
            if $projectsData.projects.count > 0 {
                ProjectsListScreen()
            } else {
                NoProjectsScreen()
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .tag(0)
        .onAppear {
            projectsData.refresh()
            companiesData.refresh()
        }
//        TabView {
//            //
//            //
//
//            //
//            //
//            NavigationView {
//                if $companiesData.companies.count > 0 {
//                    CompaniesListScreen()
//                } else {
//                    NoCompaniesScreen()
//                }
//            }
//            .tabItem { Label("Companies", systemImage: "heart.fill") }
//            .tag(1)
//            .onAppear() {
//                companiesData.refresh()
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
