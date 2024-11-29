//
//  ContentView.swift
//  Custom Cache Image
//
//  Created by Ahmet Yusuf Yuksek on 29.11.2024.
//

import SwiftUI

struct CustomCachingImageView<Content: View>: View {
    let urlString: String
    let cacheService: CacheServicing
    let content: (Image) -> Content

    init(
        urlString: String,
        cacheService: CacheServicing,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.urlString = urlString
        self.cacheService = cacheService
        self.content = content
    }

    @State private var image: UIImage?

    var body: some View {
        ZStack {
            if let uiImage = image {
                content(Image(uiImage: uiImage))
            } else {
                ProgressView()
            }
        }
        .onAppear {
            cacheService.getImage(key: urlString) { fetchedImage in
                image = fetchedImage
            }
        }
    }
}

#Preview {
    CustomCachingImageView(urlString: "https://picsum.photos/200", cacheService: CacheService()) { image in
        image
            .resizable()
            .scaledToFit()
            .frame(width: 200)
            .clipped()
    }
}
