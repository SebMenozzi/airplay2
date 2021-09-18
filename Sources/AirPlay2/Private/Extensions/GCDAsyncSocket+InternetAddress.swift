import Foundation
import CocoaAsyncSocket

extension GCDAsyncSocket {
    var internetAddress: Data! {
        let address = self.localAddress!
        if isIPv6 {
            return address.subdata(in: 8..<24)
        }
        else {
            // Same as above but with `sockaddr_in`
            return address.subdata(in: 4..<8)
        }
    }
}
