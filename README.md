# Vapor Valkey

This project provides [valkey-swift](https://github.com/valkey-io/valkey-swift) as a driver for [Vapor](https://github.com/vapor/vapor) caching and sessions.

## Usage

To use this package, add it as a dependency to your Package.swift. Then create a Valkey client and assign it to `Application.valkey`:

```swift
import Valkey
import Vapor
import VaporValkey

let app = Application.make(.detect)

// Attach Valkey service to enable `Application.valkey` & `Request.valkey`
app.valkey = ValkeyClient(
    .hostname("localhost", port: 6379),
    eventLoopGroup: app.eventLoopGroup,
    logger: app.logger
)

// Use the Valkey client for Vapor caching
app.caches.use(.valkey())

// Use the Valkey client for Vapor sessions
app.sessions.use(.valkey())
```

When assigning the Application's `valkey` property (the `app.valkey = valkeyClient` line above), the Application will take ownership of the Valkey client's lifecycle. Specifically, this assignment operation will automatically run the client, and it will be automatically cancelled when the Application is shut down.

The Application's `valkey` property can accept either `ValkeyClient` or `ValkeyClusterClient`. For more information about these clients and their configuration, see [valkey-swift](https://github.com/valkey-io/valkey-swift).

For more information about Vapor's session system, see [Sessions](https://docs.vapor.codes/advanced/sessions/)
