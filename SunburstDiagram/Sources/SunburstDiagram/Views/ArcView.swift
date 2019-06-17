//
//  ArcView.swift
//  SunburstDiagram
//
//  Created by Ludovic Landry on 6/10/19.
//  Copyright © 2019 Ludovic Landry. All rights reserved.
//

import SwiftUI

// A view drawing a single colored arc with a label
struct ArcView: View {
    
    private let arc: Sunburst.Arc
    private let level: Int
    private let configuration: SunburstConfiguration
    
    init(arc: Sunburst.Arc, level: Int, configuration: SunburstConfiguration) {
        self.arc = arc
        self.level = level
        self.configuration = configuration
    }
    
    var body: some View {
        ZStack() {
            ArcShape(arc, level: level, configuration: configuration).fill(arc.backgroundColor)
            ArcLabel(arc, level: level, configuration: configuration)
        }
    }
}

// A view for the label of the arc (text + image)
struct ArcLabel: View {
    
    private var arc: Sunburst.Arc
    private var level: Int
    private var offset: CGPoint = .zero
    private let configuration: SunburstConfiguration
    
    init(_ arc: Sunburst.Arc, level: Int, configuration: SunburstConfiguration) {
        self.arc = arc
        self.level = level
        self.configuration = configuration
        
        let points = ArcGeometry(arc, level: level, configuration: configuration)
        offset = points[.center]
    }
    
    var body: some View {
        VStack() {
            IfLet(arc.image) { image in
                Image(uiImage: image)
            }
            if !arc.isTextHidden {
                Text(arc.text)
            }
        }
        .offset(x: offset.x, y: offset.y)
    }
}

// A view for the shape of the arc
struct ArcShape: Shape {
    
    private var arc: Sunburst.Arc
    private var level: Int
    private let configuration: SunburstConfiguration
    
    init(_ arc: Sunburst.Arc, level: Int, configuration: SunburstConfiguration) {
        self.arc = arc
        self.level = level
        self.configuration = configuration
    }
    
    func path(in rect: CGRect) -> Path {
        let points = ArcGeometry(arc, level: level, in: rect, configuration: configuration)
        
        var path = Path()
        path.addArc(center: points.center, radius: points.innerRadius,
                    startAngle: .radians(arc.start), endAngle: .radians(arc.end),
                    clockwise: false)
        path.addLine(to: points[.bottomTrailing])
        path.addArc(center: points.center, radius: points.outerRadius,
                    startAngle: .radians(arc.end), endAngle: .radians(arc.start),
                    clockwise: true)
        path.closeSubpath()
        return path
    }
    
    var animatableData: Sunburst.Arc.AnimatableData {
        get { arc.animatableData }
        set { arc.animatableData = newValue }
    }
    
    static func == (lhs: ArcShape, rhs: ArcShape) -> Bool {
        return lhs.arc == rhs.arc && lhs.level == rhs.level
    }
}

// Helper type for creating view-space points within an arc.
private struct ArcGeometry {
    
    var arc: Sunburst.Arc
    var center: CGPoint
    var innerRadius: Length
    var outerRadius: Length
    
    init(_ arc: Sunburst.Arc, level: Int, in rect: CGRect? = nil, configuration: SunburstConfiguration) {
        self.arc = arc
        
        if let rect = rect {
            center = CGPoint(x: rect.midX, y: rect.midY)
        } else {
            self.center = .zero
        }
        
        self.innerRadius = CGFloat(level) * configuration.expandedArcThickness + configuration.innerRadius
        self.outerRadius = self.innerRadius + configuration.expandedArcThickness
    }
    
    // Returns the view location of the point in the arc at unit-
    // space location `unitPoint`, where the X axis of `p` moves around the
    // arc arc and the Y axis moves out from the inner to outer radius.
    subscript(unitPoint: UnitPoint) -> CGPoint {
        let radius = lerp(innerRadius, outerRadius, by: unitPoint.y)
        let angle = lerp(arc.start, arc.end, by: Double(unitPoint.x))
        
        return CGPoint(x: center.x + Length(cos(angle)) * radius,
                       y: center.y + Length(sin(angle)) * radius)
    }
}

// Linearly interpolate from `from` to `to` by the fraction `amount`.
private func lerp<T: BinaryFloatingPoint>(_ fromValue: T, _ toValue: T, by amount: T) -> T {
    return fromValue + (toValue - fromValue) * amount
}
