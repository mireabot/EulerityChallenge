//
//  PetsViewController.swift
//  EulerityChallenge
//
//  Created by Mikhail Kolkov on 2/19/24.
//

import UIKit

protocol PetCellDelegate: AnyObject {
  func didTapSaveButton(in cell: PetView, withImage image: UIImage?)
}

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
  
  private func fetchPetsDataAndDisplay() {
    NetworkManager.shared.fetchPets { [weak self] pets in
      guard let self = self, let pets = pets else {
        print("Error fetching pets")
        return
      }
      DispatchQueue.main.async {
        self.allPets = pets
        self.displayPets(pets: pets)
      }
    }
  }
  
  func displayPets(pets: [Pet]) {
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    pets.forEach { pet in
      let petCell = PetView()
      petCell.delegate = self
      petCell.configure(with: pet)
      stackView.addArrangedSubview(petCell)
    }
  }
  
  // MARK: - PetCellDelegate Methods
  func didTapSaveButton(in cell: PetView, withImage image: UIImage?) {
    print("Image will be saved")
    guard let imageToSave = image else { return }
    UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
    
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
