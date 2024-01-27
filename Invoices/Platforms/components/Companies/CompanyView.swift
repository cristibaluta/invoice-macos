//
//  CompanyDetailsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 04.10.2021.
//

import SwiftUI

struct CompanyView: View {

#if os(iOS)
    typealias Stack = HStack
#else
    typealias Stack = HStack
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
    private var vm: CompanyViewViewModel
    

    init (data: CompanyData, onChange: @escaping (CompanyData) -> Void) {
        self.init(vm: CompanyViewViewModel(data: data), onChange: onChange)
    }

    private init (vm: CompanyViewViewModel, onChange: @escaping (CompanyData) -> Void) {
        print("init CompanyView")
        self.vm = vm
        self.onChange = onChange

        name = vm.data.name
        orc = vm.data.orc
        cui = vm.data.cui
        address = vm.data.address
        county = vm.data.county
        bankAccount = vm.data.bank_account
        bankName = vm.data.bank_name
        email = vm.data.email ?? ""
        phone = vm.data.phone ?? ""
        web = vm.data.web ?? ""
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
                        vm.data.name = newValue
                        onChange(vm.data)
                    }
                    .modifier(OutlineTextField())
                }
                Stack {
                    Text("Nr.ORC/an*:").foregroundColor(.gray)
                    TextField("", text: $orc).onChange(of: orc) { newValue in
                        vm.data.orc = newValue
                        onChange(vm.data)
                    }
                    .modifier(OutlineTextField())
                }
                Stack {
                    Text("C.U.I.*:").foregroundColor(.gray)
                    TextField("", text: $cui).onChange(of: cui) { newValue in
                        vm.data.cui = newValue
                        onChange(vm.data)
                    }
                    .modifier(OutlineTextField())
                }
                Stack {
                    Text("Sediul*:").foregroundColor(.gray)
                    TextField("", text: $address).onChange(of: address) { newValue in
                        vm.data.address = newValue
                        onChange(vm.data)
                    }
                    .modifier(OutlineTextField())
                }
                Stack {
                    Text("Județul*:").foregroundColor(.gray)
                    TextField("", text: $county).onChange(of: county) { newValue in
                        vm.data.county = newValue
                        onChange(vm.data)
                    }
                    .modifier(OutlineTextField())
                }
                Stack {
                    Text("Contul*:").foregroundColor(.gray)
                    TextField("", text: $bankAccount).onChange(of: bankAccount) { newValue in
                        vm.data.bank_account = newValue
                        onChange(vm.data)
                    }
                    .modifier(OutlineTextField())
                }
                Stack {
                    Text("Banca*:").foregroundColor(.gray)
                    TextField("", text: $bankName).onChange(of: bankName) { newValue in
                        vm.data.bank_name = newValue
                        onChange(vm.data)
                    }
                    .modifier(OutlineTextField())
                }
            }

            Divider()

            Group {
                Stack {
                    Text("Email:").foregroundColor(.gray)
                    TextField("", text: $email).onChange(of: email) { newValue in
                        vm.data.email = newValue != "" ? newValue : nil
                        onChange(vm.data)
                    }
                    .modifier(OutlineTextField())
//                    .modifier(NumberKeyboard())
                }
                Stack {
                    Text("Phone:").foregroundColor(.gray)
                    TextField("", text: $phone).onChange(of: phone) { newValue in
                        vm.data.phone = newValue != "" ? newValue : nil
                        onChange(vm.data)
                    }
                    .modifier(OutlineTextField())
                    .modifier(NumberKeyboard())
                }
                Stack {
                    Text("Website:").foregroundColor(.gray)
                    TextField("", text: $web).onChange(of: web) { newValue in
                        vm.data.web = newValue != "" ? newValue : nil
                        onChange(vm.data)
                    }
                    .modifier(OutlineTextField())
                }
            }
        }

    }

}
