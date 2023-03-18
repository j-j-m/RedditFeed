import SwiftUI
import ComposableArchitecture

public struct RedditFeed: ReducerProtocol {

    public struct State: Equatable {
        public var posts: [Post] = []

        public struct Post: Equatable {
            public let id: String
            public let title: String
            public let author: String
            public let date: Date
            public let upvotes: Int
            public let comments: Int
        }
    }

    public enum Action: Equatable {
        case loadPosts
        case postsLoaded([State.Post])
        case postsError(String)
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadPosts:
                return .task {
                    let posts = try await RedditAPI().loadPosts()
                    return .postsLoaded(posts)
                } catch: { error in
                    return .postsError("Error loading posts: \(error)")
                }

            case .postsError(let description):
                print(description)
                return .none

            case .postsLoaded(let posts):
                state.posts = posts
                return .none
            }
        }
    }
}

public struct RedditView: View {
    public let store: Store<RedditFeed.State, RedditFeed.Action>

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                List(viewStore.state.posts, id: \.id) { post in
                    VStack(alignment: .leading) {
                        Text(post.title)
                            .font(.headline)
                        Text("By \(post.author) on \(post.date)")
                            .font(.subheadline)
                        HStack {
                            Text("\(post.upvotes) upvotes")
                                .font(.caption)
                            Text("\(post.comments) comments")
                                .font(.caption)
                        }
                    }
                }
//                .navigationBarTitle("Reddit Feed")
            }
            .onAppear {
                viewStore.send(.loadPosts)
            }
        }
    }
}

public struct RedditAPI {
    public func loadPosts() async throws -> [RedditFeed.State.Post] {
        let url = URL(string: "https://www.reddit.com/r/swift.json")!

        let (data, _) = try await URLSession.shared.data(from: url)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let response = try decoder.decode(RedditResponse.self, from: data)
        let posts = response.data.children.compactMap { child -> RedditFeed.State.Post? in
            guard let createdUtc = child.data.createdUtc else { return nil }
            return RedditFeed.State.Post(
                id: child.data.id,
                title: child.data.title,
                author: child.data.author,
                date: createdUtc,
                upvotes: child.data.ups,
                comments: child.data.numComments ?? 0
            )
        }

        return posts
    }
}

public struct RedditResponse: Codable {
    public let data: RedditData

    public struct RedditData: Codable {
        public let children: [RedditChild]

        public struct RedditChild: Codable {
            public let data: RedditPost
        }
    }
}

public struct RedditPost: Codable {
    public let id: String
    public let title: String
    public let author: String
    public let createdUtc: Date?
    public let ups: Int
    public let numComments: Int?
}
