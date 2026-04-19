//
//  ContentView.swift
//  GlurDemo
//
//  Created by João Gabriel Pozzobon dos Santos on 10/06/23.
//  Updated by Jonathan Bereyziat on 18/04/26.
//

import SwiftUI
import Glur

struct ContentView: View {
    var body: some View {
        ZStack {
            Color("Black")
                .ignoresSafeArea()
            
            TabView {
                icon
                    .tabItem {
                        Label("Icon", systemImage: "star")
                    }
                
                albumCover
                    .tabItem {
                        Label("Album", systemImage: "photo")
                    }
            }
            #if os(iOS)
            .tabViewStyle(.page)
            #else
            .padding()
            #endif
            .padding(.vertical)
        }
        .preferredColorScheme(.dark)
    }
    
    var icon: some View {
        LinearGradient(colors: [Color("Color 1"), Color("Color 2"), Color("Color 3")], startPoint: .top, endPoint: .bottom)
            .aspectRatio(1.0, contentMode: .fit)
            .frame(width: 128)
            .clipShape(.rect(cornerRadius: 57/2))
            .padding(32)
            .background(Color("Black"))
            .glur(startingPoint: UnitPoint(x: 0.5, y: 0.35), direction: .down, width: 128, height: 83, radius: 32.0)
    }
    
    var albumCover: some View {
        Image("Sunburn")
            .resizable()
            .aspectRatio(1.0, contentMode: .fit)
            .frame(width: 256)
            .glur(startingPoint: UnitPoint(x: 0.5, y: 0.7), direction: .down, width: 256, height: 77, radius: 8.0)
            .overlay {
                LinearGradient(stops: [.init(color: .clear, location: 0.5), .init(color: .black.opacity(0.6), location: 0.8)], startPoint: .top, endPoint: .bottom)
            }
            .clipShape(.rect(cornerRadius: 12.0))
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading) {
                    Text("Sunburn")
                        .font(.headline)
                    Text("Dominic Fike")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
    }
}

#Preview {
    ContentView()
}
