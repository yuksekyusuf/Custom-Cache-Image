//
//  Custom_Cache_ImageApp.swift
//  Custom Cache Image
//
//  Created by Ahmet Yusuf Yuksek on 29.11.2024.
//

import SwiftUI

@main
struct Custom_Cache_ImageApp: App {
    let dependencies = [CacheService()]
    var body: some Scene {
        WindowGroup {
            CustomCachingImageView(urlString: "https://picsum.photos/200", cacheService: dependencies[0]) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .clipped()
            }
        }
    }
}
