//
//  MustacheShotsApp.swift
//  MustacheShots
//
//  Created by Dev on 12/12/2023.
//

import SwiftUI

@main
struct MustacheShotsApp: App {
  let persistenceController = PersistenceController.shared
  var body: some Scene {
    WindowGroup {
      RecordingsListScreen(viewModel: VideoScreenViewModel())
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
