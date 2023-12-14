//
//  View+Extensions.swift
//  MustacheShots
//
//  Created by Dev on 15/12/2023.
//

import SwiftUI
import ReplayKit

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
