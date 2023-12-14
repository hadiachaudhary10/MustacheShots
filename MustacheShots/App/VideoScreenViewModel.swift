//
//  VideoScreenViewModel.swift
//  MustacheShots
//
//  Created by Dev on 13/12/2023.
//

import Foundation
import Photos
import AVFoundation

class VideoScreenViewModel: ObservableObject {
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
}
