//
//  Enums.swift
//  EulerityChallenge
//
//  Created by Mikhail Kolkov on 2/21/24.
//

import Foundation

enum Endpoints {
  case uploadURL
  case petsURL
  case appID
  
  var url: String {
    switch self {
    case .uploadURL:
      return "https://eulerity-hackathon.appspot.com/upload"
    case .petsURL:
      return "https://eulerity-hackathon.appspot.com/pets"
    case .appID:
      return "iOS_Challenge_Michael"
    }
  }
}
