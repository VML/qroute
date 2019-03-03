# ![kyoot-root](icon.png) QTRoute

**QTRoute** /'kyoot•root/ - *n* - Declarative general purpose application routing and UI navigation model.

## Reference Documentation

The essential pieces required in order to implement QTRoute in an application.

<br />

### QTRoute

The basic element of any route plan. Each "route" is a data structure that represents a contextual view
or "scene" presented by the application. It can include child routes and run-time dependencies.

<br />

### *QTRoutable* CustomRoutable

This protocol is to be implemented by the view controller (or presenter, etc) for a given route. While one
is not provided for you, the included ExampleApp contains several view controller examples.

 - **routeResolver: QTRouteResolving** *(Required)*
 - **routeInput: QTRouteInput** *(Required)*

<br />

### *QTRouteDriving* QTRouteDriver

Drives path navigation and resolver events. The `QTRouteDriver` class (and suitable testing "mock") is provided for you.

<br />

**driveParent()**

```
driveParent(from: QTRoutable,
            input: QTRoutableInput,
            animated: Bool,
            completion: QTRoutableCompletion?)
```

Commands the `QTRouteDriver` to navigate to the *immediate logical parent* from `QTRoutable`.

<br />

**driveSub()**

```
driveSub(QTRouteId,
         from: QTRoutable,
         input: QTRoutableInput,
         animated: Bool,
         completion: QTRoutableCompletion?)
```
Commands the `QTRouteDriver` to navigate to any route in the hierarchy, regardless of location, *as if it were*
an *immediate logical descendant* from the current route. (Essentially a subroutine version of `driveTo`.) Pass
any dependency requirements via the `input` parameter.

<br />

**driveTo()**

```
driveTo(QTRouteId,
        from: QTRoutable,
        input: QTRoutableInput,
        animated: Bool,
        completion: QTRoutableCompletion?)
```
Commands the `QTRouteDriver` to navigate to any other route in the hierarchy, regardless of location.
Calling this method will cause the `driver` to follow the nearest path to the destination route, raising the
navigation events along the way to your custom `QTRouteResolving` `resolvers`. Pass any dependency
requirements via the `input` parameter.

<br />

### *QTRouteResolving* QTRouteResolver

The `resolver` is where you implement the actual navigation within your application by responding
to navigation events triggered by the `QTRouteDriver`. The project includes a general purpose
`QTRouteResolver` which supports composition, or you can build one from scratch. It is normal to
have several of these in your project. The [Example App](https://github.com/quickthyme/qtroute-example-ios)
contains several resolver examples that you can use as a template.

 - **route: QTRoute** *(Required)*

<br />

**resolveRouteToChild()** *(Required)*

```
resolveRouteToChild(QTRoute,
                    from: QTRoutable,
                    input: QTRoutableInput,
                    animated: Bool,
                    completion: QTRoutableCompletion)
```
The resolver is expected to perform the required steps to navigate to one of its *immediate logical
descendants* matching the given `QTRoute`. If the navigation is successful, the resolver must invoke
the `QTRoutableCompletion` block before exiting. Not invoking the completion handler will abort and
cancel any remaining routing steps.

<br />

**resolveRouteToParent()** *(Required)*

```
resolveRouteToParent(from: QTRoutable,
                     input: QTRoutableInput,
                     animated: Bool,
                     completion: QTRoutableCompletion)
```
The resolver is expected to perform the required steps to navigate to its *immediate logical parent*. If the
navigation is successful, the resolver must invoke the `QTRoutableCompletion` block before exiting. Not
invoking the completion handler will abort and cancel any remaining routing steps.

<br />

**resolveRouteToSelf()** *(Optional)*

```
resolveRouteToSelf(from: QTRoutable,
                   input: QTRoutableInput,
                   animated: Bool,
                   completion: QTRoutableCompletion)
```
The default implementation ignores the result, but does merge input dependencies and calls the completion
handler passing the current routable, which should be sufficient most of the time. This event will be invoked
in response to a `driveTo` event, whenever the `targetId` matches the `source`. †

You might choose to opt-in to this behavior in situations where you want/need to directly invoke
a "refresh" or "re-route" on the current routable, or in cases where the target Id is uncertain.

If you choose to implement this, then the resolver is expected to perform the required steps to navigate
to *itself*, in whatever which way that may be interpreted. If the navigation is successful, the resolver must
invoke the `QTRoutableCompletion` block before exiting.

**†** While performing a `driveSub()` against *self*, the driver will invoke `resolveRouteToChild()` instead.

<br />

**mergeInputDependencies()** *(Optional)*

```
mergeInputDependencies(target: QTRoutable,
                       input: QTRoutableInput)
```
The default implementation merges only those values defined as one of the target route's dependencies.
However, this is not called by default, so your custom `resolver` must invoke it when necessary.

<br />

### QTRoutableInput

```
[String:Any]
```
If a given route has declared any dependencies, you can use the contents of the input parameter to satisfy them.

<br />

### QTRoutableCompletion

```
(QTRoutable?)->()
```
Once any given navigation step completes, call the completion handler, passing the destination *routable*.