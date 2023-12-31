//
//  CameraScreen.swift
//  MustacheShots
//
//  Created by Dev on 13/12/2023.
//

import SwiftUI
import ARKit

struct VideoScreen: View {
  @State var isRecording: Bool = false
  @State var url: URL?
  @State private var isPresented: Bool = false
  @State var shareVideo: Bool = false
  @State var selectedMustache = MustacheTypes.mustache1
  @StateObject var viewModel: VideoScreenViewModel
  @State private var presentAlert = false
  @State private var tagline = ""
  @StateObject private var keyboardHandler = KeyboardHandler()
  @Environment(\.dismiss) private var dismiss
  var body: some View {
    GeometryReader { geo in
      VStack {
        ARViewController(selectedMustache: $selectedMustache)
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
          .frame(height: geo.size.height * 0.85)
        if keyboardHandler.keyboardHeight == 0 {
          HStack {
            Spacer(minLength: geo.size.width * 0.4)
            Button {
              if isRecording {
                Task {
                  do {
                    self.url = try await stopRecording()
                    isRecording = false
                    shareVideo.toggle()
                    presentAlert = true
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
                .resizable()
                .foregroundColor(isRecording ? .red : .white)
                .frame(width: geo.size.width * 0.2, height: geo.size.width * 0.2)
            }
            Spacer()
            HStack {
              Picker(selectedMustache.rawValue, selection: $selectedMustache) {
                ForEach(MustacheTypes.allCases, id: \.self) { type in
                  Text(type.rawValue)
                }
              }
              .tint(Color.red)
              .pickerStyle(.menu)
              .background(Color.white)
            }
            .frame(width: geo.size.width * 0.3, height: geo.size.height * 0.1)
          }
          .frame(width: geo.size.width, height: geo.size.height * 0.15)
        }
      }
      .frame(width: geo.size.width, height: geo.size.height)
      .background(.black)
    }
    .alert("Tagline for Video", isPresented: $presentAlert) {
      TextField("Enter tagline", text: $tagline)
      Button("OK", action: {
        Task {
          if let url {
            await viewModel.saveVideoURLToCoreData(videoURL: url, tag: tagline)
            dismiss()
          }
        }
      })
    } message: {
      Text("")
    }
  }
}

struct VideoScreen_Previews: PreviewProvider {
  static var previews: some View {
    VideoScreen(viewModel: VideoScreenViewModel())
  }
}
