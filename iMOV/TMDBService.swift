import Foundation

struct Movie: Identifiable, Codable {
    let id: Int
    let title: String?
    let name: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double?
    
    var displayTitle: String {
        title ?? name ?? "بدون عنوان"
    }
    
    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
}

struct TMDBResponse: Codable {
    let results: [Movie]
}

class TMDBService: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    
    private let apiKey = "12bae60f08973cb30c741d0844769d9d"
    private let baseURL = "https://api.themoviedb.org/3"
    
    func fetchTrending() {
        guard let url = URL(string: "\(baseURL)/trending/all/day?api_key=\(apiKey)&language=ar") else { return }
        
        isLoading = true
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false
                guard let data = data, error == nil else { return }
                do {
                    let response = try JSONDecoder().decode(TMDBResponse.self, from: data)
                    self.movies = response.results
                } catch {
                    print("Error decoding: \(error)")
                }
            }
        }.resume()
    }
}
