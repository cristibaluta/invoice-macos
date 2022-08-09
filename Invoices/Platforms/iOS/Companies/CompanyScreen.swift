//
//  CompanyScreen.swift
//  Invoices iOS
//
//  Created by Cristian Baluta on 20.07.2022.
//

import SwiftUI

struct CompanyScreen: View {

    @EnvironmentObject var companiesState: CompaniesState
    @State var isEditing = false
    private var data: CompanyData

    init (data: CompanyData) {
        print("init CompanyScreen")
        self.data = data
    }

    var body: some View {
        ScrollView(.vertical) {
            CompanyView(data: data) { data in
                companiesState.selectedCompany = data
                isEditing = true
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(data.name).font(.headline)
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isEditing {
                    Button("Save") {
                        companiesState.saveSelectedCompany()
                    }
                }
            }
        }
        
    }

}
