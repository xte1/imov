import SwiftUI

struct ContentView: View {
    @StateObject private var tmdbService = TMDBService()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    
    @State private var showDeveloperPage = false
    @State private var showSettingsPage = false
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: isDarkMode ? .black : .systemGroupedBackground)
                    .ignoresSafeArea()
                
                if tmdbService.isLoading {
                    ProgressView("جاري تحميل الأفلام...")
                        .tint(.blue)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(tmdbService.movies) { movie in
                                VStack(alignment: .leading) {
                                    AsyncImage(url: movie.posterURL) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                    }
                                    .frame(height: 240)
                                    .cornerRadius(12)
                                    .clipped()
                                    
                                    Text(movie.displayTitle)
                                        .font(.system(size: 14, weight: .bold))
                                        .lineLimit(1)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 4)
                                    
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                        Text(String(format: "%.1f", movie.voteAverage ?? 0.0))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("iMOV")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showDeveloperPage = true }) {
                            Label("معلومات المطور", systemImage: "person.circle")
                        }
                        Button(action: { showSettingsPage = true }) {
                            Label("الإعدادات", systemImage: "gearshape")
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            tmdbService.fetchTrending()
        }
        .sheet(isPresented: $showDeveloperPage) {
            DeveloperView()
        }
        .sheet(isPresented: $showSettingsPage) {
            SettingsView()
        }
    }
}
