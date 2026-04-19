//
//  CompatibilityView.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 09/02/24.
//  Updated by Jonathan Bereyziat on 18/04/26.
//

import SwiftUI

internal struct CompatibilityModifier: ViewModifier {
    public var startingPoint: UnitPoint
    public var direction: GlurDirection
    public var width: CGFloat
    public var height: CGFloat
    public var radius: CGFloat
    /// Softness in normalized view space (0 = sharp), matching the Metal `spread` parameter.
    public var spread: CGFloat
    public var drawingGroup: Bool

    private func maskRect(in size: CGSize) -> CGRect {
        let b = direction.normalizedBounds(
            startingPoint: startingPoint,
            width: width,
            height: height,
            layerSize: size
        )
        return CGRect(
            x: CGFloat(b.x) * size.width,
            y: CGFloat(b.y) * size.height,
            width: CGFloat(b.z - b.x) * size.width,
            height: CGFloat(b.w - b.y) * size.height
        )
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        if radius.isZero {
            content
        } else {
            content
                .overlay {
                    GeometryReader { proxy in
                        let r = maskRect(in: proxy.size)
                        let m = min(proxy.size.width, proxy.size.height)
                        let spreadPx = max(spread, 0) * m
                        let expanded = r.insetBy(dx: -spreadPx, dy: -spreadPx)

                        Group {
                            if drawingGroup {
                                content
                                    .drawingGroup()
                            } else {
                                content
                            }
                        }
                        .allowsHitTesting(false)
                        .blur(radius: radius)
                        .scaleEffect(1 + (radius * 0.02))
                        .mask {
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: expanded.width, height: expanded.height)
                                .position(x: expanded.midX, y: expanded.midY)
                                .blur(radius: spreadPx > 0 ? spreadPx * 0.5 : 0)
                        }
                    }
                }
        }
    }
}
