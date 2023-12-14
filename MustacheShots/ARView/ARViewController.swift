//
//  ARViewController.swift
//  MustacheShots
//
//  Created by Dev on 15/12/2023.
//

import SwiftUI
import ARKit
import RealityKit

struct ARViewController: UIViewRepresentable {
  @Binding var selectedMustache: MustacheTypes
  func makeUIView(context: Context) -> ARView {
    let arView = ARView(frame: .zero)
    let arConfig = ARFaceTrackingConfiguration()
    arView.session.run(arConfig)
    updateARView(arView)
    return arView
  }
  func updateUIView(_ uiView: ARView, context: Context) {
    updateARView(uiView)
  }
  private func updateARView(_ arView: ARView) {
    arView.scene.anchors.removeAll()
    switch selectedMustache {
    case .mustache1:
      if let faceScene = try? Mustache1.load_Mustache1() {
        arView.scene.anchors.append(faceScene)
      }
    case .mustache2:
      if let faceScene = try? Mustache2.load_Mustache2() {
        arView.scene.anchors.append(faceScene)
      }
    }
  }
}
