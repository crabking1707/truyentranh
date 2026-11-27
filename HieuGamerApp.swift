import SwiftUI
import AVFoundation

@main
struct HieuGamerApp: App {
    init() {
        // Giữ audio session để PiP "giữ luồng" hoạt động khi thoát ra màn hình chính
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
        try? session.setActive(true)
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color(red: 0.086, green: 0.082, blue: 0.071).ignoresSafeArea()
                ChessWebView()
            }
            .preferredColorScheme(.dark)
            .onAppear {
                // Không cho màn hình tự tắt khi đang chơi
                UIApplication.shared.isIdleTimerDisabled = true
            }
        }
    }
}
