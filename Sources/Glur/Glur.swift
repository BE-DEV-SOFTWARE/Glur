//
//  Glur.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 09/02/24.
//  Updated by Jonathan Bereyziat on 18/04/26.
//

import SwiftUI

extension View {
    /// A modifier that applies a blur confined to a rectangular region of the view.
    ///
    /// - Parameters:
    ///   - startingPoint: Anchor as a `UnitPoint` over the **modified** view’s bounds: `(x * layerWidth, y * layerHeight)` in points. Values may lie outside 0…1; the region is clipped to the layer.
    ///   - direction: How the `width` × `height` rectangle is placed relative to that anchor (see `GlurDirection`).
    ///   - width: Region width in **points** (non-negative), relative to the layer the modifier measures.
    ///   - height: Region height in **points** (non-negative).
    ///   - radius: Blur radius when the effect is fully applied.
    ///   - spread: Edge softness in normalized layer space (0 = sharp).
    ///   - noise: Noise strength inside the blurred region.
    ///   - drawingGroup: Whether to pre-render with `drawingGroup()`.
    public func glur(
        startingPoint: UnitPoint,
        direction: GlurDirection,
        width: CGFloat,
        height: CGFloat,
        radius: CGFloat = 8.0,
        spread: CGFloat = 0.07,
        noise: CGFloat = 0.1,
        drawingGroup: Bool = true
    ) -> some View {
        assert(width >= 0.0, "width must be greater than or equal to 0")
        assert(height >= 0.0, "height must be greater than or equal to 0")
        assert(radius >= 0.0, "Radius must be greater than or equal to 0")
        assert(spread >= 0.0, "spread must be greater than or equal to 0")
        assert(noise >= 0.0, "Noise must be greater than or equal to 0")

        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, *) {
            return modifier(
                GlurModifier(
                    startingPoint: startingPoint,
                    direction: direction,
                    width: width,
                    height: height,
                    radius: radius,
                    spread: spread,
                    noise: noise,
                    drawingGroup: drawingGroup
                )
            )
        } else {
            return modifier(
                CompatibilityModifier(
                    startingPoint: startingPoint,
                    direction: direction,
                    width: width,
                    height: height,
                    radius: radius,
                    spread: spread,
                    drawingGroup: drawingGroup
                )
            )
        }
    }
}
