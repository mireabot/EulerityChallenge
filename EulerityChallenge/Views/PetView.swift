//
//  PetView.swift
//  EulerityChallenge
//
//  Created by Mikhail Kolkov on 2/20/24.
//

import UIKit

// MARK: Delegate which handles image which will be saved to library
protocol PetViewDelegate: AnyObject {
    func didTapSaveButton(in view: PetView, withImage image: UIImage?, originalUrl: String?)
}

// MARK: UI which shows info about pet
class PetView: UIView {
  weak var delegate: PetViewDelegate?
  
  private let imageView = UIImageView()
  private let titleLabel = UILabel()
  private let descriptionLabel = UILabel()
  private let saveButton = UIButton()
  private let stackView = UIStackView()
  private var pet: Pet?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .secondarySystemBackground
    setupViews()
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // Configurator for cell
  func configure(with pet: Pet) {
    self.pet = pet
    imageView.loadImage(from: pet.url)
    titleLabel.text = pet.title
    descriptionLabel.text = pet.description
  }
  
  private func setupViews() {
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 5
    imageView.backgroundColor = .lightGray
    
    titleLabel.font = UIFont.systemFont(ofSize: 17)
    titleLabel.textColor = .black
    
    descriptionLabel.font = UIFont.systemFont(ofSize: 13)
    descriptionLabel.textColor = .systemGray2
    
    saveButton.configuration = .borderedProminent()
    saveButton.setTitle("Save Image", for: .normal)
    
    saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    
    stackView.axis = .vertical
    stackView.alignment = .leading
    stackView.spacing = 8
    
    stackView.addArrangedSubview(imageView)
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(descriptionLabel)
    stackView.addArrangedSubview(saveButton)
    
    stackView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(stackView)
  }
  
  private func setupLayout() {
    NSLayoutConstraint.activate([
      imageView.widthAnchor.constraint(equalToConstant: 90),
      imageView.heightAnchor.constraint(equalToConstant: 90),
      
      stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
      stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -10),
      stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10)
    ])
  }
  
  // MARK: Function for save button with passing delegate
  @objc private func saveButtonTapped() {
    if let image = imageView.image, let url = pet?.url {
      delegate?.didTapSaveButton(in: self, withImage: image, originalUrl: url)
    }
  }
}
