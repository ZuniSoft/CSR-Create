//
//  ContentView.swift
//  CSR Create
//
//  Copyright © 2022 Keith R. Davis
//

import SwiftUI

struct ContentView: View {
    
    let csr = CSR()
    
    @State var commonName: String = ""
    @State var orgName: String = ""
    @State var orgUnitName: String = ""
    @State var countryName: String = ""
    @State var stateProvName: String = ""
    @State var localityName: String = ""
    @State var emailAddress: String = ""
    @State var description: String = ""
    @State var csrText = ""
    @State var format = "With Headers"
    @State var keySize = "2048"
    @State var sigType = "sha512"
    
    let formats = ["With Headers", "Without Headers"]
    let keySizes = ["512", "1024", "2048"]
    let sigTypes = ["sha1", "sha256", "sha512"]
    let countryNameLimit = 2
    
    var body: some View {
        VStack {
            Form {
                Section {
                    Label {
                        Text("CSR Create")
                            .font(.title)
                    } icon: {}
                }
                
                Section(header: Text("Instructions")) {
                    HStack {
                        Label {
                            Text("Fill your information in the first section. Required fields are marked with an asterisk (*). Select cryptography options for the CSR. Press 'Create Request' when you are finished. Your CSR will appear at the bottom of the app. The generated keys are stored in your keychain.")
                                .fixedSize(horizontal: false, vertical: true)
                        } icon: {}
                    }
                }
                
                Section(header: Text("Request Data")) {
                    TextField("Common Name*", text: $commonName)
                    TextField("Organization Name*", text: $orgName)
                    TextField("Organization Unit Name", text: $orgUnitName)
                    TextField("Country Name [2 letter]*", text: $countryName)
                        .onReceive(countryName.publisher.collect()) {
                            let s = String($0.prefix(countryNameLimit))
                            if countryName != s {
                                countryName = s
                            }
                        }
                    TextField("State or Province Name*", text: $stateProvName)
                    TextField("Locality Name*", text: $localityName)
                    TextField("Email Address*", text: $emailAddress)
                    TextField("Description", text: $description)
                }
                
                Section(header: Text("Signature Type")) {
                    Picker("Select a signature type", selection: $sigType) {
                        ForEach(sigTypes, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Key Size")) {
                    Picker("Select a key length", selection: $keySize) {
                        ForEach(keySizes, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Output FOrmat Options")) {
                    Picker("Select a data format", selection: $format) {
                        ForEach(formats, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section {
                    Button("Create Request") {
                        csrText = self.csr.Create(commonName: commonName,
                                                  organizationName: orgName,
                                                  organizationUnitName: orgUnitName,
                                                  countryName: countryName,
                                                  stateOrProvinceName: stateProvName,
                                                  localityName: localityName,
                                                  emailAddress: emailAddress,
                                                  description: description,
                                                  format: format,
                                                  keySize: keySize,
                                                  sigType: sigType)
                    } 
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .buttonStyle(.plain)
                    .disabled(commonName.isEmpty ||
                              orgName.isEmpty ||
                              countryName.isEmpty ||
                              stateProvName.isEmpty ||
                              localityName.isEmpty ||
                              emailAddress.isEmpty)
                }
                
                Section(header: Text("CSR (long press & select copy)")) {
                    Text(csrText)
                        .textSelection(.enabled)
                }
            }
        }
    }
}
