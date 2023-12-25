//
//  Persistence.swift
//  MustacheShots
//
//  Created by Dev on 12/12/2023.
//

import CoreData
import Foundation

struct PersistenceController {
  static let shared = PersistenceController()
  let container: NSPersistentContainer
  init() {
    container = NSPersistentContainer(name: "MustacheShots")
    container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    container.loadPersistentStores(completionHandler: {_, _ in })
    container.viewContext.automaticallyMergesChangesFromParent = true
  }
  func clear() {
    // Delete all dishes from the store
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Shot")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    _ = try? container.persistentStoreCoordinator.execute(deleteRequest, with: container.viewContext)
  }
}
