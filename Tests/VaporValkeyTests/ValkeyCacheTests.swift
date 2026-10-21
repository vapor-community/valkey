import Logging
import Testing
import Valkey
import Vapor
import VaporTesting
import VaporValkey

@Suite("ValkeyCache Tests")
struct ValkeyCacheTests {
    @Test("ValkeyCache GET")
    func valkeyCacheGet() async throws {
        try await withValkeyCache { app, client in
            let key = "\(Int.random())"
            let value = "\(Int.random())"
            // Manually populate Valkey as the JSON encoded representation, with quotes
            try await client.set(.init(key), value: "\"\(value)\"")
            try await #expect(app.cache.get(key, as: String.self) == value)

            try await client.del(keys: [.init(key)])
        }
    }

    @Test("ValkeyCache SET")
    func valkeyCacheSet() async throws {
        try await withValkeyCache { app, client in
            let key = "\(Int.random())"
            let value = "\(Int.random())"
            try await app.cache.set(key, to: value, expiresIn: nil)
            // Manually check Valkey as the JSON encoded representation, with quotes
            let result = try #require(await client.get(.init(key)))
            #expect(String(result) == "\"\(value)\"")

            // Check that setting to `nil` deletes the cached key
            let nilValue: String? = nil
            try await app.cache.set(key, to: nilValue, expiresIn: nil)
            try await #expect(client.get(.init(key)) == nil)
        }
    }

    @Test("ValkeyCache DELETE")
    func valkeyCacheDelete() async throws {
        try await withValkeyCache { app, client in
            let key = "\(Int.random())"
            let value = "\(Int.random())"
            try await app.cache.set(key, to: value, expiresIn: nil)
            try await #expect(app.cache.get(key, as: String.self) == value)
            try await app.cache.delete(key)
            try await #expect(client.get(.init(key)) == nil)
        }
    }

    private func withValkeyCache(_ body: (Application, any ValkeyClientProtocol) async throws -> Void) async throws {
        try await ValkeyConnection.withConnection(address: valkeyAddress, logger: .current) { connection in
            try await withApp(services: .init(cache: .valkey(connection))) { app in
                try await body(app, connection)
            }
        }
    }
}
