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
  @State private var presentAlert = false
  @State private var newTagline = ""
  @StateObject private var keyboardHandler = KeyboardHandler()
  @State var rowSize: CGSize = .zero
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
                  .frame(width: rowSize.width * 0.3, height: rowSize.height * 0.17)
                  .cornerRadius(15)
              }
              .frame(width: rowSize.width * 0.3, height: rowSize.height * 0.2)
              VStack(alignment: .leading) {
                HStack {
                  Text(shot.tag!)
                  Spacer()
                  Button {
                    presentAlert = true
                  } label: {
                    Image(systemName: "square.and.pencil")
                      .imageScale(.medium)
                  }
                }
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
              .frame(width: rowSize.width * 0.5, height: rowSize.height * 0.2)
            }
            .frame(width: rowSize.width * 0.9, height: rowSize.height * 0.2)
            .background(Color.pastelGrey)
            .cornerRadius(15)
            .alert("Update Tagline", isPresented: $presentAlert) {
              TextField("Enter new tagline", text: $newTagline)
              Button("OK", action: {
                if !newTagline.isEmpty {
                  viewModel.updateTagline(shotID: shot.id, updatedTagline: newTagline)
                }
              })
            } message: {
              Text("")
            }
          }
        }
        .frame(width: geo.size.width, height: geo.size.height)
        .onAppear {
          rowSize = CGSize(width: geo.size.width, height: geo.size.height)
        }
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
