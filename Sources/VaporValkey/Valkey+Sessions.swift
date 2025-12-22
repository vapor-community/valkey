import Valkey
import Vapor

public extension Application.Sessions.Provider {
    /// Use the Application's Valkey client for Vapor sessions. The `Application.valkey` property must be set to use this.
    ///
    /// Here's a quick example:
    /// ```swift
    /// let app = Application.make(.detect)
    /// app.valkey = ValkeyClient(
    ///     .hostname("valkey", port: 6379),
    ///     eventLoopGroup: app.eventLoopGroup,
    ///     logger: app.logger
    /// )
    /// app.sessions.use(.valkey())
    /// app.middleware.use(app.sessions.middleware)
    /// app.get("set", ":name") { req in
    ///     req.session.data["name"] = req.parameters.get("name")
    ///     return .ok
    /// }
    /// app.get("hello") { req in
    ///     req.session.data["name"] ?? "world"
    /// }
    /// ```
    static func valkey(
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) -> Self {
        return .init { app in
            app.sessions.use { _ in
                ValkeySessionsDriver(
                    encoder: encoder,
                    decoder: decoder
                )
            }
        }
    }
}

struct ValkeySessionsDriver: SessionDriver {
    let encoder: JSONEncoder
    let decoder: JSONDecoder

    func createSession(_ data: SessionData, for request: Request) -> EventLoopFuture<SessionID> {
        let sessionID = makeSessionID()
        let key = makeKey(sessionID: sessionID)

        return request.eventLoop.makeFutureWithTask {
            try await request.valkey.set(.init(key), value: encoder.encode(data))
            return sessionID
        }
    }

    func readSession(_ sessionID: SessionID, for request: Request) -> EventLoopFuture<SessionData?> {
        let key = makeKey(sessionID: sessionID)

        return request.eventLoop.makeFutureWithTask {
            try await request.valkey.get(.init(key)).map { result in
                try decoder.decode(SessionData.self, from: ByteBuffer(result))
            }
        }
    }

    func updateSession(_ sessionID: SessionID, to data: SessionData, for request: Request) -> EventLoopFuture<SessionID> {
        let key = makeKey(sessionID: sessionID)

        return request.eventLoop.makeFutureWithTask {
            try await request.valkey.set(.init(key), value: encoder.encode(data))
            return sessionID
        }
    }

    func deleteSession(_ sessionID: SessionID, for request: Request) -> EventLoopFuture<Void> {
        let key = makeKey(sessionID: sessionID)

        return request.eventLoop.makeFutureWithTask {
            try await request.valkey.del(keys: [.init(key)])
        }
    }

    private func makeSessionID() -> SessionID {
        var bytes = Data()
        for _ in 0 ..< 32 {
            bytes.append(.random(in: .min ..< .max))
        }
        return SessionID(string: bytes.base64EncodedString())
    }

    private func makeKey(sessionID: SessionID) -> String {
        return "vvs-\(sessionID.string)"
    }
}
