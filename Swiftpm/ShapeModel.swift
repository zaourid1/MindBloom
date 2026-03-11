//
//  ShapeModel.swift
//  MindBloom
//
//  Created by Zineb Aourid on 2026-02-22.
//
// Simple ML model using KNN
//
import Foundation

enum KNNShapeModel {

    struct Prediction {
        let label: ShapeLabel?
        let confidence: Double
        let neighborLabels: [ShapeLabel]
        let neighborDistances: [Double]
    }

    static func predict(x: [Double], samples: [TrainingSample], k: Int = 3) -> Prediction {
        guard !samples.isEmpty else {
            return Prediction(label: nil, confidence: 0, neighborLabels: [], neighborDistances: [])
        }

        let top = samples
            .map { ($0, euclidean(x, $0.features)) }
            .sorted { $0.1 < $1.1 }
            .prefix(max(1, min(k, samples.count)))

        var votes: [ShapeLabel: Int] = [:]
        top.forEach { votes[$0.0.label, default: 0] += 1 }

        let best = votes.max { $0.value < $1.value }
        let confidence = Double(best?.value ?? 0) / Double(top.count)

        return Prediction(
            label: best?.key,
            confidence: confidence,
            neighborLabels: top.map { $0.0.label },
            neighborDistances: top.map { $0.1 }
        )
    }

    static func leaveOneOutAccuracy(samples: [TrainingSample], k: Int = 3) -> Double {
        guard samples.count >= 2 else { return 0 }
        let correct = samples.indices.filter { i in
            var rest = samples
            let held = rest.remove(at: i)
            return predict(x: held.features, samples: rest, k: k).label == held.label
        }.count
        return Double(correct) / Double(samples.count)
    }

    private static func euclidean(_ a: [Double], _ b: [Double]) -> Double {
        let sum = zip(a, b).reduce(0.0) { acc, pair in
            let d = pair.0 - pair.1; return acc + d * d
        }
        return sum == 0 ? .infinity : sqrt(sum)
    }
}
