import XCTest
@testable import PocketCoach

final class CGPointGeometryTests: XCTestCase {

    // MARK: - Angle

    func test_angle_90degrees() {
        let vertex = CGPoint(x: 0, y: 0)
        let a      = CGPoint(x: 1, y: 0)
        let b      = CGPoint(x: 0, y: 1)
        XCTAssertEqual(vertex.angle(to: a, and: b), 90, accuracy: 0.001)
    }

    func test_angle_180degrees_straightLine() {
        let vertex = CGPoint(x: 0, y: 0)
        let a      = CGPoint(x: 1, y: 0)
        let b      = CGPoint(x: -1, y: 0)
        XCTAssertEqual(vertex.angle(to: a, and: b), 180, accuracy: 0.001)
    }

    func test_angle_0degrees_sameDirection() {
        let vertex = CGPoint(x: 0, y: 0)
        let a      = CGPoint(x: 1, y: 0)
        let b      = CGPoint(x: 2, y: 0)
        XCTAssertEqual(vertex.angle(to: a, and: b), 0, accuracy: 0.001)
    }

    func test_angle_45degrees() {
        let vertex = CGPoint(x: 0, y: 0)
        let a      = CGPoint(x: 1, y: 0)
        let b      = CGPoint(x: 1, y: 1)
        XCTAssertEqual(vertex.angle(to: a, and: b), 45, accuracy: 0.001)
    }

    func test_angle_isSymmetric() {
        let vertex = CGPoint(x: 0.5, y: 0.5)
        let a      = CGPoint(x: 0.3, y: 0.7)
        let b      = CGPoint(x: 0.8, y: 0.2)
        let forward  = vertex.angle(to: a, and: b)
        let reversed = vertex.angle(to: b, and: a)
        XCTAssertEqual(forward, reversed, accuracy: 0.001)
    }

    func test_angle_withCoincidentPoints_returnsZero() {
        let vertex = CGPoint(x: 0.5, y: 0.5)
        XCTAssertEqual(vertex.angle(to: vertex, and: CGPoint(x: 1, y: 0)), 0, accuracy: 0.001)
    }

    // MARK: - Distance

    func test_distance_unitVectors() {
        let origin = CGPoint(x: 0, y: 0)
        XCTAssertEqual(origin.distance(to: CGPoint(x: 3, y: 4)), 5, accuracy: 0.001)
    }

    func test_distance_isSymmetric() {
        let a = CGPoint(x: 0.1, y: 0.2)
        let b = CGPoint(x: 0.5, y: 0.8)
        XCTAssertEqual(a.distance(to: b), b.distance(to: a), accuracy: 0.001)
    }

    func test_distance_toSelf_isZero() {
        let p = CGPoint(x: 0.3, y: 0.7)
        XCTAssertEqual(p.distance(to: p), 0, accuracy: 0.001)
    }

    // MARK: - Clamped

    func test_clamped_withinRange() {
        XCTAssertEqual(0.5.clamped(to: 0.0...1.0), 0.5)
    }

    func test_clamped_belowRange() {
        XCTAssertEqual((-0.1).clamped(to: -1.0...1.0), -1.0)
    }

    func test_clamped_aboveRange() {
        XCTAssertEqual(1.1.clamped(to: -1.0...1.0), 1.0)
    }
}
