<div align="center">
<h1>Vapor Valkey</h1>
<br>

[![Documentation](https://design.vapor.codes/images/readthedocs.svg)](https://docs.vapor.codes/)
[![Team Chat](https://design.vapor.codes/images/discordchat.svg)](https://discord.gg/vapor)
[![MIT License](https://design.vapor.codes/images/mitlicense.svg)](LICENSE)
[![Continuous Integration](https://img.shields.io/github/actions/workflow/status/vapor/valkey/test.yml?event=push&style=plastic&logo=github&label=tests&logoColor=ccc)](https://github.com/vapor/valkey/actions/workflows/test.yml)
[![Code Coverage](https://img.shields.io/codecov/c/gh/vapor/valkey?style=plastic&logo=codecov&label=codecov)](https://codecov.io/gh/vapor/valkey)
[![Swift 6.4+](https://design.vapor.codes/images/swift64up.svg)](https://swift.org)

</div>

<br>

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
