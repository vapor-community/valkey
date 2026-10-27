public import Valkey
public import Vapor

#if canImport(FoundationEssentials)
public import FoundationEssentials
#else
public import Foundation
#endif

extension Application.ServiceOptionType where Service == any Cache {
    /// Builds a Valkey-based cache driver for the application.
    ///
    /// - Parameters:
    ///   - client: The Valkey client or connection to use for cache operations.
    ///   - decoder: The JSON decoder to use for decoding cached values.
    ///   - encoder: The JSON encoder to use for encoding cached values.
    ///
    /// - Returns: A Valkey-based cache driver.
    public static func valkey(
        _ client: any ValkeyClientProtocol,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) -> Self {
        .provided(
            ValkeyCache(
                client: client,
                decoder: decoder,
                encoder: encoder
            )
        )
    }
}

/// A cache driver for Vapor that uses Valkey as the backend.
public struct ValkeyCache: Cache {
    private let client: any ValkeyClientProtocol
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    /// Creates a new instance of ``ValkeyCache`` with the given Valkey client, JSON decoder, and JSON encoder.
    ///
    /// - Parameters:
    ///   - client: The Valkey client or connection to use for cache operations.
    ///   - decoder: The JSON decoder to use for decoding cached values.
    ///   - encoder: The JSON encoder to use for encoding cached values.
    public init(client: any ValkeyClientProtocol, decoder: JSONDecoder = JSONDecoder(), encoder: JSONEncoder = JSONEncoder()) {
        self.client = client
        self.decoder = decoder
        self.encoder = encoder
    }

    public func get<T>(_ key: String, as type: T.Type) async throws -> T? where T: Decodable & Sendable {
        try await self.client.get(.init(key)).map { result in
            try self.decoder.decode(T.self, from: Data(result))
        }
    }

    public func set<T>(
        _ key: String,
        to value: T?,
        expiresIn expirationTime: CacheExpirationTime?
    ) async throws where T: Encodable & Sendable {
        // Delete the key if value is `nil`
        guard let value else {
            try await client.del(keys: [.init(key)])
            return
        }

        let encoded = try encoder.encode(value)
        if let expirationTime {
            try await client.setex(.init(key), seconds: expirationTime.seconds, value: encoded)
        } else {
            try await client.set(.init(key), value: encoded)
        }
    }
}
