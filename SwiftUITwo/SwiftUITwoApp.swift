//
//  SwiftUITwoApp.swift
//  SwiftUITwo
//
//  Created by Pawel Kowalczuk on 11/02/2021.
//

import SwiftUI

struct Env {
    static var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    static var isIPAD: Bool {
        idiom == .pad
    }
    static var isIPHONE: Bool {
        !isIPAD
    }
}

@main
struct SwiftUITwoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }.navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
