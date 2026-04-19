//
//  GlurModifier.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 09/02/24.
//  Updated by Jonathan Bereyziat on 18/04/26.
//

import SwiftUI

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
internal struct GlurModifier: ViewModifier {
    public var startingPoint: UnitPoint
    public var direction: GlurDirection
    public var width: CGFloat
    public var height: CGFloat
    public var radius: CGFloat
    /// Edge softness in normalized layer space (1 = full view). Shader uses `smoothstep(-spread, spread, sdf)`.
    public var spread: CGFloat
    public var noise: CGFloat
    public var drawingGroup: Bool

    @State var size: CGSize = .zero

    let library = ShaderLibrary.bundle(.module)

    private var bounds: SIMD4<Float> {
        direction.normalizedBounds(
            startingPoint: startingPoint,
            width: width,
            height: height,
            layerSize: size
        )
    }

    var blurX: Shader {
        var shader = library.blurX(
            .float(radius),
            .float4(bounds.x, bounds.y, bounds.z, bounds.w),
            .float(spread),
            .float2(size)
        )
        shader.dithersColor = true
        return shader
    }

    var blurY: Shader {
        var shader = library.blurY(
            .float(radius),
            .float4(bounds.x, bounds.y, bounds.z, bounds.w),
            .float(spread),
            .float2(size)
        )
        shader.dithersColor = true
        return shader
    }

    var noiseShader: Shader {
        var shader = library.noise(
            .float(noise),
            .float4(bounds.x, bounds.y, bounds.z, bounds.w),
            .float(spread),
            .float2(size)
        )
        shader.dithersColor = true
        return shader
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        if radius.isZero {
            content
        } else {
            Group {
                if drawingGroup {
                    content.drawingGroup()
                } else {
                    content
                }
            }
            .overlay {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: proxy.size)
                }
                .allowsHitTesting(false)
            }
            .onPreferenceChange(SizePreferenceKey.self) { size in
                self.size = size
            }
            .layerEffect(blurX, maxSampleOffset: .zero)
            .layerEffect(blurY, maxSampleOffset: .zero)
            .layerEffect(noiseShader, maxSampleOffset: .zero)
        }
    }
}

fileprivate struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
