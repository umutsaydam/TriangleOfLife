//
//  ViewController.swift
//  TriangleOfLife
//
//  Created by Yunus Emre Berdibek on 8.03.2024.
//

import UIKit

final class ViewController: UIViewController {
    private let chooseImageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .tinted()
        button.configuration?.title = "Choose an Image."
        button.configuration?.baseBackgroundColor = .magenta
        button.configuration?.baseForegroundColor = .magenta
        return button
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = 8
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        prepareImageView()
        prepareChooseImageButton()
    }

    private func prepareImageView() {
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 4),
            imageView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 2),
            imageView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }

    private func prepareChooseImageButton() {
        view.addSubview(chooseImageButton)
        chooseImageButton.addTarget(self, action: #selector(showImagePickerOptions), for: .touchUpInside)

        NSLayoutConstraint.activate([
            chooseImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            chooseImageButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 24),
            chooseImageButton.widthAnchor.constraint(equalToConstant: 250),
            chooseImageButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

extension ViewController {
    func addImagePicker(sourceType: UIImagePickerController.SourceType) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        return picker
    }

    @objc func showImagePickerOptions() {
        let alertVC = UIAlertController(title: "Pick a photo", message: "Choose a picture from Library or Camera.", preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            guard let self else { return }
            let cameraPicker = self.addImagePicker(sourceType: .camera)

            self.present(cameraPicker, animated: true)
        }

        let libraryAction = UIAlertAction(title: "Library", style: .default) { [weak self] _ in
            guard let self else { return }
            let libraryPicker = self.addImagePicker(sourceType: .photoLibrary)

            self.present(libraryPicker, animated: true)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertVC.addAction(cameraAction)
        alertVC.addAction(libraryAction)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true)
    }
}

extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        imageView.image = image
        dismiss(animated: true)
    }
}
