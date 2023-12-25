//
//  VideoScreenViewModel.swift
//  MustacheShots
//
//  Created by Dev on 13/12/2023.
//

import Foundation
import Photos
import AVFoundation
import CoreData

class VideoScreenViewModel: ObservableObject {
  @Published var numberOfShots: Int = 5
  @Published var shots: [Shot] = []
  init() {}
  func saveVideoToAlbum(videoURL: URL, albumName: String) {
    if albumExists(albumName: albumName) {
      let fetchOptions = PHFetchOptions()
      fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
      let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
      if let album = collection.firstObject {
        saveVideo(videoURL: videoURL, to: album)
      }
    } else {
      var albumPlaceholder: PHObjectPlaceholder?
      PHPhotoLibrary.shared().performChanges({
        let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
        albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
      }, completionHandler: { success, error in
        if success {
          guard let albumPlaceholder = albumPlaceholder else { return }
          let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumPlaceholder.localIdentifier], options: nil)
          guard let album = collectionFetchResult.firstObject else { return }
          self.saveVideo(videoURL: videoURL, to: album)
        } else {
          print("Error creating album: \(error?.localizedDescription ?? "")")
        }
      })
    }
  }
  private func albumExists(albumName: String) -> Bool {
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
    let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
    return collection.firstObject != nil
  }
  private func saveVideo(videoURL: URL, to album: PHAssetCollection) {
    PHPhotoLibrary.shared().performChanges({
      let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
      let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
      let enumeration: NSArray = [assetChangeRequest!.placeholderForCreatedAsset!]
      albumChangeRequest?.addAssets(enumeration)
    }, completionHandler: { success, error in
      if success {
        print("Successfully saved video to album")
      } else {
        print("Error saving video to album: \(error?.localizedDescription ?? "")")
      }
    })
  }
  func saveVideoURLToCoreData(videoURL: URL, tag: String) {
    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    context.parent = PersistenceController.shared.container.viewContext
    let videoEntity = Shot(context: context)
    videoEntity.videoURL = videoURL.absoluteString
    videoEntity.duration = getVideoDuration(from: videoURL)
    videoEntity.tag = tag
    videoEntity.id = UUID().uuidString
    do {
      try context.save()
      print("Video saved to Core Data")
    } catch {
      print("Error saving video URL to Core Data: \(error.localizedDescription)")
    }
  }
  func getVideoDuration(from path: URL) -> String {
    let asset = AVURLAsset(url: path)
    let duration: CMTime = asset.duration
    let totalSeconds = CMTimeGetSeconds(duration)
    let hours = Int(totalSeconds / 3600)
    let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
    let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
    if hours > 0 {
      return String(format: "%i:%02i:%02i", hours, minutes, seconds)
    } else {
      return String(format: "%02i:%02i", minutes, seconds)
    }
  }
}
