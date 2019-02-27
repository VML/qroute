
class QTRouteDriver: QTRouteDriving {
    func driveParent(from source: QTRoutable, input: QTRouteResolvingInput?, completion: QTRouteDrivingCompletion?) {
        guard let parentId = source.route?.parent?.id else { completion?(nil); return }
        driveTo(parentId, from: source, input: input ?? [:], completion: completion)
    }

    func driveSub(_ targetId: QTRouteId, from source: QTRoutable, input: QTRouteResolvingInput?, completion: QTRouteDrivingCompletion?) {
        guard let clonePath = QTRouteDriver.buildClonePath(to: targetId, from: source) else { completion?(nil); return }
        QTRouteDriver.routeNext(path: clonePath, routable: source, input: input ?? [:], finalCompletion: completion)
    }

    func driveTo(_ targetId: QTRouteId, from source: QTRoutable, input: QTRouteResolvingInput?, completion: QTRouteDrivingCompletion?) {
        guard let path = source.route?.findPath(to: targetId) else { completion?(nil); return }
        QTRouteDriver.routeNext(path: path, routable: source, input: input ?? [:], finalCompletion: completion)
    }
}

fileprivate extension QTRouteDriver {
    static func routeNext(path: QTRoutePath, routable: QTRoutable?, input: QTRouteResolvingInput, finalCompletion: QTRouteDrivingCompletion?) {
        guard let nextRoutable = routable, (path.count > 0) else { finalCompletion?(routable); return }
        let stepCompletion = self.getStepCompletion(path, input: input, finalCompletion)
        QTRouteDriver.driveRoutable(nextRoutable, path[0], input: input, stepCompletion)
    }

    static func driveRoutable(_ routable: QTRoutable, _ pathNode: QTRoutePathNode, input: QTRouteResolvingInput, _ stepCompletion: @escaping QTRoutableCompletion) {
        guard let resolver = routable.routeResolver else { return }
        switch (pathNode) {
        case let .DOWN(nextRoute): resolver.resolveRouteToChild(nextRoute, from: routable, input: input, completion: stepCompletion)
        case .SELF: resolver.resolveRouteToSelf(from: routable, input: input, completion: stepCompletion)
        case .UP:   resolver.resolveRouteToParent(from: routable, input: input, completion: stepCompletion)
        }
    }

    static func getStepCompletion(_ path: QTRoutePath, input: QTRouteResolvingInput, _ finalCompletion: QTRouteDrivingCompletion?) -> QTRoutableCompletion {
        return { QTRouteDriver.routeNext(path: QTRoutePath( path.dropFirst() ),
                                         routable: $0,
                                         input: input,
                                         finalCompletion: finalCompletion) }
    }

    static func buildClonePath(to targetId: QTRouteId, from source: QTRoutable) -> QTRoutePath? {
        guard let sourceRoute = source.route else { return nil }
        guard let target = sourceRoute.findPath(to: targetId).last?.route else { return nil }
        let clone = QTRoute(deepClone: target)
        clone.parent = sourceRoute
        return [.DOWN(clone)]
    }
}
