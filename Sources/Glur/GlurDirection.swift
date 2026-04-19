//
//  GlurDirection.swift
//
//  Created by João Gabriel Pozzobon dos Santos.
//  Updated by Jonathan Bereyziat on 18/04/26.
//

import SwiftUI

/// How `width` and `height` (in points) extend from the `startingPoint` on the modified view’s layer.
public enum GlurDirection: Hashable, Sendable {
    /// Bottom edge midpoint at the anchor; grows upward by `height`, `width` centered horizontally.
    case up
    /// Top edge midpoint at the anchor; grows downward by `height`, `width` centered horizontally.
    case down
    /// Right edge midpoint at the anchor; grows left by `width`, `height` centered vertically.
    case left
    /// Left edge midpoint at the anchor; grows right by `width`, `height` centered vertically.
    case right
    /// The `width` × `height` rectangle is centered on the anchor.
    case center
    /// Top-leading corner of the rectangle is at the anchor; extends toward greater *x* and *y*.
    case upLeft
    /// Bottom-leading corner of the rectangle is at the anchor; extends up and right.
    case upRight
    /// Top-trailing corner at the anchor; extends down and left.
    case downLeft
    /// Bottom-trailing corner at the anchor; extends up and left.
    case downRight

    /// Normalized `(minX, minY, maxX, maxY)` for the Metal layer (0…1 per axis), clipped to the layer.
    ///
    /// The anchor is `startingPoint` mapped with `layerSize`: `(x * layerWidth, y * layerHeight)` in points.
    /// `width` and `height` arguments are the blur region’s size **in points**, not fractions.
    func normalizedBounds(
        startingPoint: UnitPoint,
        width: CGFloat,
        height: CGFloat,
        layerSize: CGSize
    ) -> SIMD4<Float> {
        let W = max(layerSize.width, 0)
        let H = max(layerSize.height, 0)
        guard W > 0, H > 0 else {
            return .zero
        }

        let w = max(width, 0)
        let h = max(height, 0)
        let px = CGFloat(startingPoint.x) * W
        let py = CGFloat(startingPoint.y) * H

        let rect: CGRect
        switch self {
        case .up:
            rect = CGRect(x: px - w / 2, y: py - h, width: w, height: h)
        case .down:
            rect = CGRect(x: px - w / 2, y: py, width: w, height: h)
        case .left:
            rect = CGRect(x: px - w, y: py - h / 2, width: w, height: h)
        case .right:
            rect = CGRect(x: px, y: py - h / 2, width: w, height: h)
        case .center:
            rect = CGRect(x: px - w / 2, y: py - h / 2, width: w, height: h)
        case .upLeft:
            rect = CGRect(x: px, y: py, width: w, height: h)
        case .upRight:
            rect = CGRect(x: px, y: py - h, width: w, height: h)
        case .downLeft:
            rect = CGRect(x: px - w, y: py, width: w, height: h)
        case .downRight:
            rect = CGRect(x: px - w, y: py - h, width: w, height: h)
        }

        let c = rect.intersection(CGRect(x: 0, y: 0, width: W, height: H))
        return SIMD4<Float>(Float(c.minX / W), Float(c.minY / H), Float(c.maxX / W), Float(c.maxY / H))
    }
}
