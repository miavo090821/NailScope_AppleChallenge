//
//  Extensions.swift
//  nailScope
//  Created by Iriss Vivi on 08/01/2024.
//

import SwiftUI
import UIKit
import CoreGraphics
import CoreVideo

extension Color {
    static let background = LinearGradient(gradient: Gradient(colors: [Color("Background 1"), Color("Background 2")]),
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
    static let shapeBackground = LinearGradient(gradient: Gradient(colors: [Color("Background 2").opacity(0.26), Color("What's the trend").opacity(0.26)]), startPoint: .topLeading, endPoint: .bottomTrailing)
    static let WhatsTheTrendNow = LinearGradient(gradient: Gradient(colors: [Color("What's the trend").opacity(0.1), Color("Tip Background")]), startPoint: .topLeading, endPoint: .bottom)
    static let bottomSheetBackground = LinearGradient(gradient: Gradient(colors: [Color("Background 1").opacity(0.26), Color("Background 2").opacity(0.26)]), startPoint: .topLeading, endPoint: .bottomTrailing)
    static let bottomSheetBorderMiddle = LinearGradient(gradient: Gradient(stops: [.init(color: .white, location: 0), .init(color: .clear, location: 0.2)]), startPoint: .top, endPoint: .bottom)
    static let bottomSheetBorderTop = LinearGradient(gradient: Gradient(colors: [.white.opacity(0), .white.opacity(0.5), .white.opacity(0)]), startPoint: .leading, endPoint: .trailing)
    static let tabBarBackground = LinearGradient(gradient: Gradient(colors: [Color("What's the trend").opacity(0.6), Color("Tips background").opacity(0.6)]), startPoint: .top, endPoint: .bottom)
    
    static let tabBarBorder = Color("Background 1").opacity(0.5)
}
