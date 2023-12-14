//
//  MustacheTypes.swift
//  MustacheShots
//
//  Created by Dev on 15/12/2023.
//

import Foundation

enum MustacheTypes: String, CaseIterable, Identifiable {
  var id: String { self.rawValue }
  case mustache1 = "Mustache1"
  case mustache2 = "Mustache2"
}
