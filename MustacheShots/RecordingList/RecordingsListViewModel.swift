//
//  RecordingsListViewModel.swift
//  MustacheShots
//
//  Created by Dev on 13/12/2023.
//

import Foundation
import CoreData

class RecordingsListViewModel: ObservableObject {
  @Published var numberOfShots: Int = 5
  @Published var shots: [Shot] = []
  init() {}
  func fetchShots() {
    let fetchRequest: NSFetchRequest<Shot> = Shot.fetchRequest()
    fetchRequest.returnsDistinctResults = true
    fetchRequest.propertiesToFetch = ["id"]
    do {
      let result = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
      shots = result
    } catch {
      print("Error fetching items: \(error)")
    }
  }
}
