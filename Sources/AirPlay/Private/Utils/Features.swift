import Foundation

struct Features: OptionSet {
    let rawValue: UInt64

    //  https://emanuelecozzi.net/docs/airplay2/features/
    // https://openairplay.github.io/airplay-spec/features.html
    static let Ft00Video = Features(rawValue: 0x0000000000000001) // 1<<0
    static let Ft01Photo = Features(rawValue: 0x0000000000000002) // 1<<1
    static let Ft02VideoFairPlay = Features(rawValue: 0x0000000000000004) // 1<<2
    static let Ft03VideoVolumeCtrl = Features(rawValue: 0x0000000000000008) // 1<<3
    static let Ft04VideoHTTPLiveStr = Features(rawValue: 0x0000000000000010) // 1<<4
    static let Ft05Slideshow = Features(rawValue: 0x0000000000000020) // 1<<5

    static let Ft07ScreenMirroring = Features(rawValue: 0x0000000000000080) // 1<<7
    static let Ft08ScreenRotate = Features(rawValue: 0x0000000000000100) // 1<<8

    // Ft09 is necessary for iPhones/Music: audio
    static let Ft09AirPlayAudio = Features(rawValue: 0x0000000000000200) // 1<<9
    static let Ft10Unknown = Features(rawValue: 0x0000000000000400) // 1<<10
    static let Ft11AudRedundant = Features(rawValue: 0x0000000000000800) // 1<<11

    //  Feat12: iTunes4Win ends ANNOUNCE with rsaaeskey, does not attempt FPLY auth.
    // also coerces frequent OPTIONS packets (keepalive) from iPhones.
    static let Ft12FPSAPv2p5_AES_GCM = Features(rawValue: 0x0000000000001000) // 1<<12

    // 13-14 seem to be MFi stuff. 13: prevents assoc.
    static let Ft13MFiHardware = Features(rawValue: 0x0000000000002000) // 1<<13

    // Music on iPhones needs this to stream audio
    static let Ft14MFiSoftware = Features(rawValue: 0x0000000000004000) // 1<<14

    // 15-17 not mandatory - faster pairing without
    static let Ft15AudioMetaCovers = Features(rawValue: 0x0000000000008000) // 1<<15
    static let Ft16AudioMetaProgres = Features(rawValue: 0x0000000000010000) // 1<<16
    static let Ft17AudioMetaTxtDAAP = Features(rawValue: 0x0000000000020000) // 1<<17

    // macOS needs 18 to pair
    static let Ft18RcvAudPCM = Features(rawValue: 0x0000000000040000) // 1<<18

    // macOS needs 19
    static let Ft19RcvAudALAC = Features(rawValue: 0x0000000000080000) // 1<<19

    // iOS needs 20
    static let Ft20RcvAudAAC_LC = Features(rawValue: 0x0000000000100000) // 1<<20

    // static let Ft21Unknown = Features(rawValue: 0x0000000000200000) // 1<<21

    // Try Ft22 without Ft40 - ANNOUNCE + SDP
    static let Ft22AudioUnencrypted = Features(rawValue: 0x0000000000400000) // 1<<22
    static let Ft23RSAAuth = Features(rawValue: 0x0000000000800000) // 1<<23

    // Unknown = 1<<24 - 1<<25

    // Pairing stalls with longer /auth-setup string w/26
    // Ft25 seems to require ANNOUNCE
    static let Ft25iTunes4WEncrypt = Features(rawValue: 0x0000000002000000) // 1<<25

    // try Ft26 without Ft40. Ft26 = crypt audio? mutex w/Ft22?
    static let Ft26AudioMfi = Features(rawValue: 0x0000000004000000) // 1<<26

    // 27: connects and works OK
    static let Ft27LegacyPairing = Features(rawValue: 0x0000000008000000) // 1<<27
    static let Ft29plistMetaData = Features(rawValue: 0x0000000020000000) // 1<<29
    static let Ft30UnifiedAdvertInf = Features(rawValue: 0x0000000040000000) // 1<<30

    // Reserved? = 1<<31

    // 32: iOS music does not see AP with this flag, but macOS sees video - bc of HUD?
    static let Ft32CarPlay = Features(rawValue: 0x0000000100000000) // 1<<32
    static let Ft33AirPlayVidPlayQ = Features(rawValue: 0x0000000200000000) // 1<<33
    static let Ft34AirPlayFromCloud = Features(rawValue: 0x0000000400000000) // 1<<34
    static let Ft35TLS_PSK = Features(rawValue: 0x0000000800000000) // 1<<35

    // static let Ft36Unknown = Features(rawValue: 0x0000001000000000) // 1<<36
    static let Ft37CarPlayCtrl = Features(rawValue: 0x0000002000000000) // 1<<37
    static let Ft38CtrlChanEncrypt = Features(rawValue: 0x0000004000000000) // 1<<38

    // 40 absence: requires ANNOUNCE method
    static let Ft40BufferedAudio = Features(rawValue: 0x0000010000000000) // 1<<40
    static let Ft41_PTPClock = Features(rawValue: 0x0000020000000000) // 1<<41
    static let Ft42ScreenMultiCodec = Features(rawValue: 0x0000040000000000) // 1<<42

    // 43: sends system sounds thru also(?) - setup fails with iOS/macOS
    static let Ft43SystemPairing = Features(rawValue: 0x0000080000000000) // 1<<43
    static let Ft44APValeriaScrSend = Features(rawValue: 0x0000100000000000) // 1<<44

    // 45: macOS wont connect, iOS will, but dies on play. 45<->41 seem mut.ex.
    // 45 triggers stream type:96 - 41, stream type:103
    static let Ft45_NTPClock = Features(rawValue: 0x0000200000000000) // 1<<45
    static let Ft46HKPairing = Features(rawValue: 0x0000400000000000) // 1<<46
    static let Ft47PeerMgmt = Features(rawValue: 0x0000800000000000) // 1<<47
    static let Ft48TransientPairing = Features(rawValue: 0x0001000000000000) // 1<<48
    static let Ft49AirPlayVideoV2 = Features(rawValue: 0x0002000000000000) // 1<<49
    static let Ft50NowPlayingInfo = Features(rawValue: 0x0004000000000000) // 1<<50
    static let Ft51MfiPairSetup = Features(rawValue: 0x0008000000000000) // 1<<51
    static let Ft52PeersExtMsg = Features(rawValue: 0x0010000000000000) // 1<<52
    static let Ft54SupportsAPSync = Features(rawValue: 0x0040000000000000) // 1<<54
    static let Ft55SupportsWoL = Features(rawValue: 0x0080000000000000) // 1<<55
    static let Ft56SupportsWoL = Features(rawValue: 0x0100000000000000) // 1<<56
    static let Ft58HangdogRemote = Features(rawValue: 0x0400000000000000) // 1<<58
    static let Ft59AudStreamConnStp = Features(rawValue: 0x0800000000000000) // 1<<59
    static let Ft60AudMediaDataCtrl = Features(rawValue: 0x1000000000000000) // 1<<60
    static let Ft61RFC2198Redundant = Features(rawValue: 0x2000000000000000) // 1<<61
}
