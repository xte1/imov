import SwiftUI

struct ContentView: View {
    @StateObject private var tmdbService = TMDBService()
    @State private var searchQuery = ""
    @State private var selectedMovie: Movie?

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            VStack {
                // شريط البحث
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("بحث عن فيلم...", text: $searchQuery)
                        .onChange(of: searchQuery) { newValue in
                            tmdbService.searchMovies(query: newValue)
                        }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)

                // عرض شبكة الأفلام
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(tmdbService.movies) { movie in
                            VStack(alignment: .leading) {
                                AsyncImage(url: movie.posterURL) { image in
                                    image.resizable()
                                         .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Rectangle().fill(Color.gray.opacity(0.3))
                                }
                                .frame(height: 220)
                                .cornerRadius(10)
                                .clipped()

                                Text(movie.title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .lineLimit(1)

                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text(String(format: "%.1f", movie.voteAverage))
                                        .foregroundColor(.gray)
                                }
                            }
                            .onTapGesture {
                                selectedMovie = movie
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("iMOV")
            .onAppear {
                tmdbService.fetchPopularMovies()
            }
            // فتح صفحة التشغيل عند النقر على الفيلم
            .sheet(item: $selectedMovie) { movie in
                if let streamURL = URL(string: "https://vidsrc.to/embed/movie/\(movie.id)") { // سيرفر تجريبي للمشاهدة
                    WebView(url: streamURL)
                }
            }
        }
    }
}
