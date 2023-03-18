//
//  ContentView.swift
//  RedditFeed
//
//  Created by Jacob Martin on 3/17/23.
//

import SwiftUI
import ComposableArchitecture

let feedStore = StoreOf<RedditFeed>(
    initialState: .init(),
    reducer: RedditFeed()
)

struct ContentView: View {
    var body: some View {
        RedditView(store: feedStore)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
