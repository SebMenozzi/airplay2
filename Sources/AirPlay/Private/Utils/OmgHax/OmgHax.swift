import Foundation

final class OmgHax: NSObject {

    // MARK: - Public

    func decryptAesKey(message3: Data, cipherText: Data, keyOut: Data) {
        let chunk1 = cipherText.range(start: 16)
        let chunk2 =  cipherText.range(start: 56)
        let blockIn = [UInt8](repeating: 0, count: 16)
        let sapKey = [UInt8](repeating: 0, count: 16)
        let keySchedule = [[Int]](repeating: [Int](repeating: 0, count: 4), count: 11)
        /*
        generate_session_key(default_sap, message3, sapKey);
        generate_key_schedule(sapKey, key_schedule);
        z_xor(chunk2, blockIn, 1);
        cycle(blockIn, key_schedule);
        for (int i = 0; i < 16; i++) {
            keyOut[i] = (byte) (blockIn[i] ^ chunk1[i]);
        }
        x_xor(keyOut, keyOut, 1);
        z_xor(keyOut, keyOut, 1);
        */
    }

    // MARK: - Private

    func generateSessionKey(oldSap: [UInt8], messageIn: [UInt8], sessionKey: [UInt8]) {
        let decryptedMessage = [UInt8](repeating: 0, count: 128)
        let newSap = [UInt8](repeating: 0, count: 320)
        let md5 = [UInt8](repeating: 0, count: 16)

        Array.copy(src: Self.staticSource1, srcPos: 0, dest: newSap, destPos: 0, length: 0x11)
        Array.copy(src: decryptedMessage, srcPos: 0, dest: newSap, destPos: 0x11, length: 0x80)
        Array.copy(src: oldSap, srcPos: 0x80, dest: newSap, destPos: 0x091, length: 0x80)
        Array.copy(src: Self.staticSource2, srcPos: 0, dest: newSap, destPos: 0x111, length: 0x2f)
        Array.copy(src: Self.initialSessionKey, srcPos: 0, dest: sessionKey, destPos: 0, length: 16)

        for round in 0...4 {
            let base = newSap.data.range(start: round * 64)
        }


    }
}
