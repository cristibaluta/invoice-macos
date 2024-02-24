//
//  CompanyDetailsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 04.10.2021.
//

import SwiftUI

struct CompanyView: View {

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
    private var model: CompanyModel
    

    init (data: CompanyData, onChange: @escaping (CompanyData) -> Void) {
        self.init(model: CompanyModel(data: data), onChange: onChange)
    }

    private init (model: CompanyModel, onChange: @escaping (CompanyData) -> Void) {
        print("init CompanyView")
        self.model = model
        self.onChange = onChange

        name = model.data.name
        orc = model.data.orc
        cui = model.data.cui
        address = model.data.address
        county = model.data.county
        bankAccount = model.data.bank_account
        bankName = model.data.bank_name
        email = model.data.email ?? ""
        phone = model.data.phone ?? ""
        web = model.data.web ?? ""
    }
    
    var body: some View {

        let _ = Self._printChanges()

        VStack(alignment: .leading) {
            Group {
                HStack {
                    Text("Nume*:").foregroundColor(.gray)
                    TextField("", text: $name).onChange(of: name) { newValue in
                        /// Proper way to do this?
                        /// Published didSet is called twice in a row
                        /// State is not called at all
                        model.data.name = newValue
                        onChange(model.data)
                    }
                    .modifier(OutlineTextField())
                }
                HStack {
                    Text("Nr.ORC/an*:").foregroundColor(.gray)
                    TextField("", text: $orc).onChange(of: orc) { newValue in
                        model.data.orc = newValue
                        onChange(model.data)
                    }
                    .modifier(OutlineTextField())
                }
                HStack {
                    Text("C.U.I.*:").foregroundColor(.gray)
                    TextField("", text: $cui).onChange(of: cui) { newValue in
                        model.data.cui = newValue
                        onChange(model.data)
                    }
                    .modifier(OutlineTextField())
                }
                HStack {
                    Text("Sediul*:").foregroundColor(.gray)
                    TextField("", text: $address).onChange(of: address) { newValue in
                        model.data.address = newValue
                        onChange(model.data)
                    }
                    .modifier(OutlineTextField())
                }
                HStack {
                    Text("Județul*:").foregroundColor(.gray)
                    TextField("", text: $county).onChange(of: county) { newValue in
                        model.data.county = newValue
                        onChange(model.data)
                    }
                    .modifier(OutlineTextField())
                }
                HStack {
                    Text("Contul*:").foregroundColor(.gray)
                    TextField("", text: $bankAccount).onChange(of: bankAccount) { newValue in
                        model.data.bank_account = newValue
                        onChange(model.data)
                    }
                    .modifier(OutlineTextField())
                }
                HStack {
                    Text("Banca*:").foregroundColor(.gray)
                    TextField("", text: $bankName).onChange(of: bankName) { newValue in
                        model.data.bank_name = newValue
                        onChange(model.data)
                    }
                    .modifier(OutlineTextField())
                }
            }

            Divider()

            Group {
                HStack {
                    Text("Email:").foregroundColor(.gray)
                    TextField("", text: $email).onChange(of: email) { newValue in
                        model.data.email = newValue != "" ? newValue : nil
                        onChange(model.data)
                    }
                    .modifier(OutlineTextField())
                }
                HStack {
                    Text("Phone:").foregroundColor(.gray)
                    TextField("", text: $phone).onChange(of: phone) { newValue in
                        model.data.phone = newValue != "" ? newValue : nil
                        onChange(model.data)
                    }
                    .modifier(OutlineTextField())
                    .modifier(NumberKeyboard())
                }
                HStack {
                    Text("Website:").foregroundColor(.gray)
                    TextField("", text: $web).onChange(of: web) { newValue in
                        model.data.web = newValue != "" ? newValue : nil
                        onChange(model.data)
                    }
                    .modifier(OutlineTextField())
                }
            }
        }

    }

}
