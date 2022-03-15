//
//  MyApp.swift
//  CSR Create
//
//  Copyright © 2022 Keith R. Davis
//

import SwiftUI

// Global scaling values
let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
let scaleFactor = deviceIdiom == .phone ? 0.52 : 1.0
let fontSize = deviceIdiom == .phone ? 24.0 : 32.0

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}
