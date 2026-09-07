import Testing

@testable import TBAAuth

struct NonceTests {

    @Test func charset_isExactly64Characters() {
        // 64 divides 256 evenly, so the byte -> character mapping is uniform.
        // "W" is absent by design; adding it would make 65 and bias the result.
        #expect(Nonce.charset.count == 64)
        #expect(Set(Nonce.charset).count == 64)
        #expect(256 % Nonce.charset.count == 0)
    }

    @Test func length() throws {
        #expect(try Nonce().raw.count == 32)
    }

    @Test func everyByteMapsIntoCharset() throws {
        let charset = Set(Nonce.charset)
        let raw = try Nonce(randomBytes: { _ in Array(0...255) }).raw
        #expect(raw.count == 256)
        #expect(raw.allSatisfy { charset.contains($0) })
    }

    @Test func noncesDiffer() throws {
        #expect(try Nonce().raw != Nonce().raw)
    }

    @Test func injectedBytesMapDeterministically() throws {
        let nonce = try Nonce(randomBytes: { _ in [0, 1, 64, 65] })
        // charset[0] = "0", charset[1] = "1", charset[64 % 64] = "0", charset[65 % 64] = "1"
        #expect(nonce.raw == "0101")
    }

    @Test func sha256_matchesKnownVector() throws {
        let nonce = try Nonce(randomBytes: { _ in [35, 36, 37] })
        #expect(nonce.raw == "abc")
        #expect(nonce.sha256 == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
    }

    @Test func sha256_is64LowercaseHexCharacters() throws {
        let sha = try Nonce().sha256
        #expect(sha.count == 64)
        #expect(sha.allSatisfy { $0.isHexDigit && !$0.isUppercase })
    }

    @Test func throwsWhenRandomBytesFail() {
        #expect(throws: AuthError.nonceGenerationFailed(-1)) {
            _ = try Nonce(randomBytes: { _ in throw AuthError.nonceGenerationFailed(-1) })
        }
    }
}
