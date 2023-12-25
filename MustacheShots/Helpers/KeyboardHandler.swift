//
//  KeyboardHandler.swift
//  MustacheShots
//
//  Created by Dev on 25/12/2023.
//

import Combine
import SwiftUI

final class KeyboardHandler: ObservableObject {
  @Published private(set) var keyboardHeight: CGFloat = 0.0
  func getKeybaordHeight() -> CGFloat {
    return keyboardHeight
  }
  private var cancellable: AnyCancellable?
  private let keyboardWillShow = NotificationCenter.default
    .publisher(for: UIResponder.keyboardWillShowNotification)
    .compactMap { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height }
  private let keyboardWillHide =  NotificationCenter.default
    .publisher(for: UIResponder.keyboardWillHideNotification)
    .map { _ in
      CGFloat.zero
    }
  init() {
    cancellable = Publishers.Merge(keyboardWillShow, keyboardWillHide)
      .subscribe(on: DispatchQueue.main)
      .assign(to: \.self.keyboardHeight, on: self)
  }
}
