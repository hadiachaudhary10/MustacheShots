//
//  CameraScreen.swift
//  MustacheShots
//
//  Created by Dev on 13/12/2023.
//

import SwiftUI
import RealityKit
import ARKit
import ReplayKit
import Photos
import AVFoundation

extension View {
  func startRecording(enableMicrophone: Bool = false, completion: @escaping (Error?) -> Void) {
    let recorder = RPScreenRecorder.shared()
    recorder.isMicrophoneEnabled = enableMicrophone
    recorder.startRecording(handler: completion)
  }
  func stopRecording() async throws -> URL {
    let name = UUID().uuidString + ".mov"
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
    let recorder = RPScreenRecorder.shared()
    try await recorder.stopRecording(withOutput: url)
    return url
  }
  func cancelRecording() {
    let recorder = RPScreenRecorder.shared()
    recorder.discardRecording {}
  }
}

struct VideoScreen: View {
  @State var isRecording: Bool = false
  @State var url: URL?
  @State private var isPresented: Bool = false
  @State var shareVideo: Bool = false
  var body: some View {
    ARViewContainer()
      .edgesIgnoringSafeArea(.all)
      .alert("Face Tracking Unavailable", isPresented: $isPresented) {
        Button {
          isPresented = false
        } label: {
          Text("Okay")
        }
      } message: {
        Text("Face tracking requires an iPhone X or later.")
      }
      .onAppear {
        if !ARFaceTrackingConfiguration.isSupported {
          isPresented = true
        }
      }
      .overlay(alignment: .bottomTrailing) {
        Button {
          if isRecording {
            Task {
              do {
                self.url = try await stopRecording()
                isRecording = false
                shareVideo.toggle()
                if let url {
                  saveVideoToAlbum(videoURL: url, albumName: "MyAlbum")
                }
              } catch {
                print(error.localizedDescription)
              }
            }
          } else {
            startRecording(enableMicrophone: true) { error in
              if let error = error {
                print(error.localizedDescription)
                return
              }
              isRecording = true
            }
          }
        } label: {
          Image(systemName: "record.circle")
            .font(.largeTitle)
            .foregroundColor(isRecording ? .red : .black)
        }
      }
  }
  private func saveVideoToAlbum(videoURL: URL, albumName: String) {
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

struct ARViewContainer: UIViewRepresentable {
  func makeUIView(context: Context) -> ARView {
    let arView = ARView(frame: .zero)
    if let faceScene = try? Mustache2.load_Mustache2() {
      arView.scene.anchors.append(faceScene)
    }
    let arConfig = ARFaceTrackingConfiguration()
    arView.session.run(arConfig)
    return arView
  }
  func updateUIView(_ uiView: ARView, context: Context) {}
}

struct VideoScreen_Previews: PreviewProvider {
  static var previews: some View {
    VideoScreen()
  }
}
