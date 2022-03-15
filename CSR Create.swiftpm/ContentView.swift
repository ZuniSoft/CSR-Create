//
//  ContentView.swift
//  CSR Create
//
//  Copyright © 2022 Keith R. Davis
//

import SwiftUI

struct ContentView: View {
    
    let csr = CSR()
    
    var body: some View {
        Form {
            Section {
                Text("Hello, world!")
            }
            
            Section {
                Text("Hello, world!")
                Text("Hello, world!")
            }
        }
    }
}
