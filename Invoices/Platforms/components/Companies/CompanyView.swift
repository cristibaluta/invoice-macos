//
//  CompanyDetailsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 04.10.2021.
//

import SwiftUI

class CompanyViewViewModel {

    var data: CompanyData

    init (data: CompanyData) {
        self.data = data
    }
}

struct CompanyView: View {

#if os(iOS)
    typealias Stack = HStack
    let alignment: VerticalAlignment = .center
    let font = Font.system(size: 20)
#else
    typealias Stack = HStack
    let alignment: HorizontalAlignment = .center
    let font = Font.system(size: 12)
#endif

    @State var name: String
    @State var orc: String
    @State var cui: String
    @State var address: String
    @State var county: String
    @State var bankAccount: String
    @State var bankName: String
    @State var email: String
    @State var phone: String
    @State var web: String

    private var onChange: (CompanyData) -> Void
    private var state: CompanyViewViewModel
    

    init (data: CompanyData, onChange: @escaping (CompanyData) -> Void) {
        self.init(state: CompanyViewViewModel(data: data), onChange: onChange)
    }

    private init (state: CompanyViewViewModel, onChange: @escaping (CompanyData) -> Void) {
        print("init CompanyView")
        self.state = state
        self.onChange = onChange

        name = state.data.name
        orc = state.data.orc
        cui = state.data.cui
        address = state.data.address
        county = state.data.county
        bankAccount = state.data.bank_account
        bankName = state.data.bank_name
        email = state.data.email ?? ""
        phone = state.data.phone ?? ""
        web = state.data.web ?? ""
    }
    
    var body: some View {

        let _ = Self._printChanges()

        VStack(alignment: .leading) {
            Group {
                Stack {
                    Text("Nume*:").foregroundColor(.gray)
                    TextField("", text: $name).onChange(of: name) { newValue in
                        /// Proper way to do this?
                        /// Published didSet is called twice in a row
                        /// State is not called at all
                        state.data.name = newValue
                        onChange(state.data)
                    }
                    .modifier(OutlineTextField())
                }
                Stack {
                    Text("Nr.ORC/an*:").foregroundColor(.gray)
                    TextField("", text: $orc).onChange(of: orc) { newValue in
                        state.data.orc = newValue
                        onChange(state.data)
                    }
                    .modifier(OutlineTextField())
                }
                Stack {
                    Text("C.U.I.*:").foregroundColor(.gray)
                    TextField("", text: $cui).onChange(of: cui) { newValue in
                        state.data.cui = newValue
                        onChange(state.data)
                    }
                    .modifier(OutlineTextField())
                }
                Stack {
                    Text("Sediul*:").foregroundColor(.gray)
                    TextField("", text: $address).onChange(of: address) { newValue in
                        state.data.address = newValue
                        onChange(state.data)
                    }
                    .modifier(OutlineTextField())
                }
                Stack {
                    Text("Județul*:").foregroundColor(.gray)
                    TextField("", text: $county).onChange(of: county) { newValue in
                        state.data.county = newValue
                        onChange(state.data)
                    }
                    .modifier(OutlineTextField())
                }
                Stack {
                    Text("Contul*:").foregroundColor(.gray)
                    TextField("", text: $bankAccount).onChange(of: bankAccount) { newValue in
                        state.data.bank_account = newValue
                        onChange(state.data)
                    }
                    .modifier(OutlineTextField())
                }
                Stack {
                    Text("Banca*:").foregroundColor(.gray)
                    TextField("", text: $bankName).onChange(of: bankName) { newValue in
                        state.data.bank_name = newValue
                        onChange(state.data)
                    }
                    .modifier(OutlineTextField())
                }
            }

            Divider()

            Group {
                Stack {
                    Text("Email:").foregroundColor(.gray)
                    TextField("", text: $email).onChange(of: email) { newValue in
                        state.data.email = newValue != "" ? newValue : nil
                        onChange(state.data)
                    }
                    .modifier(OutlineTextField())
//                    .modifier(NumberKeyboard())
                }
                Stack {
                    Text("Phone:").foregroundColor(.gray)
                    TextField("", text: $phone).onChange(of: phone) { newValue in
                        state.data.phone = newValue != "" ? newValue : nil
                        onChange(state.data)
                    }
                    .modifier(OutlineTextField())
                    .modifier(NumberKeyboard())
                }
                Stack {
                    Text("Website:").foregroundColor(.gray)
                    TextField("", text: $web).onChange(of: web) { newValue in
                        state.data.web = newValue != "" ? newValue : nil
                        onChange(state.data)
                    }
                    .modifier(OutlineTextField())
                }
            }
        }

    }

}
