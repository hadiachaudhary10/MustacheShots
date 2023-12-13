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
  var body: some View {
    VStack {
      ARViewContainer()
        .edgesIgnoringSafeArea(.all)
    }
  }
}

struct CameraScreen_Previews: PreviewProvider {
  static var previews: some View {
    VideoScreen()
  }
}

struct ARViewContainer: UIViewRepresentable {
  func makeUIView(context: Context) -> some UIView {
    let arView = ARView(frame: .zero)
    let config = ARFaceTrackingConfiguration()
    arView.session.run(config)
    let sphere = ModelEntity(mesh: .generateSphere(radius: 0.08), materials: [SimpleMaterial(color: UIColor.blue, roughness: 0.2, isMetallic: true)])
    let anchor = AnchorEntity(.face)
    anchor.addChild(sphere)
    arView.scene.addAnchor(anchor)
    return arView
  }
  func updateUIView(_ uiView: UIViewType, context: Context) {}
}
