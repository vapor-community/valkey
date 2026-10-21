# Vapor Valkey

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fvapor-community%2Fvalkey%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/vapor-community/valkey)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fvapor-community%2Fvalkey%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/vapor-community/valkey)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/vapor-community/valkey/test.yaml)
![Codecov](https://img.shields.io/codecov/c/github/vapor-community/valkey)

This library provides Valkey/Redis drivers for [Vapor](https://github.com/vapor/vapor) caching and sessions, based on [valkey-swift](https://github.com/valkey-io/valkey-swift).

## Overview

Create a Valkey client or connection (any type conforming to [`ValkeyClientProtocol`](https://swiftpackageindex.com/valkey-io/valkey-swift/documentation/valkey/valkeyclientprotocol)) and use it to configure the application's cache and session driver:

```swift
import Logging
import Valkey
import Vapor
import VaporValkey

let valkeyClient = ValkeyClient(.hostname("localhost"), logger: .current)

let app = try Application(
    services: .init(
        cache: .valkey(valkeyClient),
        sessionDriver: .valkey(valkeyClient)
    )
)

// If you're using a connection pool backed client, remember to run it

// This lets Vapor handle the client, starting it when the Application starts and stopping it when the application shuts down
app.addService(valkeyClient)

// Alternatively, you can run it yourself
// async let _ = valkeyClient.run()
```

For more information about Vapor's session system, see [Sessions](https://docs.vapor.codes/advanced/sessions/).

## Documentation

User guides and reference documentation for Vapor Valkey can be found on the [Swift Package Index](https://swiftpackageindex.com/vapor-community/valkey/documentation).
