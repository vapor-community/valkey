import Testing
import Valkey
import Vapor
import VaporTesting
import VaporValkey

struct TestSessions {
    @Test func valkeySession() async throws {
        try await withApp { app in
            let client = ValkeyClient(
                .hostname(valkeyHostname(), port: valkeyPort()),
                eventLoopGroup: app.eventLoopGroup,
                logger: app.logger
            )
            app.valkey = client
            app.sessions.use(.valkey())
            app.middleware.use(app.sessions.middleware)

            // Setup routes.
            app.get("set", ":value") { req -> HTTPStatus in
                req.session.data["name"] = req.parameters.get("value")
                return .ok
            }
            app.get("get") { req -> String in
                req.session.data["name"] ?? "n/a"
            }
            app.get("del") { req -> HTTPStatus in
                req.session.destroy()
                return .ok
            }

            // Store session id.
            var sessionID: String?
            try await app.testing().test(.GET, "/set/vapor") { res in
                sessionID = res.headers.setCookie?["vapor-session"]?.string
                #expect(res.status == .ok)
            }
            #expect(try #require(sessionID).contains("vvs-") == false, "session token has the redis key prefix!")

            try await app.testing().test(.GET, "/get", beforeRequest: { req in
                var cookies = HTTPCookies()
                cookies["vapor-session"] = .init(string: sessionID!)
                req.headers.cookie = cookies
            }) { res in
                #expect(res.status == .ok)
                #expect(res.body.string == "vapor")
            }
        }
    }
}
