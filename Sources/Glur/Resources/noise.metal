//
//  noise.metal
//
//
//  Created by João Gabriel Pozzobon dos Santos on 24/04/24.
//  Updated by Jonathan Bereyziat on 18/04/26.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

static float boxSdf(float2 p, float4 b) {
    float2 center = float2((b.x + b.z) * 0.5, (b.y + b.w) * 0.5);
    float2 halfSize = float2((b.z - b.x) * 0.5, (b.w - b.y) * 0.5);
    float2 d = abs(p - center) - halfSize;
    return length(max(d, float2(0.0))) + min(max(d.x, d.y), 0.0);
}

float mapStrength(float2 position,
                  float2 size,
                  float strength,
                  float4 bounds,
                  float spread) {
    float2 pn = float2(position.x / size.x, position.y / size.y);
    float sdf = boxSdf(pn, bounds);

    float t;
    if (spread <= 0.0) {
        t = sdf <= 0.0 ? 1.0 : 0.0;
    } else {
        t = 1.0 - smoothstep(-spread, spread, sdf);
    }

    t = clamp(t, 0.0, 1.0);
    return min(t * strength, strength);
}

float overlay(float base, float blend) {
    return (base <= 0.5) ? (2.0*base*blend) : (1.0-2.0*(1.0-base)*(1.0-blend));
}

float rand(float2 st) {
    return fract(sin(dot(st.xy,
                         float2(12.9898,78.233)))*
                 43758.5453123);
}

[[ stitchable ]] half4 noise(float2 position,
                             SwiftUI::Layer layer,
                             float strength,
                             float4 bounds,
                             float spread,
                             float2 size) {
    float s = mapStrength(position,
                          size,
                          strength,
                          bounds,
                          spread);

    float2 pos = position*10;
    float2 floored = floor(pos);

    float white = rand(floored)*0.5+0.5;
    half4 color = layer.sample(float2(position.x, position.y));

    float r = overlay(color.r, white);
    float g = overlay(color.g, white);
    float b = overlay(color.b, white);

    half4 newColor = half4(r, g, b, color.a);
    return mix(color, newColor, s);
}
