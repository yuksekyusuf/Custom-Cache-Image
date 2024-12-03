//
//  CacheService_Tests.swift
//  CacheService_Tests
//
//  Created by Ahmet Yusuf Yuksek on 29.11.2024.
//

import XCTest
import UIKit
@testable import Custom_Cache_Image

class MockCacheService: CacheServicing {
    var imageCache: [String: UIImage] = [:]
    var didFetchFromNetwork = false
    
    func getImage(key: String, completion: @escaping (UIImage?) -> Void) {
        if let image = imageCache[key] {
            completion(image)
        } else {
            didFetchFromNetwork = true
            completion(nil)
        }
    }
    
    func saveImage(key: String, image: UIImage) {
        imageCache[key] = image
    }
}

final class CacheService_Tests: XCTestCase {
    
    var mockCacheService: MockCacheService!
    var cacheService: CacheService!
    
    override func setUp() {
        super.setUp()
        mockCacheService = MockCacheService()
        cacheService = CacheService()
    }
    
    override func tearDown() {
        mockCacheService = nil
        cacheService = nil
        super.tearDown()
    }
    
    // Test saving an image
    func test_CacheService_ShouldSaveImage() {
        let testKey = "testKey"
        let testImage = UIImage(systemName: "star")!
        
        cacheService.saveImage(key: testKey, image: testImage)
        
        XCTAssertNotNil(cacheService.cache.object(forKey: testKey as NSString), "Image should be saved in the cache.")
    }
    
    // Test fetching an image from the cache
    func test_CacheService_ShouldGetImageFromCache() {
        let testKey = "testKey"
        let testImage = UIImage(systemName: "star")!
        cacheService.saveImage(key: testKey, image: testImage)
        
        let expectation = self.expectation(description: "Fetch image from cache")
        
        cacheService.getImage(key: testKey) { fetchedImage in
            XCTAssertNotNil(fetchedImage, "Fetched image should not be nil.")
            XCTAssertEqual(fetchedImage, testImage, "Fetched image should match the saved image.")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Test fetching an image that is not in the cache
    func test_CacheService_ShouldGetImageFromNetwork() {
        let testKey = "https://example.com/testImage.jpg"
        
        let expectation = self.expectation(description: "Fetch image from network")
        
        cacheService.getImage(key: testKey) { fetchedImage in
            XCTAssertNil(fetchedImage, "Image should not be in the cache or fetched from the network in the mock.")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Test saving and retrieving using the mock cache
    func test_MockCacheService_ShouldSaveImage() {
        let testKey = "mockKey"
        let testImage = UIImage(systemName: "star")!
        
        mockCacheService.saveImage(key: testKey, image: testImage)
        
        let expectation = self.expectation(description: "Fetch image from mock cache")
        
        mockCacheService.getImage(key: testKey) { fetchedImage in
            XCTAssertNotNil(fetchedImage, "Fetched image should not be nil.")
            XCTAssertEqual(fetchedImage, testImage, "Fetched image should match the saved image in the mock cache.")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
