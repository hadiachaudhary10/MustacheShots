//
//  CameraScreen.swift
//  MustacheShots
//
//  Created by Dev on 13/12/2023.
//

import SwiftUI
import AVFoundation
import CoreImage
import Photos

struct VideoScreen: View {
  var body: some View {
    ZStack(alignment: .bottom) {
      
      ZStack {
        Button {
          
        } label: {
          Image(systemName: "square.and.pencil")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
        }
        Button {
          
        } label: {
          Text("preview")
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing)
      }.frame(maxHeight: .infinity, alignment: .bottom)
      .padding(.bottom, 10)
      .padding(.bottom, 30)
    }
    .preferredColorScheme(.dark)
  }
}

struct CameraScreen_Previews: PreviewProvider {
  static var previews: some View {
    VideoScreen()
  }
}

struct CameraView: View {
  @StateObject var camera = CameraModel()
  var body: some View {
    ZStack {
      CameraPreview(camera: camera)
        .ignoresSafeArea(.all, edges: .all)
      VStack {
        if camera.isTaken {
          HStack {
            Spacer()
            Button {
              camera.retakePic()
            } label: {
              Image(systemName: "arrow.triangle.2.circlepath.camera")
                .foregroundColor(.black)
                .padding()
                .background(Color.white)
                .clipShape(Capsule())
            }
            .padding(.trailing, 10)
          }
        }
        Spacer()
        HStack {
          if camera.isTaken {
            Button {
              if !camera.isSaved {
                camera.savePic()
              }
            } label: {
              Text(camera.isSaved ? "Saved" : "Save")
                .foregroundColor(.black)
                .fontWeight(.semibold)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.white)
                .clipShape(Capsule())
            }
            .padding(.leading)
            Spacer()

          } else {
            Button {
              camera.takePic()
            } label: {
              ZStack {
                Circle()
                  .fill(Color.white)
                  .frame(width: 70, height: 70)
                Circle()
                  .stroke(Color.white, lineWidth: 2)
                  .frame(width: 77, height: 77)
              }
            }
          }
        }
        .frame(height: 77)
      }
    }
    .onAppear {
      camera.check()
    }
  }
}

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
  @Published var isTaken = false
  @Published var session = AVCaptureSession()
  @Published var alert = false
  @Published var output = AVCapturePhotoOutput()
  @Published var preview: AVCaptureVideoPreviewLayer!
  @Published var isSaved = false
  @Published var picData = Data(count: 0)
  func check() {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      setUp()
      return
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { status in
        if status {
          self.setUp()
        }
      }
    case .denied:
      alert.toggle()
      return
    default:
      return
    }
  }
  func setUp() {
    do {
      session.beginConfiguration()
      guard let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) else { return }
      let input = try AVCaptureDeviceInput(device: device)
      if session.canAddInput(input) {
        session.addInput(input)
      }
      if session.canAddOutput(output) {
        session.addOutput(output)
      }
      session.commitConfiguration()
    } catch {
      print(error.localizedDescription)
    }
  }
  func takePic() {
    DispatchQueue.global(qos: .background).async {
      self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
      self.session.stopRunning()
      DispatchQueue.main.async {
        withAnimation {
          self.isTaken.toggle()
        }
      }
    }
  }
  func retakePic() {
    DispatchQueue.global(qos: .background).async {
      self.session.startRunning()
      DispatchQueue.main.async {
        withAnimation {
          self.isTaken.toggle()
        }
        self.isSaved = false
      }

    }
  }
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    if error != nil {
      return
    }
    print("pic taken")
    guard let imageData = photo.fileDataRepresentation() else {
      return
    }
    self.picData = imageData
  }
  func savePic() {
    guard let image = UIImage(data: self.picData) else { return }
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    self.isSaved = true
    print("saved successfully")
  }
}

struct CameraPreview: UIViewRepresentable {
  @ObservedObject var camera: CameraModel
  func makeUIView(context: Context) -> some UIView {
    let view = UIView(frame: UIScreen.main.bounds)
    DispatchQueue.main.async {
      camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
      camera.preview.frame = view.frame
      camera.preview.videoGravity = .resizeAspectFill
      view.layer.addSublayer(camera.preview)
    }
    camera.session.startRunning()
//    DispatchQueue.global(qos: .background).async {
//      camera.session.startRunning()
//    }
    return view
  }
  func updateUIView(_ uiView: UIViewType, context: Context) {
    
  }
}
