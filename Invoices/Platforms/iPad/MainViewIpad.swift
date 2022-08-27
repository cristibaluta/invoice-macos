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

    @EnvironmentObject var foldersState: FoldersState
    @EnvironmentObject var companiesState: CompaniesState

    var body: some View {
        NavigationView {
            if $foldersState.folders.count > 0 {
                FoldersListScreen()
            } else {
                NoProjectsScreen()
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .tag(0)
        .onAppear {
            foldersState.refresh()
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
