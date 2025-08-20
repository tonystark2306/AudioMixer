//
//  Root.swift
//  HustEnglishStudy
//
//  Created by iKame Elite Fresher 2025 on 8/7/25.
//

import SwiftUI

struct Root: View {
    
    @State private var tabSelection: Int = 2
    @Namespace private var animation
    
    var body: some View {
        TabView(selection: $tabSelection) {
            Record()
                .tag(1)
                .tabItem {
                    Image(systemName: "mic.fill")
                    Text("Record")
                }
            
            Mixer()
                .tag(2)
                .tabItem {
                    Image(systemName: "slider.horizontal.3")
                    Text("Mixer")
                }
            
            PlayMusic()
                .tag(3)
                .tabItem {
                    Image(systemName: "music.note")
                    Text("Music")
                }
        }
        .overlay(alignment: .bottom) {
        }
        .ignoresSafeArea()
        
    }
}

#Preview {
    Root()
}
