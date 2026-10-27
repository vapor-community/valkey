import Valkey

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

var valkeyAddress: ValkeyServerAddress {
    .hostname(
        ProcessInfo.processInfo.environment["VALKEY_HOSTNAME"] ?? "localhost",
        port: ProcessInfo.processInfo.environment["VALKEY_PORT"].map { Int($0) ?? 6379 } ?? 6379
    )
}
