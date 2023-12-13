//
//  RecordingsListViewModel.swift
//  MustacheShots
//
//  Created by Dev on 13/12/2023.
//

import Foundation

class RecordingsListViewModel: ObservableObject {
  @Published var numberOfShots: Int = 5
  init() {}
}
