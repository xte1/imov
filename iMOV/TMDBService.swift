import Foundation

struct Movie: Identifiable, Codable {
    let id: Int
    let title: String
    let posterPath: String?
    let voteAverage: Double
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
    }
    
    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
}

struct MovieResponse: Codable {
    let results: [Movie]
}

class TMDBService: ObservableObject {
    @Published var movies: [Movie] = []
    private let apiKey = "YOUR_TMDB_API_KEY" // ضع مفتاحك هنا
    
    // جلب الأفلام الشائعة
    func fetchPopularMovies() {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)&language=ar-SA") else { return }
        performRequest(with: url)
    }
    
    // ميزة البحث عن فيلم
    func searchMovies(query: String) {
        guard !query.isEmpty else {
            fetchPopularMovies()
            return
        }
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(encodedQuery)&language=ar-SA") else { return }
        performRequest(with: url)
    }
    
    private func performRequest(with url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(MovieResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.movies = decoded.results
                    }
                } catch {
                    print("Error decoding: \(error)")
                }
            }
        }.resume()
    }
}
