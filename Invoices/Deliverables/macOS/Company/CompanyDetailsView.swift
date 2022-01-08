//
//  CompanyDetailsView.swift
//  Invoices
//
//  Created by Cristian Baluta on 04.10.2021.
//

import SwiftUI

struct CompanyDetailsView: View {
    
    
#if os(iOS)
    typealias Stack = HStack
    let alignment: VerticalAlignment = .center
    let font = Font.system(size: 20)
#else
    typealias Stack = HStack
    let alignment: HorizontalAlignment = .center
    let font = Font.system(size: 12)
#endif
    @ObservedObject var store: CompanyDetailsStore
    private var completion: (CompanyData) -> Void
    
    init (store: CompanyDetailsStore, completion: @escaping (CompanyData) -> Void) {
        self.store = store
        self.completion = completion
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    Stack {
                        Text("Nume*:").foregroundColor(.gray)
                        TextField("...", text: $store.name).onChange(of: store.name) { _ in
                            completion(store.data)
                        }
                    }
                    Stack {
                        Text("Nr.ORC/an*:").foregroundColor(.gray)
                        TextField("...", text: $store.orc).onChange(of: store.orc) { _ in
                            completion(store.data)
                        }
                    }
                    Stack {
                        Text("C.U.I.*:").foregroundColor(.gray)
                        TextField("...", text: $store.cui).onChange(of: store.cui) { _ in
                            completion(store.data)
                        }
                    }
                    Stack {
                        Text("Sediul*:").foregroundColor(.gray)
                        TextField("...", text: $store.address).onChange(of: store.address) { _ in
                            completion(store.data)
                        }
                    }
                    Stack {
                        Text("Județul*:").foregroundColor(.gray)
                        TextField("...", text: $store.county).onChange(of: store.county) { _ in
                            completion(store.data)
                        }
                    }
                    Stack {
                        Text("Contul*:").foregroundColor(.gray)
                        TextField("...", text: $store.bankAccount).onChange(of: store.bankAccount) { _ in
                            completion(store.data)
                        }
                    }
                    Stack {
                        Text("Banca*:").foregroundColor(.gray)
                        TextField("...", text: $store.bankName).onChange(of: store.bankName) { _ in
                            completion(store.data)
                        }
                    }
                }
                
                Divider()
                
                Group {
                    Stack {
                        Text("Email:").foregroundColor(.gray)
                        TextField("...", text: $store.email).onChange(of: store.email) { _ in
                            completion(store.data)
                        }
                    }
                    Stack {
                        Text("Phone:").foregroundColor(.gray)
                        TextField("...", text: $store.phone).onChange(of: store.phone) { _ in
                            completion(store.data)
                        }
                    }
                    Stack {
                        Text("Website:").foregroundColor(.gray)
                        TextField("...", text: $store.web).onChange(of: store.web) { _ in
                            completion(store.data)
                        }
                    }
                }
            }.padding()
        }
    }
}
