struct Constants {

    // MARK: - AirPlay Constants

    static let airTunesPort = 5000
    static let airPlayPort = 7000
    static let hardwareAddress: [UInt8] = [184, 199, 93, 59, 114, 43]
    static let publicKey: String = "29fbb183a58b466e05b9ab667b3c429d18a6b785637333d3f0f3a34baa89f45e"
    static let airPlayPairingIdentifier: String = "aa072a95-0318-4ec3-b042-4992495877d3"
    static let deviceModel: String = "AppleTV5,3"

    // MARK: - Content Types

    static let rstpContentType = "application/rtsp"
    static let bplistContentType = "application/x-apple-binary-plist"

    // MARK: - RTSP Constants

    static let requestMaxMethodLength = 64
    static let requestMaxURLLength = 2048
    static let requestMaxProtocolLength = 64
    static let rtspProtocol = "RTSP/1.0"

    static let headerMaxFieldsCount = 255
    static let headerMaxKeyLength = 512
    static let headerMaxValueLength = 2048

    static let rtspMaxContentLength = 128 * 1024

    static let contentTypeBinaryPlist = "application/x-apple-binary-plist"

    static let FEATURES: UInt64 = Features(rawValue: 0) // all zeros
        .union(Features.Ft48TransientPairing)
        .union(Features.Ft47PeerMgmt)
        .union(Features.Ft47PeerMgmt)
        .union(Features.Ft46HKPairing)
        .union(Features.Ft41_PTPClock)
        .union(Features.Ft40BufferedAudio)
        .union(Features.Ft30UnifiedAdvertInf)
        .union(Features.Ft22AudioUnencrypted)
        .union(Features.Ft20RcvAudAAC_LC)
        .union(Features.Ft19RcvAudALAC)
        .union(Features.Ft18RcvAudPCM)
        .union(Features.Ft17AudioMetaTxtDAAP)
        .union(Features.Ft16AudioMetaProgres)
        .union(Features.Ft14MFiSoftware)
        .union(Features.Ft09AirPlayAudio)
        .union(Features.Ft07ScreenMirroring)
        .rawValue

}
