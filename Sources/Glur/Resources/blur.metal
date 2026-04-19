//
//  blur.metal
//  WWDCApp
//
//  Created by João Gabriel Pozzobon dos Santos on 06/06/23.
//  Updated by Jonathan Bereyziat on 18/04/26.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

#define kernelSize (64)

/// Signed distance to an axis-aligned box in normalized coordinates (negative inside, positive outside).
static float boxSdf(float2 p, float4 b) {
    float2 center = float2((b.x + b.z) * 0.5, (b.y + b.w) * 0.5);
    float2 halfSize = float2((b.z - b.x) * 0.5, (b.w - b.y) * 0.5);
    float2 d = abs(p - center) - halfSize;
    return length(max(d, float2(0.0))) + min(max(d.x, d.y), 0.0);
}

float mapRadius(float2 position,
                float2 size,
                float radius,
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
    return min(t * radius, radius);
}

void calculateGaussianWeights(float radius,
                              thread half weights[]) {
    half sum = 0.0;

    for (int i = 0; i < kernelSize; ++i) {
        float x = i-(kernelSize-1)/2;
        weights[i] = exp(-(x*x)/(2.0*radius*radius));
        sum+= weights[i];
    }

    for (int i = 0; i < kernelSize; ++i) {
        weights[i]/= sum;
    }
}

[[ stitchable ]] half4 blurX(float2 position,
                             SwiftUI::Layer layer,
                             float radius,
                             float4 bounds,
                             float spread,
                             float2 size) {
    float r = mapRadius(position,
                        size,
                        radius,
                        bounds,
                        spread);

    if (r < 1e-3) {
        return layer.sample(position);
    }

    half weights[kernelSize];
    calculateGaussianWeights(r, weights);

    half4 result = half4(0.0);
    for (int i = 0; i < kernelSize; ++i) {
        float sampleOffset = i-(kernelSize-1)/2;
        float x = clamp(position.x+sampleOffset, 0.0, size.x-1.0);

        result+= layer.sample(float2(x, position.y))*weights[i];
    }

    return result;
}

[[ stitchable ]] half4 blurY(float2 position,
                             SwiftUI::Layer layer,
                             float radius,
                             float4 bounds,
                             float spread,
                             float2 size) {
    float r = mapRadius(position,
                        size,
                        radius,
                        bounds,
                        spread);

    if (r < 1e-3) {
        return layer.sample(position);
    }

    half weights[kernelSize];
    calculateGaussianWeights(r, weights);

    half4 result = half4(0.0);
    for (int i = 0; i < kernelSize; ++i) {
        float sampleOffset = i-(kernelSize-1)/2;
        float y = clamp(position.y+sampleOffset, 0.0, size.y-1.0);

        result+= layer.sample(float2(position.x, y))*weights[i];
    }

    return result;
}
