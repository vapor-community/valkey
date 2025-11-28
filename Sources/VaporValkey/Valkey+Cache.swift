import Valkey
import Vapor

public extension Application.Caches.Provider {
    /// Use the Application's Valkey client for Vapor caching. The `Application.valkey` property must be set to use this.
    ///
    /// Here's a quick example:
    /// ```swift
    /// let app = Application.make(.detect)
    /// app.valkey = ValkeyClient(
    ///     .hostname("valkey", port: 6379),
    ///     eventLoopGroup: app.eventLoopGroup,
    ///     logger: app.logger
    /// )
    /// app.cache.use(.valkey())
    /// try await app.cache.set("hello", to: "world")
    /// app.get("hello") { req in
    ///     try await req.cache.get("hello", as: String.self) ?? "not found"
    /// }
    /// ```
    static func valkey(
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) -> Self {
        .init { $0.caches.use { $0.caches.valkey(encoder: encoder, decoder: decoder) } }
    }
}

extension Application.Caches {
    func valkey(encoder: JSONEncoder, decoder: JSONDecoder) -> any Cache {
        ValkeyCache(
            client: application.valkey,
            eventLoopGroup: application.eventLoopGroup,
            decoder: decoder,
            encoder: encoder
        )
    }
}

struct ValkeyCache {
    let client: any ValkeyClientProtocol
    let eventLoopGroup: any EventLoopGroup
    let decoder: JSONDecoder
    let encoder: JSONEncoder
}

extension ValkeyCache: Cache {
    // Avoids `Capture of non-Sendable type 'T.Type' in an isolated
    // closureSourceKit[sendable](https://docs.swift.org/compiler/documentation/diagnostics/sendable-metatypes)`
    // warning, but `SendableMetatype` isn't available until Swift 6.2. We can remove when 6.1 support is dropped.
    #if swift(>=6.2)
        /// Gets a decodable value from the cache. Returns `nil` if not found.
        func get<T: Decodable & SendableMetatype>(_ key: String, as _: T.Type) -> EventLoopFuture<T?> {
            return eventLoopGroup.makeFutureWithTask {
                try await client.get(.init(key)).map { result in
                    try decoder.decode(T.self, from: result)
                }
            }
        }
    #else
        /// Gets a decodable value from the cache. Returns `nil` if not found.
        func get<T: Decodable>(_ key: String, as _: T.Type) -> EventLoopFuture<T?> {
            return eventLoopGroup.makeFutureWithTask {
                try await client.get(.init(key)).map { result in
                    try decoder.decode(T.self, from: result)
                }
            }
        }
    #endif

    /// Sets an encodable value into the cache. Existing values are replaced. If `nil`, removes value.
    func set<T: Encodable>(_ key: String, to value: T?) -> EventLoopFuture<Void> {
        set(key, to: value, expiresIn: nil)
    }

    /// Sets an encodable value into the cache with an expiry time. Existing values are replaced. If `nil`, removes value.
    func set<T: Encodable>(_ key: String, to value: T?, expiresIn expirationTime: CacheExpirationTime?) -> EventLoopFuture<Void> {
        // Delete the key if value is nil
        guard let value = value else {
            return eventLoopGroup.makeFutureWithTask {
                try await client.del(keys: [.init(key)])
            }
        }

        // Encode outside task because value isn't sendable
        let encoded: Data
        do {
            encoded = try encoder.encode(value)
        } catch {
            return eventLoopGroup.future(error: error)
        }
        return eventLoopGroup.makeFutureWithTask {
            if let expirationTime = expirationTime {
                return try await client.setex(.init(key), seconds: expirationTime.seconds, value: encoded)
            } else {
                try await client.set(.init(key), value: encoded)
                return
            }
        }
    }

    /// Creates a request-specific cache instance.
    func `for`(_ request: Request) -> Self {
        return ValkeyCache(
            client: client,
            eventLoopGroup: request.eventLoop,
            decoder: decoder,
            encoder: encoder
        )
    }
}
