//
//  RecordingsListScreen.swift
//  MustacheShots
//
//  Created by Dev on 13/12/2023.
//

import SwiftUI
import CoreData
import AVKit

struct VideoPlayerView: UIViewControllerRepresentable {
  let videoURLString: String
  func makeUIViewController(context: Context) -> AVPlayerViewController {
    guard let videoURL = URL(string: videoURLString) else {
      fatalError("Invalid video URL string")
    }
    let playerItem = AVPlayerItem(url: videoURL)
    let player = AVPlayer(playerItem: playerItem)
    let playerViewController = AVPlayerViewController()
    playerViewController.player = player
    playerViewController.showsPlaybackControls = true
    return playerViewController
  }
  func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

struct RecordingsListScreen: View {
  @StateObject var viewModel: VideoScreenViewModel
  @Environment(\.managedObjectContext) private var viewContext
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Shot.duration, ascending: true)],
    animation: .default)
  private var shots: FetchedResults<Shot>
  var body: some View {
    NavigationStack {
      GeometryReader { geo in
        ScrollView {
          ForEach(shots) { shot in
            HStack(alignment: .center) {
              VStack(alignment: .center) {
                VideoPlayer(player: AVPlayer(url: URL(string: shot.videoURL!)!))
                  .scaledToFit()
                  .frame(width: geo.size.width * 0.3, height: geo.size.height * 0.2)
                  .cornerRadius(15)
              }
              .frame(width: geo.size.width * 0.3, height: geo.size.height * 0.2)
              VStack(alignment: .leading) {
                Text(shot.tag!)
                Spacer()
                HStack {
                  Text(shot.duration!)
                  Spacer()
                  NavigationLink(destination: VideoPlayerView(videoURLString: shot.videoURL!)) {
                    Image(systemName: "chevron.right")
                      .imageScale(.medium)
                  }
                }
              }
              .padding(.vertical)
              .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.2)
            }
            .frame(width: geo.size.width * 0.9, height: geo.size.height * 0.2)
            .background(Color.pastelGrey)
            .cornerRadius(15)
          }
        }
        .frame(width: geo.size.width, height: geo.size.height)
      }
      .padding(.top)
      .navigationTitle("Recordings List")
      .navigationBarItems(trailing: NavigationLink(destination: VideoScreen(viewModel: VideoScreenViewModel())) {
        Image(systemName: "plus")
      })
      .toolbarColorScheme(.dark, for: .navigationBar)
      .toolbarBackground(Gradient.blueGrottoGradident, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
    }
  }
}

struct RecordingsListScreen_Previews: PreviewProvider {
  static var previews: some View {
    RecordingsListScreen(viewModel: VideoScreenViewModel())
  }
}
