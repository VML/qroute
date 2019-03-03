
import XCTest
import QTRoute

class QTRouteDriverTests: XCTestCase {

    var subject: QTRouteDriver!

    func linearAncestors() -> (first: QTRoute, second: QTRoute, third: QTRoute) {
        let third = QTRoute("third")
        let second = QTRoute("second", third)
        let first = QTRoute("first", second)
        return (first, second, third)
    }

    override func setUp() {
        subject = QTRouteDriver()
    }

    func test_driveTo_nowhere() {
        given("routable for route with no parent or children") {
            let marco = QTRoute("marco")
            let mockRouteResolver = MockQTRouteResolver(marco)
            let mockRoutable = MockQTRoutable(mockRouteResolver)

            when("trying to route to non-existent route") {
                let expectComplete = expectation(description: "complete")
                var finalResolver: MockQTRouteResolver? = mockRouteResolver

                subject.driveTo("polo", from: mockRoutable, input: nil,
                                animated: true,
                                completion: {
                                    finalResolver = $0?.routeResolver as? MockQTRouteResolver
                                    expectComplete.fulfill() })

                wait(for: [expectComplete], timeout: 0.1)
                then("it should not go anywhere") {
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToChild, 0)
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToSelf, 0)
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToParent, 0)
                    XCTAssertEqual(finalResolver?.routeTrail, [])
                }
            }
        }
    }

    func test_driveTo_linear_parent() {
        given("routes first -> second -> third") {
            let (first, second, _) = self.linearAncestors()

            when("second routes to first") {
                let mockRouteResolver = MockQTRouteResolver(second)
                let mockRoutable = MockQTRoutable(mockRouteResolver)
                let expectComplete = expectation(description: "complete")
                var finalResolver: MockQTRouteResolver? = mockRouteResolver

                subject.driveTo("first", from: mockRoutable, input: nil,
                                animated: true,
                                completion: {
                                    finalResolver = $0?.routeResolver as? MockQTRouteResolver
                                    expectComplete.fulfill() })

                wait(for: [expectComplete], timeout: 0.1)
                then("it should have routed to parent one times landing on 'first'") {
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToChild, 0)
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToSelf, 0)
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToParent, 1)
                    XCTAssertEqual(finalResolver?.routeTrail, [first])
                }
            }
        }
    }

    func test_driveTo_linear_child() {
        given("routes first -> second -> third") {
            let (_, second, third) = self.linearAncestors()

            when("second routes to third") {
                let mockRouteResolver = MockQTRouteResolver(second)
                let mockRoutable = MockQTRoutable(mockRouteResolver)
                let expectComplete = expectation(description: "complete")
                var finalResolver: MockQTRouteResolver? = mockRouteResolver

                subject.driveTo("third", from: mockRoutable, input: nil,
                                animated: false,
                                completion: {
                                    finalResolver = $0?.routeResolver as? MockQTRouteResolver
                                    expectComplete.fulfill() })

                wait(for: [expectComplete], timeout: 0.1)
                then("it should have routed to child one times landing on third") {
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToChild, 1)
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToSelf, 0)
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToParent, 0)
                    XCTAssertEqual(finalResolver?.routeTrail, [third])
                }
            }
        }
    }


    func test_driveTo_linear_self() {
        given("routes first -> second -> third") {
            let (_, second, _) = self.linearAncestors()

            when("second routes to self") {
                let mockRouteResolver = MockQTRouteResolver(second)
                let mockRoutable = MockQTRoutable(mockRouteResolver)
                let expectComplete = expectation(description: "complete")
                var finalResolver: MockQTRouteResolver? = mockRouteResolver

                subject.driveTo("second", from: mockRoutable, input: nil,
                                animated: false,
                                completion: {
                                    finalResolver = $0?.routeResolver as? MockQTRouteResolver
                                    expectComplete.fulfill() })

                wait(for: [expectComplete], timeout: 0.1)
                then("it should have routed to self one times") {
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToChild, 0)
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToSelf, 1)
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToParent, 0)
                    XCTAssertEqual(finalResolver?.routeTrail, [second])
                }
            }
        }
    }

    func test_driveTo_linear_grandchild() {
        given("routes first -> second -> third") {
            let (first, second, third) = self.linearAncestors()

            when("first routes to third") {
                let mockRouteResolver = MockQTRouteResolver(first)
                let mockRoutable = MockQTRoutable(mockRouteResolver)
                let expectComplete = expectation(description: "complete")
                var finalResolver: MockQTRouteResolver? = mockRouteResolver

                subject.driveTo("third", from: mockRoutable, input: nil,
                                animated: false,
                                completion: {
                                    finalResolver = $0?.routeResolver as? MockQTRouteResolver
                                    expectComplete.fulfill() })

                wait(for: [expectComplete], timeout: 0.1)
                then("it should have routed to child two times landing on 'third'") {
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToChild, 2)
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToSelf, 0)
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToParent, 0)
                    XCTAssertEqual(finalResolver?.routeTrail, [second, third])
                    XCTAssertEqual(finalResolver?.route, third)
                }
            }
        }
    }

    func test_driveTo_linear_grandparent() {
        given("routes first -> second -> third") {
            let (first, second, third) = self.linearAncestors()

            when("third routes to first") {
                let mockRouteResolver = MockQTRouteResolver(third)
                let mockRoutable = MockQTRoutable(mockRouteResolver)
                let expectComplete = expectation(description: "complete")
                var finalResolver: MockQTRouteResolver? = mockRouteResolver

                subject.driveTo("first", from: mockRoutable, input: nil,
                                animated: false,
                                completion: {
                                    finalResolver = $0?.routeResolver as? MockQTRouteResolver
                                    expectComplete.fulfill() })

                wait(for: [expectComplete], timeout: 0.1)
                then("it should have routed to parent two times landing on 'first'") {
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToChild, 0)
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToSelf, 0)
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToParent, 2)
                    XCTAssertEqual(finalResolver?.routeTrail, [second, first])
                }
            }
        }
    }

    func test_driveTo_complex() {
        given("MockQTRoutePlan") {
            let root = MockQTRoutePlan()
            let bravo = root.route("Bravo")!
            let bravoOne = bravo.route("BravoOne")!
            let bravoOneAlpha = bravoOne.route("BravoOneAlpha")!
            let help = root.route("Zach")!
            let zachTwo = help.route("ZachTwo")!

            when("routing 'BravoOneAlpha' to 'ZachTwo'") {
                let mockRouteResolver = MockQTRouteResolver(bravoOneAlpha)
                let mockRoutable = MockQTRoutable(mockRouteResolver)
                let expectComplete = expectation(description: "complete")
                var finalResolver: MockQTRouteResolver? = mockRouteResolver

                subject.driveTo("ZachTwo", from: mockRoutable, input: nil,
                                animated: false,
                                completion: {
                                    finalResolver = $0?.routeResolver as? MockQTRouteResolver
                                    expectComplete.fulfill() })

                wait(for: [expectComplete], timeout: 0.1)
                then("it should have routed to parent 3 times and child 2 times landing at 'ZachTwo'") {
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToChild, 2)
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToSelf, 0)
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToParent, 3)
                    XCTAssertEqual(finalResolver?.routeTrail, [bravoOne, bravo, root, help, zachTwo])
                }
            }
        }
    }

    func test_driveSub() {
        given("MockQTRoutePlan") {
            let root = MockQTRoutePlan()
            let bravo = root.route("Bravo")!
            let bravoOne = bravo.route("BravoOne")!
            let zachTwo = root.route("Zach")!.route("ZachTwo")!

            when("substitute routing 'BravoOne' to 'ZachTwo'") {
                let mockRouteResolver = MockQTRouteResolver(bravoOne)
                let mockRoutable = MockQTRoutable(mockRouteResolver)
                let expectComplete = expectation(description: "complete")
                var landingRoutable: MockQTRoutable?
                var finalResolver: MockQTRouteResolver? = mockRouteResolver

                subject.driveSub("ZachTwo", from: mockRoutable, input: nil,
                                 animated: false,
                                 completion: {
                                    landingRoutable = $0 as? MockQTRoutable
                                    finalResolver = $0?.routeResolver as? MockQTRouteResolver
                                    expectComplete.fulfill() })

                wait(for: [expectComplete], timeout: 0.1)
                then("it should have routed to child 1 times landing at 'ZachTwo' clone") {
                    let zachTwoClone = finalResolver!.route
                    XCTAssertEqual(finalResolver?.routeTrail, [zachTwoClone])
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToChild, 1)
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToSelf, 0)
                    XCTAssertEqual(finalResolver?.timesCalled_resolveRouteToParent, 0)
                    with("'ZachTwo' Clone not the same instance as 'ZachTwo'") {
                        XCTAssert(zachTwoClone !== zachTwo)
                    }
                    with("'ZachTwo' Clone parent property set to actual 'BravoOne'") {
                        XCTAssertEqual(zachTwoClone.parent, bravoOne)
                    }
                    with("'BravoOne' retaining its original child routes (no ref to 'ZachTwo')") {
                        XCTAssertEqual(bravoOne.routes.count, 1)
                        XCTAssertNotNil(bravoOne.route("BravoOneAlpha"))
                        XCTAssertNil(bravoOne.route("ZachTwo"))
                    }
                    with("back trail following the original plan") {
                        let foundPath = zachTwoClone.findPath(to: "Root")
                        let expectedPath: [QTRoutePathNode] = [.UP(bravoOne),
                                                               .UP(bravo),
                                                               .UP(root)]
                        XCTAssertEqual(foundPath, expectedPath)
                    }

                    when("resolving to parent") {
                        let expectComplete = expectation(description: "complete")
                        var backResult: QTRoutable? = nil

                        subject.driveParent(from: landingRoutable!, input: nil,
                                            animated: false,
                                            completion: {
                                                backResult = $0; expectComplete.fulfill(); }
                        )

                        wait(for: [expectComplete], timeout: 0.1)
                        then("it should arrive back at 'BravoOne'") {
                            XCTAssertEqual(backResult?.routeResolver?.route, bravoOne)
                        }
                    }
                }
            }
        }
    }
}
