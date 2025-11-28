import ServiceLifecycle
import Valkey
import Vapor

extension Application {
    /// Binds a Valkey Client to the Application for later use via `Application.valkey` or `Request.valkey`.
    ///
    /// When this is called, the Application will take ownership of the Valkey client's lifecycle. Specifically, this assignment operation will automatically run the client, and it will be automatically cancelled when the Application is shut down.
    ///
    /// Here's a basic example:
    ///
    /// ```swift
    /// let app = Application.make(.detect)
    /// app.valkey = ValkeyClient(
    ///     .hostname("valkey", port: 6379),
    ///     eventLoopGroup: app.eventLoopGroup,
    ///     logger: app.logger
    /// )
    /// try await app.valkey.set("hello", value: "world")
    /// app.get("hello") { req in
    ///    try await req.valkey.get("hello")?.string ?? "not found"
    /// }
    /// ```
    public var valkey: any ValkeyClientProtocol & ServiceLifecycle.Service {
        get {
            guard let valkeyClientStorage = storage[ValkeyClientKey.self] else {
                fatalError("No valkey client has been configured. Check configuration for `application.valkey = ...`")
            }
            return valkeyClientStorage.client
        }
        set {
            let valkeyClientStorage = ValkeyClientStorage(
                client: newValue,
                task: Task {
                    try await newValue.run()
                }
            )
            storage.set(
                ValkeyClientKey.self,
                to: valkeyClientStorage,
                onShutdown: { valkeyClientStorage in
                    valkeyClientStorage.task.cancel()
                }
            )
        }
    }

    struct ValkeyClientKey: StorageKey {
        typealias Value = ValkeyClientStorage
    }
}

actor ValkeyClientStorage {
    let client: any ValkeyClientProtocol & ServiceLifecycle.Service
    let task: Task<Void, any Error>

    init(
        client: any ValkeyClientProtocol & ServiceLifecycle.Service,
        task: Task<Void, any Error>
    ) {
        self.client = client
        self.task = task
    }
}

public extension Request {
    var valkey: any ValkeyClientProtocol {
        application.valkey
    }
}
