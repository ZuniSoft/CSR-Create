//
//  SplashView.swift
//  CSR Create
//
//  Copyright © 2022 Keith R. Davis
//

import SwiftUI

struct SplashView: View {
    
    @State var isActive:Bool = false
    
    var body: some View {
        VStack {
            if self.isActive {
                InfoView()
            } else {
                Image("Splash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350.0 * scaleFactor, height: 350.0 * scaleFactor)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
    
}
