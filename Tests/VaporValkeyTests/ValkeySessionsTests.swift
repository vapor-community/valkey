import HTTPTypes
import Logging
import RoutingKit
import Testing
import Valkey
import Vapor
import VaporTesting
import VaporValkey

@Suite("ValkeySessions Tests")
struct ValkeySessionsTests {
    @Test("ValkeySessions")
    func valkeySessions() async throws {
        try await ValkeyConnection.withConnection(address: valkeyAddress, logger: .current) { connection in
            try await withApp(services: .init(sessionDriver: .valkey(connection))) { app in
                app.middleware.use(app.sessionsMiddleware)

                // Setup routes.
                app.get("set", ":value") { req -> HTTPResponse.Status in
                    req.session.data["name"] = req.parameters.get("value")
                    return .ok
                }
                app.get("get") { req -> String in
                    req.session.data["name"] ?? "n/a"
                }
                app.get("del") { req -> HTTPResponse.Status in
                    req.session.destroy()
                    return .ok
                }

                // Store session id.
                var sessionID: String?
                try await app.testing { client in
                    let res = try await client.get("/set/vapor")
                    sessionID = res.headers.setCookie?["vapor-session"]?.string
                    #expect(res.status == .ok)
                }
                #expect(try #require(sessionID).contains("vvs-") == false, "session token has the redis key prefix!")

                try await app.testing { client in
                    var headers = HTTPFields()
                    var cookies = HTTPCookies()
                    cookies["vapor-session"] = .init(string: sessionID!)
                    headers.cookie = cookies

                    let res = try await client.get("/get", headers: headers)
                    #expect(res.status == .ok)
                    #expect(res.body.string == "vapor")
                }
            }
        }
    }
}
