//
//  CameraScreen.swift
//  MustacheShots
//
//  Created by Dev on 13/12/2023.
//

import SwiftUI
import RealityKit
import ARKit

struct VideoScreen: View {
  @State private var isPresented: Bool = false
  var body: some View {
    ARViewContainer().edgesIgnoringSafeArea(.all)
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
