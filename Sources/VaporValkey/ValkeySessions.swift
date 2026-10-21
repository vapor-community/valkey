public import Valkey
public import Vapor

#if canImport(FoundationEssentials)
public import FoundationEssentials
#else
public import Foundation
#endif

extension Application.ServiceOptionType where Service == any SessionDriver {
    /// Builds a Valkey-based session driver for the application.
    ///
    /// - Parameters:
    ///   - client: The Valkey client or connection to use for session operations.
    ///   - decoder: The JSON decoder to use for decoding session data.
    ///   - encoder: The JSON encoder to use for encoding session data.
    ///   - keyPrefix: The prefix to use for session keys in Valkey.
    ///
    /// - Returns: A Valkey-based session driver.
    public static func valkey(
        _ client: any ValkeyClientProtocol,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder(),
        keyPrefix: String = "vvs-"
    ) -> Self {
        .provided(
            ValkeySessions(
                client: client,
                decoder: decoder,
                encoder: encoder,
                keyPrefix: keyPrefix
            )
        )
    }
}

/// A session driver for Vapor that uses Valkey as the backend.
public struct ValkeySessions: SessionDriver {
    private let client: any ValkeyClientProtocol
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    /// The prefix to use for session keys in Valkey.
    private let keyPrefix: String

    /// Creates a new instance of ``ValkeySessions`` with the given Valkey client, JSON decoder, and JSON encoder.
    ///
    /// - Parameters:
    ///   - client: The Valkey client or connection to use for session operations.
    ///   - decoder: The JSON decoder to use for decoding session data.
    ///   - encoder: The JSON encoder to use for encoding session data.
    ///   - keyPrefix: The prefix to use for session keys in Valkey.
    public init(
        client: any ValkeyClientProtocol,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder(),
        keyPrefix: String = "vvs-"
    ) {
        self.client = client
        self.decoder = decoder
        self.encoder = encoder
        self.keyPrefix = keyPrefix
    }

    public func createSession(_ data: SessionData, for request: Request) async throws -> SessionID {
        let sessionID = Self.generateID()
        let key = self.makeKey(sessionID: sessionID)

        try await self.client.set(.init(key), value: self.encoder.encode(data))
        return sessionID
    }

    public func readSession(_ sessionID: SessionID, for request: Request) async throws -> SessionData? {
        try await self.client.get(.init(self.makeKey(sessionID: sessionID))).map { result in
            try self.decoder.decode(SessionData.self, from: Data(result))
        }
    }

    public func updateSession(_ sessionID: SessionID, to data: SessionData, for request: Request) async throws -> SessionID {
        try await self.client.set(.init(self.makeKey(sessionID: sessionID)), value: self.encoder.encode(data))
        return sessionID
    }

    public func deleteSession(_ sessionID: SessionID, for request: Request) async throws {
        try await self.client.del(keys: [.init(self.makeKey(sessionID: sessionID))])
    }

    private static func generateID() -> SessionID {
        .init(string: [UInt8].random(count: 32).base64String())
    }

    private func makeKey(sessionID: SessionID) -> String {
        self.keyPrefix + sessionID.string
    }
}
