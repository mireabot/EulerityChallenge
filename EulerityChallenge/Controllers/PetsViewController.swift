//
//  PetsViewController.swift
//  EulerityChallenge
//
//  Created by Mikhail Kolkov on 2/19/24.
//

import UIKit

class PetsViewController: UIViewController, PetViewDelegate {
  private var scrollView: UIScrollView!
  private var stackView: UIStackView!
  private var searchBar: UISearchBar!
  private var allPets: [Pet] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    title = "Pets"
    setupSearchBar()
    setupScrollViewAndStackView()
    fetchPetsDataAndDisplay()
  }
  
  private func setupSearchBar() {
    searchBar = UISearchBar()
    searchBar.placeholder = "Search for favorite pet"
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    searchBar.delegate = self
    view.addSubview(searchBar)
    
    NSLayoutConstraint.activate([
      searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }
  
  private func setupScrollViewAndStackView() {
    scrollView = UIScrollView()
    scrollView.isDirectionalLockEnabled = true
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    
    stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 10
    stackView.alignment = .fill
    stackView.distribution = .equalSpacing
    stackView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(stackView)
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
    ])
  }
  
  // Dynamicly adding views to the stack
  func displayPets(pets: [Pet]) {
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    pets.forEach { pet in
      let petCell = PetView()
      // Connecting delegate of UI Cell
      petCell.delegate = self
      petCell.configure(with: pet)
      stackView.addArrangedSubview(petCell)
    }
  }
  
  private func fetchPetsDataAndDisplay() {
    NetworkManager.shared.fetchPets { [weak self] pets in
      guard let self = self, let pets = pets else {
        DispatchQueue.main.async {
          let alert = UIAlertController(title: "Something went wrong", message: "Error while fetching pets", preferredStyle: UIAlertController.Style.alert)
          alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
            self?.fetchPetsDataAndDisplay()
          }))
          alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
          
          self?.present(alert, animated: true, completion: nil)
        }
        return
      }
      DispatchQueue.main.async {
        self.allPets = pets
        self.displayPets(pets: pets)
      }
    }
  }
}

// MARK: - PetCellDelegate Methods
extension PetsViewController {
  func didTapSaveButton(in view: PetView, withImage image: UIImage?, originalUrl: String?) {
    guard let imageToSave = image, let originalUrl = originalUrl else { return }
    UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
    Task {
      let url = await NetworkManager.shared.fetchUploadURL()
      NetworkManager.shared.uploadImage(imageToSave, appID: Endpoints.appID.url, originalURL: originalUrl, to: url) { result, error in
        if result {
          DispatchQueue.main.async {
            let alert = UIAlertController(title: "Image was submited", message: "It will be saved in photo library and remote server", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
          }
        } else {
          DispatchQueue.main.async {
            let alert = UIAlertController(title: "Something wrong happened", message: "\(String(describing: error?.localizedDescription))", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
          }
        }
      }
    }
  }
}

// MARK: - UISearchBarDelegate Methods
extension PetsViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    let filteredPets = searchText.isEmpty ? allPets : allPets.filter { pet in
      pet.title.lowercased().contains(searchText.lowercased()) ||
      pet.description.lowercased().contains(searchText.lowercased())
    }
    displayPets(pets: filteredPets)
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = ""
    searchBar.resignFirstResponder()
    displayPets(pets: allPets)
  }
}
