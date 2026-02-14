//
//  ContentView.swift
//  Memory Stacker Pro
//
//  Created by Erdinç Yılmaz on 14.02.2026.
//

import SwiftUI
import Combine
import UIKit
import WebKit
import ImageIO

private enum AppColors {
    static let headerPurple = Color(
        red: 58.0 / 255.0,
        green: 48.0 / 255.0,
        blue: 96.0 / 255.0
    )
}

struct ContentView: View {
    @StateObject private var webModel = GameWebViewModel()
    @State private var selectedTab: AppTab = .game
    
    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
    }

    private var appBuild: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "-"
    }

    private var aboutItems: [String] {
        [
            "Memory Stacker Pro, hızlı hafıza ve dikkat odaklı bir oyundur.",
            "Oyun içeriği memory-stacker.netlify.app üzerinden yüklenir.",
            "Bu uygulama iOS tarafında web oyunu native deneyimle birleştirir.",
            "Amaç, sırayı doğru hatırlayıp aşamaları tamamlamaktır.",
            "Sürüm: \(appVersion) (Build \(appBuild))"
        ]
    }

    var body: some View {
        ZStack {
            AppColors.headerPurple
                .ignoresSafeArea()

            Group {
                switch selectedTab {
                case .game:
                    ZStack {
                        GameWebView(webView: webModel.webView)

                        if webModel.shouldShowLoading {
                            LoadingOverlayView()
                                .ignoresSafeArea()
                        }

                        if let errorText = webModel.errorText {
                            VStack(spacing: 10) {
                                Text("Baglanti Sorunu")
                                    .font(.headline)
                                Text(errorText)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                                HStack {
                                    Button("Yeniden Dene") {
                                        webModel.reload()
                                    }
                                    .buttonStyle(.borderedProminent)

                                    Button("Ana Sayfa") {
                                        webModel.loadHome()
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                            .padding(20)
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(24)
                        }
                    }
                case .howToPlay:
                    InfoListView(
                        title: "Nasıl Oynanır",
                        subtitle: "Hızlı başlangıç rehberi",
                        icon: "play.circle.fill",
                        items: [
                            "Dizilimi 7 saniye içinde aklında tut.",
                            "Seçeneklerden aynı sırayı aşağıdan yukarıya diz.",
                            "Kontrol et, doğruysa bitir.",
                            "Yanlış dizilim bir can eksiltir.",
                            "Toplam 3 can ile oyuna devam edersin.",
                            "Oyun 10 aşamadan oluşur."
                        ]
                    )
                case .rules:
                    InfoListView(
                        title: "Kurallar",
                        subtitle: "Oyun akışı ve kısıtlar",
                        icon: "list.bullet.clipboard.fill",
                        items: [
                            "Oyun bellek fazı ve seçim fazından oluşur.",
                            "Geri sayım bitmeden hamleni tamamlamalısın.",
                            "Aşamalarda zorluk kademeli artar.",
                            "Eşleştirme ve yol takip etme gibi farklı modlar açılır.",
                            "Canlar sıfırlandığında oyun biter ve başa dönersin."
                        ]
                    )
                case .about:
                    InfoListView(
                        title: "Uygulama Hakkında",
                        subtitle: "Memory Stacker Pro",
                        icon: "info.circle.fill",
                        items: aboutItems
                    )
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !webModel.shouldShowLoading {
                LiquidTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 0)
                    .offset(y: 6)
                    .frame(maxWidth: .infinity)
                    .background(AppColors.headerPurple)
            }
        }
        .task {
            webModel.ensureInitialLoad()
        }
    }
}

enum AppTab: CaseIterable {
    case game
    case howToPlay
    case rules
    case about

    var icon: String {
        switch self {
        case .game: return "gamecontroller.fill"
        case .howToPlay: return "play.circle.fill"
        case .rules: return "list.bullet.clipboard.fill"
        case .about: return "info.circle.fill"
        }
    }
    
    var title: String {
        switch self {
        case .game: return "Oyun"
        case .howToPlay: return "Nasıl Oynanır"
        case .rules: return "Kurallar"
        case .about: return "Hakkında"
        }
    }
}

struct LiquidTabBar: View {
    @Binding var selectedTab: AppTab
    @Namespace private var liquid

    var body: some View {
        HStack(spacing: 8) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.78)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 15, weight: .semibold))
                        Text(tab.title)
                            .font(.system(size: 10, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(selectedTab == tab ? .white : .white.opacity(0.75))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background {
                        if selectedTab == tab {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.9), .purple.opacity(0.95)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .matchedGeometryEffect(id: "liquid-tab", in: liquid)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.black.opacity(0.55))
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.white.opacity(0.14), lineWidth: 1)
                }
        )
    }
}

struct InfoListView: View {
    let title: String
    let subtitle: String
    let icon: String
    let items: [String]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.cyan.opacity(0.95), .purple.opacity(0.85)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Image(systemName: icon)
                            .foregroundStyle(.white)
                            .font(.system(size: 19, weight: .semibold))
                    }
                    .frame(width: 48, height: 48)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                        Text(subtitle)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [.indigo.opacity(0.4), .purple.opacity(0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.white.opacity(0.16), lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(.bottom, 4)

                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.cyan.opacity(0.95))
                            .padding(.top, 1)
                        Text(item)
                            .foregroundStyle(.white.opacity(0.92))
                            .font(.subheadline.weight(.medium))
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [.white.opacity(0.12), .white.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(.white.opacity(0.15), lineWidth: 1)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding(16)
            .padding(.bottom, 12)
        }
        .scrollIndicators(.hidden)
    }
}

struct GameWebView: UIViewRepresentable {
    let webView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

@MainActor
final class GameWebViewModel: NSObject, ObservableObject {
    @Published var isLoading = true
    @Published var hasLoadedOnce = false
    @Published var errorText: String?

    private let homeBaseURL = URL(string: "https://memory-stacker.netlify.app/")!
    private let allowedHost = "memory-stacker.netlify.app"
    private var didStartInitialLoad = false

    lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.websiteDataStore = .nonPersistent()

        let view = WKWebView(frame: .zero, configuration: configuration)
        view.navigationDelegate = self
        view.uiDelegate = self
        view.allowsBackForwardNavigationGestures = false
        view.scrollView.contentInsetAdjustmentBehavior = .automatic
        view.scrollView.bounces = false
        view.isOpaque = true
        let appBackground = UIColor(
            red: 58.0 / 255.0,
            green: 48.0 / 255.0,
            blue: 96.0 / 255.0,
            alpha: 1
        )
        view.backgroundColor = appBackground
        view.scrollView.backgroundColor = appBackground
        return view
    }()

    func ensureInitialLoad() {
        guard !didStartInitialLoad else { return }
        didStartInitialLoad = true
        loadHome()
    }

    var shouldShowLoading: Bool {
        !hasLoadedOnce || isLoading
    }

    func loadHome() {
        loadHome(in: webView)
    }

    func reload() {
        if webView.url == nil {
            loadHome()
        } else {
            errorText = nil
            webView.reload()
        }
    }

    private func loadHome(in webView: WKWebView) {
        isLoading = true
        errorText = nil
        var components = URLComponents(url: homeBaseURL, resolvingAgainstBaseURL: false)
        var queryItems = components?.queryItems ?? []
        queryItems.removeAll { $0.name.lowercased() == "lang" }
        queryItems.append(URLQueryItem(name: "lang", value: "tr"))
        components?.queryItems = queryItems
        let targetURL = components?.url ?? homeBaseURL

        var request = URLRequest(
            url: targetURL,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 30
        )
        request.setValue("tr", forHTTPHeaderField: "X-App-Locale")
        request.setValue("tr", forHTTPHeaderField: "Accept-Language")
        webView.load(request)
    }

    private func isAllowed(_ url: URL) -> Bool {
        guard let host = url.host else { return false }
        return url.scheme == "https" && host == allowedHost
    }
}

extension GameWebViewModel: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isLoading = true
        errorText = nil
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
        hasLoadedOnce = true
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        isLoading = false
        errorText = "Internet baglantini kontrol edip tekrar dene."
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        if navigationAction.targetFrame == nil {
            webView.load(URLRequest(url: url))
            decisionHandler(.cancel)
            return
        }

        if isAllowed(url) {
            decisionHandler(.allow)
        } else {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        }
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }

}

struct LoadingOverlayView: View {
    var body: some View {
        ZStack {
            AppColors.headerPurple
            VStack(spacing: 14) {
                AnimatedGIFView(name: "loading", size: CGSize(width: 180, height: 180))
                Text("Yukleniyor...")
                    .foregroundStyle(.white)
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct AnimatedGIFView: UIViewRepresentable {
    let name: String
    let size: CGSize

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.frame.size = size
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: size.width),
            imageView.heightAnchor.constraint(equalToConstant: size.height)
        ])
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        if uiView.image == nil {
            uiView.image = UIImage.animatedGIF(named: name)
        }
    }
}

private extension UIImage {
    static func animatedGIF(named name: String) -> UIImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "gif"),
              let data = try? Data(contentsOf: url),
              let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        let frameCount = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var duration: Double = 0

        for index in 0..<frameCount {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) else { continue }
            images.append(UIImage(cgImage: cgImage))

            let frameDuration = Self.frameDuration(from: source, index: index)
            duration += frameDuration
        }

        if duration == 0 { duration = Double(frameCount) * 0.1 }
        return UIImage.animatedImage(with: images, duration: duration)
    }

    static func frameDuration(from source: CGImageSource, index: Int) -> Double {
        let defaultDuration = 0.1
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let gifInfo = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] else {
            return defaultDuration
        }

        if let unclamped = gifInfo[kCGImagePropertyGIFUnclampedDelayTime] as? Double, unclamped > 0 {
            return unclamped
        }
        if let clamped = gifInfo[kCGImagePropertyGIFDelayTime] as? Double, clamped > 0 {
            return clamped
        }
        return defaultDuration
    }
}
