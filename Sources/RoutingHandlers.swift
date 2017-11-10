//
//  PerfectHandlers.swift
//  URL Routing
//
//  Created by Kyle Jessup on 2015-12-15.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectHTTP

func makeURLRoutes() -> Routes {
	
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
	api1Routes.add(api)
	// Add the main API calls to version 2
	api2Routes.add(api)
	// Update the call2 API
	api2Routes.add(method: .get, uri: "/call2", handler: { _, response in
		response.setBody(string: "API v2 CALL 2")
		response.completed()
	})

	// Add both versions to the main server routes
	routes.add(api1Routes)
	routes.add(api2Routes)

	// Check the console to see the logical structure of what was installed.
	print("\(routes.navigator.description)")
	return routes
}

func indexHandler(request: HTTPRequest, _ response: HTTPResponse) {
	response.appendBody(string: "Index handler: You accessed path \(request.path)")
	response.completed()
}

func echoHandler(request: HTTPRequest, _ response: HTTPResponse) {
	response.appendBody(string: "Echo handler: You accessed path \(request.path) with variables \(request.urlVariables)")
	response.completed()
}

func echo2Handler(request: HTTPRequest, _ response: HTTPResponse) {
	response.appendBody(string: "<html><body>Echo 2 handler: You GET accessed path \(request.path) with variables \(request.urlVariables)<br>")
	response.appendBody(string: "<form method=\"POST\" action=\"/user/\(request.urlVariables["id"] ?? "error")/baz\"><button type=\"submit\">POST</button></form></body></html>")
	response.completed()
}

func echo3Handler(request: HTTPRequest, _ response: HTTPResponse) {
	response.appendBody(string: "<html><body>Echo 3 handler: You POSTED to path \(request.path) with variables \(request.urlVariables)</body></html>")
	response.completed()
}

func echo4Handler(request: HTTPRequest, _ response: HTTPResponse) {
    response.appendBody(string: "<html><body>Echo 4 (trailing wildcard) handler: You accessed path \(request.path)</body></html>")
    response.completed()
}

func rawPOSTHandler(request: HTTPRequest, _ response: HTTPResponse) {
	response.appendBody(string: "<html><body>Raw POST handler: You POSTED to path \(request.path) with content-type \(request.header(.contentType)) and POST body \(request.postBodyString)</body></html>")
	response.completed()
}

