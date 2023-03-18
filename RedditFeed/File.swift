import SwiftUI
import NukeUI
import ComposableArchitecture

struct RedditFeedListItemView: View {
    let post: RedditPost

    var body: some View {
        HStack {
            if let thumbnailUrl = post.thumbnail {
                LazyImage(request: .init(url: thumbnailUrl)) { imageState in
                    if let image = imageState.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 70, height: 70)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    } else if imageState.error == nil  {
                        Color.gray
//                            .shimmering()
                            .frame(width: 70, height: 70)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    } else {
                        EmptyView()
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.gray)
                    .frame(width: 70, height: 70)
            }
            VStack(alignment: .leading) {
                Text(post.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                Text("by \(post.author)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("\(post.numComments) comments")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
