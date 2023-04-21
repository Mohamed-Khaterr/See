//
//  TMDBImageService.swift
//  See
//
//  Created by Khater on 3/15/23.
//


import UIKit


class TMDBImageService {
    
    // MARK: - Variables
    private var posterImageCache = NSCache<NSString, NSData>()
    private var backdropImageCache = NSCache<NSString, NSData>()
    private let profileImageCache = NSCache<NSString, NSData>()
    
    
    deinit {
        print("Image Service deinit")
    }
    
    
    // MARK: - Functions
    func getPosterImage(withPath path: String, inHeighQulity: Bool) async -> UIImage? {
        // Get Image from Cache
        if let posterImageData = posterImageCache.object(forKey: path as NSString) {
            let data = posterImageData as Data
            return UIImage(data: data)
        }
        
        // Image not found in the Cache
        do {
            // Downalod the Image
            let downloadedImageData = try await downloadImage(withPath: path, inHeighQuality: inHeighQulity)
            
            // Save image in the Poster Cache
            posterImageCache.setObject(downloadedImageData as NSData, forKey: path as NSString)
            
            // Return Image
            return UIImage(data: downloadedImageData)
            
        } catch {
            print("[TMDBImageService] - Poster Image: ", error)
            return nil
        }
    }
    
    func getBackdropImage(withPath path: String, inHeighQuality: Bool) async -> UIImage? {
        // Get Image from Cache
        if let backdropImageData = backdropImageCache.object(forKey: path as NSString) {
            let data = backdropImageData as Data
            return UIImage(data: data)
        }
        
        // Image not found in the Cache
        do {
            // Downalod the Image
            let downloadedImageData = try await downloadImage(withPath: path, inHeighQuality: inHeighQuality)
            
            // Save image in the Backdrop Cache
            backdropImageCache.setObject(downloadedImageData as NSData, forKey: path as NSString)
            
            // Return Image
            return UIImage(data: downloadedImageData)
            
        } catch {
            print("[TMDBImageService] - Backdrop Image: ", error)
            return nil
        }
    }
    
    func getCastProfileImage(withPath path: String, inHeighQuailty: Bool) async -> UIImage? {
        // Get Image from Cache
        if let profileImageData = profileImageCache.object(forKey: path as NSString) {
            let data = profileImageData as Data
            return UIImage(data: data)
        }
        
        // Image not found in the Cache
        do {
            // Downalod the Image
            let downloadedImageData = try await downloadImage(withPath: path, inHeighQuality: inHeighQuailty)
            
            // Save image in the Profile Cache
            profileImageCache.setObject(downloadedImageData as NSData, forKey: path as NSString)
            
            // Return Image
            return UIImage(data: downloadedImageData)
            
        } catch {
            print("[TMDBImageService] - Profiel Image: ", error)
            return nil
        }
    }
    
    
    // MARK: - Downloading Image
    private func downloadImage(withPath path: String, inHeighQuality: Bool) async throws -> Data {
        let url = Endpoint.Image.get(inHeighQuality: inHeighQuality, path: path).url
        do {
            let imageData = try await URLSession.shared.getOnlyData(with: url)
            return imageData
            
        } catch {
            print("[TMDBImageService] : [downloadImage] Error: ", error)
            throw error
        }
    }
}
