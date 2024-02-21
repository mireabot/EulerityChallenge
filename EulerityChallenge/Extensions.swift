//
//  Extensions.swift
//  EulerityChallenge
//
//  Created by Mikhail Kolkov on 2/20/24.
//

import UIKit

extension UIImageView {
  func loadImage(from urlString: String) {
    guard let url = URL(string: urlString) else { return }
    URLSession.shared.dataTask(with: url) { data, _, _ in
      guard let data = data, let image = UIImage(data: data) else { return }
      DispatchQueue.main.async {
        self.image = image
      }
    }.resume()
  }
}

extension Data {
  mutating func append(_ string: String) {
    if let data = string.data(using: .utf8) {
      append(data)
    }
  }
}
