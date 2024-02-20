//
//  NetworkManager.swift
//  EulerityChallenge
//
//  Created by Mikhail Kolkov on 2/19/24.
//

import Foundation

struct Pet: Decodable {
  let title: String
  let description: String
  let url: String
  let created: String
  
  enum CodingKeys: String, CodingKey {
    case title
    case description
    case url
    case created
  }
}

final class NetworkManager {
  
  static let shared = NetworkManager()
  
  private init() {}
  
  func fetchPets(completion: @escaping ([Pet]?) -> Void) {
    guard let url = URL(string: "https://eulerity-hackathon.appspot.com/pets") else { return }
    URLSession.shared.dataTask(with: url) { data, response, error in
      guard let data = data, error == nil else {
        completion(nil)
        return
      }
      let pets = try? JSONDecoder().decode([Pet].self, from: data)
      completion(pets)
    }.resume()
  }
  
  func fetchUploadURL(completion: @escaping (URL?) -> Void) {
    guard let url = URL(string: "https://eulerity-hackathon.appspot.com/upload") else {
      completion(nil)
      return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
      guard let data = data, error == nil else {
        completion(nil)
        return
      }
      
      do {
        if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let uploadURLString = jsonObject["url"] as? String,
           let uploadURL = URL(string: uploadURLString) {
          completion(uploadURL)
        } else {
          completion(nil)
        }
      } catch {
        completion(nil)
      }
    }.resume()
  }
}
