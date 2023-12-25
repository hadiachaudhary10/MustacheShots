//
//  ShotData.swift
//  MustacheShots
//
//  Created by Dev on 17/12/2023.
//

import Foundation

struct ShotData: Codable, Identifiable {
  var id: Int
  let duration: String
  let tag: String
  let videoURL: String
}
