//
//  JsonityApp.swift
//  Jsonity
//
//  Created by MrDev on 26/02/2022.
//

import SwiftUI

@main
struct JsonityApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
