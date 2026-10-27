# ``VaporValkey``

This library provides Valkey/Redis drivers for Vapor caching and sessions, based on valkey-swift.

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

## Topics

### Sessions

- ``Vapor/Application/ServiceOptionType/valkey(_:decoder:encoder:keyPrefix:)``
- ``ValkeySessions``

### Cache

- ``Vapor/Application/ServiceOptionType/valkey(_:decoder:encoder:)``
- ``ValkeyCache``
