//
//  CompatibilityView.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 09/02/24.
//

import SwiftUI

internal struct CompatibilityModifier: ViewModifier {
    public var radius: CGFloat
    public var offset: CGFloat
    public var interpolation: CGFloat
    public var direction: BlurDirection
    
    @Environment(\.layoutDirection) var layoutDirection
    
    var evaluatedDirection: BlurDirection.Evaluated {
        direction.evaluate(with: layoutDirection)
    }
    
    func body(content: Content) -> some View {
        content
            .overlay {
                content
                    .drawingGroup()
                    .allowsHitTesting(false)
                    .blur(radius: radius)
                    .scaleEffect(1+(radius*0.02))
                    .mask(gradientMask)
            }
    }
    
    var gradientMask: some View {
        var (startPoint, endPoint) = evaluatedDirection.unitPoints
        
        return LinearGradient(stops: [
            .init(color: .clear, location: 0),
            .init(color: .clear, location: offset),
            .init(color: .black, location: offset+interpolation)
        ],
                       startPoint: startPoint,
                       endPoint: endPoint)
    }
}

fileprivate extension BlurDirection.Evaluated {
    var unitPoints: (UnitPoint, UnitPoint) {
        switch self {
        case .down:
            return (.top, .bottom)
        case .up:
            return (.bottom, .top)
        case .right:
            return (.leading, .trailing)
        case .left:
            return (.trailing, .leading)
        }
    }
}
