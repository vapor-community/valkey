import Testing
import Valkey
import Vapor
import VaporTesting
import VaporValkey

@Suite
struct TestService {
    @Test func valkeyService() async throws {
        try await withApp { app in
            let client = ValkeyClient(
                .hostname(valkeyHostname(), port: valkeyPort()),
                eventLoopGroup: app.eventLoopGroup,
                logger: app.logger
            )
            app.valkey = client

            let value = "\(Int.random())"
            try await app.valkey.set("test", value: value)
            try await #expect(app.valkey.get("test").map { String($0) } == value)
        }
    }
}
