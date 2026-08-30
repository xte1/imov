import SwiftUI

struct MovieSite: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let url: String
}

struct ContentView: View {
    @AppStorage("lastURL") private var currentURLString: String = "https://cinejoy.com"
    @AppStorage("selectedSiteName") private var selectedSiteName: String = "Cinejoy"
    
    @State private var showDeveloperPage = false
    @State private var showSettingsPage = false
    
    let sites: [MovieSite] = [
        MovieSite(name: "Cinejoy", url: "https://cinejoy.com"),
        MovieSite(name: "فيديو فيولا", url: "https://videoviola.com"),
        MovieSite(name: "Akwam", url: "https://akwam.to"),
        MovieSite(name: "Wecima", url: "https://wecima.show"),
        MovieSite(name: "Krmzi", url: "https://krmzi.com"),
        MovieSite(name: "Starcima", url: "https://starcima.com")
    ]

    var body: some View {
        ZStack(alignment: .top) {
            // صفحة الويب مدمجة على كامل الشاشة خلف القوائم الزجاجية
            WebView(urlString: $currentURLString)
                .ignoresSafeArea()

            // الشريط العلوي الزجاجي العائم فوق الويب مباشرة
            HStack {
                // قائمة اختيار المواقع
                Menu {
                    ForEach(sites) { site in
                        Button(action: {
                            selectedSiteName = site.name
                            currentURLString = site.url
                        }) {
                            HStack {
                                Text(site.name)
                                if selectedSiteName == site.name {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "tv")
                            .font(.system(size: 14, weight: .semibold))
                        Text(selectedSiteName)
                            .font(.system(size: 15, weight: .bold))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                }

                Spacer()

                // قائمة الإعدادات والمطور
                Menu {
                    Button(action: { showDeveloperPage = true }) {
                        Label("معلومات المطور", systemName: "person.circle")
                    }
                    
                    Button(action: { showSettingsPage = true }) {
                        Label("الإعدادات", systemName: "gearshape")
                    }
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(12)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 50)
        }
        .sheet(isPresented: $showDeveloperPage) {
            DeveloperView()
        }
        .sheet(isPresented: $showSettingsPage) {
            SettingsView()
        }
    }
}
