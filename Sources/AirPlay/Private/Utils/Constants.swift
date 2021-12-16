struct Constants {
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
