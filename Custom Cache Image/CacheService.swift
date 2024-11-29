//
//  CacheService.swift
//  Custom Cache Image
//
//  Created by Ahmet Yusuf Yuksek on 29.11.2024.
//

import UIKit

// Protocol defining caching behavior
protocol CacheServicing {
    // Fetches image from cache or downloads it
    func getImage(key: String, completion: @escaping (_ image: UIImage?) -> Void)
    // Saves image to cache
    func saveImage(key: String, image: UIImage)
}

class CacheService: CacheServicing {

    // NSCache instance for in-memory caching
    let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100 // Maximum number of items to store
        cache.totalCostLimit = 1024 * 1024 * 100 // Maximum memory cost in bytes (100 MB)
        return cache
    }()
    
    // Retrieves an image from the cache or downloads it
    func getImage(key: String, completion: @escaping (_ image: UIImage?) -> Void) {
        // Check cache for the image
        if let image = cache.object(forKey: key as NSString) {
            print("Image is in cache")
            DispatchQueue.main.async {
                completion(image)
            }
            return
        }
        
        // If not in cache, fetch the image from the URL
        fetchImage(urlString: key) { [weak self] data in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            guard let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            // Save fetched image to cache
            self?.saveImage(key: key, image: image)
            print("Image fetched and saved in cache")
            DispatchQueue.main.async {
                completion(image) // Return the fetched image
            }
        }
    }
    
    // Saves an image to the in-memory cache
    func saveImage(key: String, image: UIImage) {
        cache.setObject(image, forKey: key as NSString)
        print("Image saved to cache")
    }
    
    // Fetches image data from a remote URL
    private func fetchImage(urlString: String, completion: @escaping (_ data: Data?) -> Void) {
        // Validate URL string
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil) // Return nil if URL is invalid
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle network errors
            if let error = error {
                print("Error fetching image: \(error)")
                completion(nil)
                return
            }
            
            // Validate HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("Unexpected HTTP status code: \(httpResponse.statusCode)")
                    completion(nil)
                    return
                }
            } else {
                print("Invalid response type")
                completion(nil)
                return
            }
            
            // Ensure data is non-nil
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            completion(data) // Return valid data
        }
        .resume()
    }
}
