//
//  nailScopeApp.swift
//  nailScope
//
//  Created by Iriss Vivi on 05/01/2024.
//

import SwiftUI

@main
struct nailScopeApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(tabBar: TabBar(savedPhotos: ["art 1", "art 3", "art 5"]))
        }
    }
}

