//
//  NetworkManager.swift
//  EulerityChallenge
//
//  Created by Mikhail Kolkov on 2/19/24.
//

import Foundation
import UIKit

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
    guard let url = URL(string: Endpoints.petsURL.url) else { return }
    URLSession.shared.dataTask(with: url) { data, response, error in
      guard let data = data, error == nil else {
        completion(nil)
        return
      }
      let pets = try? JSONDecoder().decode([Pet].self, from: data)
      completion(pets)
    }.resume()
  }
  
  func fetchUploadURL() async -> String {
    guard let url = URL(string: Endpoints.uploadURL.url) else {
      return ""
    }
    
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
         let uploadURLString = jsonObject["url"] as? String {
        return uploadURLString
      }
    } catch {
      print(error)
    }
    return ""
  }
  
  func uploadImage(_ image: UIImage, appID: String, originalURL: String, to uploadURLString: String, completion: @escaping (Bool, Error?) -> Void) {
    guard let uploadURL = URL(string: uploadURLString) else {
      completion(false, NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid upload URL"]))
      return
    }
    
    var request = URLRequest(url: uploadURL)
    request.httpMethod = "POST"
    
    let boundary = "Boundary-\(UUID().uuidString)"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    request.httpBody = createBody(appID: appID, originalURL: originalURL, image: image, boundary: boundary)
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, error == nil else {
        completion(false, error)
        return
      }
      completion(true, nil)
    }.resume()
  }
  
  private func createBody(appID: String, originalURL: String, image: UIImage, boundary: String) -> Data {
    let lineBreak = "\r\n"
    var body = Data()
    
    let parameters = ["appid": appID, "original": originalURL]
    for (key, value) in parameters {
      body.append("--\(boundary + lineBreak)")
      body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
      body.append("\(value + lineBreak)")
    }
    
    if let imageData = image.jpegData(compressionQuality: 0.75) {
      body.append("--\(boundary + lineBreak)")
      body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\(lineBreak)")
      body.append("Content-Type: image/jpeg\(lineBreak + lineBreak)")
      body.append(imageData)
      body.append(lineBreak)
    }
    
    body.append("--\(boundary)--\(lineBreak)")
    
    return body
  }
}
