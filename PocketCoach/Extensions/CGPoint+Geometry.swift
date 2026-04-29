import CoreGraphics
import Foundation

extension CGPoint {

    /// Angle in degrees at `self` (the vertex), formed by vectors to `a` and `b`.
    func angle(to a: CGPoint, and b: CGPoint) -> Double {
        let vA = CGVector(dx: a.x - x, dy: a.y - y)
        let vB = CGVector(dx: b.x - x, dy: b.y - y)
        let dot = vA.dx * vB.dx + vA.dy * vB.dy
        let magA = sqrt(vA.dx * vA.dx + vA.dy * vA.dy)
        let magB = sqrt(vB.dx * vB.dx + vB.dy * vB.dy)
        guard magA > 0, magB > 0 else { return 0 }
        let cosTheta = (dot / (magA * magB)).clamped(to: -1...1)
        return acos(cosTheta) * (180 / .pi)
    }

    /// Angle in degrees that the vector from `self` to `other` makes with the positive x-axis.
    func bearing(to other: CGPoint) -> Double {
        let dx = other.x - x
        let dy = other.y - y
        return atan2(dy, dx) * (180 / .pi)
    }

    /// Euclidean distance to another point.
    func distance(to other: CGPoint) -> Double {
        sqrt(pow(other.x - x, 2) + pow(other.y - y, 2))
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
