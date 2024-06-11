//
//  Shapes.swift
//  nailScope
//
//  Created by Iriss Vivi on 09/01/2024.
//
//
//import SwiftUI
//
//struct Arc: Shape{
//    func path(in rect:CGRect)-> Path {
//        var path = Path()
//        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
//        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),control: CGPoint(x:rect.minY, y:rect.minY))
//        path.addLine(to: CGPoint(x: rect.maxX + 1, y: rect.maxY+1))
//        path.addLine(to: CGPoint(x: rect.minX - 1, y: rect.maxY + 1))
//        return path
//    }
//}
