# URL Routing

<p align="center">
    <a href="http://perfect.org/get-involved.html" target="_blank">
        <img src="http://perfect.org/assets/github/perfect_github_2_0_0.jpg" alt="Get Involed with Perfect!" width="854" />
    </a>
</p>

<p align="center">
    <a href="https://github.com/PerfectlySoft/Perfect" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_1_Star.jpg" alt="Star Perfect On Github" />
    </a>  
    <a href="http://stackoverflow.com/questions/tagged/perfect" target="_blank">
        <img src="http://www.perfect.org/github/perfect_gh_button_2_SO.jpg" alt="Stack Overflow" />
    </a>  
    <a href="https://twitter.com/perfectlysoft" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_3_twit.jpg" alt="Follow Perfect on Twitter" />
    </a>  
    <a href="http://perfect.ly" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_4_slack.jpg" alt="Join the Perfect Slack" />
    </a>
</p>

<p align="center">
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat" alt="Swift 3.0">
    </a>
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat" alt="Platforms OS X | Linux">
    </a>
    <a href="http://perfect.org/licensing.html" target="_blank">
        <img src="https://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat" alt="License Apache">
    </a>
    <a href="http://twitter.com/PerfectlySoft" target="_blank">
        <img src="https://img.shields.io/badge/Twitter-@PerfectlySoft-blue.svg?style=flat" alt="PerfectlySoft Twitter">
    </a>
    <a href="http://perfect.ly" target="_blank">
        <img src="http://perfect.ly/badge.svg" alt="Slack Status">
    </a>
</p>

This example illustrates how to set up URL routing to direct requests to your custom handlers.

To use the example with Swift Package Manager, type ```swift build``` and then run ``` .build/debug/URLRouting```.

To use the example with Xcode, run the **URL Routing** target. This will launch the Perfect HTTP Server. 

Navigate in your web browser to [http://localhost:8181/](http://localhost:8181/). Experiment with the URL routes which are added.

## Issues

We are transitioning to using JIRA for all bugs and support related issues, therefore the GitHub issues has been disabled.

If you find a mistake, bug, or any other helpful suggestion you'd like to make on the docs please head over to [http://jira.perfect.org:8080/servicedesk/customer/portal/1](http://jira.perfect.org:8080/servicedesk/customer/portal/1) and raise it.

A comprehensive list of open issues can be found at [http://jira.perfect.org:8080/projects/ISS/issues](http://jira.perfect.org:8080/projects/ISS/issues)


## Enabling URL Routing

The following code is taken from the example project and shows how to create and add routes to a server.

```swift
var routes = Routes()

routes.add(method: .get, uris: ["/", "index.html"], handler: indexHandler)
routes.add(method: .get, uri: "/foo/*/baz", handler: echoHandler)
routes.add(method: .get, uri: "/foo/bar/baz", handler: echoHandler)
routes.add(method: .get, uri: "/user/{id}/baz", handler: echo2Handler)
routes.add(method: .get, uri: "/user/{id}", handler: echo2Handler)
routes.add(method: .post, uri: "/user/{id}/baz", handler: echo3Handler)

// Test this one via command line with curl:
// curl --data "{\"id\":123}" http://0.0.0.0:8181/raw --header "Content-Type:application/json"
routes.add(method: .post, uri: "/raw", handler: rawPOSTHandler)

// Trailing wildcard matches any path
routes.add(method: .get, uri: "**", handler: echo4Handler)

// Routes with a base URI

// Create routes for version 1 API
var api = Routes()
api.add(method: .get, uri: "/call1", handler: { _, response in
	response.setBody(string: "API CALL 1")
	response.completed()
})
api.add(method: .get, uri: "/call2", handler: { _, response in
	response.setBody(string: "API CALL 2")
	response.completed()
})

// API version 1
var api1Routes = Routes(baseUri: "/v1")
// API version 2
var api2Routes = Routes(baseUri: "/v2")

// Add the main API calls to version 1
api1Routes.add(routes: api)
// Add the main API calls to version 2
api2Routes.add(routes: api)
// Update the call2 API
api2Routes.add(method: .get, uri: "/call2", handler: { _, response in
	response.setBody(string: "API v2 CALL 2")
	response.completed()
})

// Add both versions to the main server routes
routes.add(routes: api1Routes)
routes.add(routes: api2Routes)

// Check the console to see the logical structure of what was installed.
print("\(routes.navigator.description)")

// Create server object.
let server = HTTPServer()

// Listen on port 8181.
server.serverPort = 8181

// Add our routes.
server.addRoutes(routes)

do {
    // Launch the HTTP server
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
```
## Handling Requests

The example `EchoHandler` consists of the following.

```swift
func echoHandler(request: HTTPRequest, _ response: HTTPResponse) {
	response.appendBody(string: "Echo handler: You accessed path \(request.path) with variables \(request.urlVariables)")
	response.completed()
}
```

## Using Apache
The following Apache conf snippet can be used to pipe requests for non-existent files through to Perfect when using the URL routing system.

```apacheconf
	RewriteEngine on
	RewriteCond %{REQUEST_FILENAME} !-f
	RewriteCond %{REQUEST_FILENAME} !-d
	RewriteRule (.*) - [L,NS,H=perfect-handler]
```


## Further Information
For more information on the Perfect project, please visit [perfect.org](http://perfect.org).
