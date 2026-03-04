import Testing
import Valkey
import Vapor
import VaporTesting
import VaporValkey

@Suite
struct TestCache {
    @Test func valkeyCacheGet() async throws {
        try await withApp { app in
            let client = ValkeyClient(
                .hostname(valkeyHostname(), port: valkeyPort()),
                eventLoopGroup: app.eventLoopGroup,
                logger: app.logger
            )
            app.valkey = client
            app.caches.use(.valkey())

            let key = "\(Int.random())"
            let value = "\(Int.random())"
            // Manually populate Valkey as the JSON encoded representation, with quotes
            try await client.set(.init(key), value: "\"\(value)\"")
            try await #expect(app.cache.get(key, as: String.self) == value)

            try await client.del(keys: [.init(key)])
        }
    }

    /// Test that cache get reflects what was manually put in Valkey
    @Test func valkeyCacheSet() async throws {
        try await withApp { app in
            let client = ValkeyClient(
                .hostname(valkeyHostname(), port: valkeyPort()),
                eventLoopGroup: app.eventLoopGroup,
                logger: app.logger
            )
            app.valkey = client
            app.caches.use(.valkey())

            let key = "\(Int.random())"
            let value = "\(Int.random())"
            try await app.cache.set(key, to: value)
            // Manually check Valkey as the JSON encoded representation, with quotes
            var result = try #require(await client.get(.init(key)))
            #expect(String(result) == "\"\(value)\"")

            // Check that setting to nil deletes the cached key
            let nilValue: String? = nil
            try await app.cache.set(key, to: nilValue)
            try await #expect(client.get(.init(key)) == nil)
        }
    }

    /// Test that cache get reflects what was manually put in Valkey
    @Test func valkeyCacheDelete() async throws {
        try await withApp { app in
            let client = ValkeyClient(
                .hostname(valkeyHostname(), port: valkeyPort()),
                eventLoopGroup: app.eventLoopGroup,
                logger: app.logger
            )
            app.valkey = client
            app.caches.use(.valkey())

            let key = "\(Int.random())"
            let value = "\(Int.random())"
            try await app.cache.set(key, to: value)
            try await #expect(app.cache.get(key, as: String.self) == value)
            try await app.cache.delete(key)
            try await #expect(client.get(.init(key)) == nil)
        }
    }
}
