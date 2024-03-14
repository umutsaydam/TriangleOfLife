//
//  ViewController.swift
//  TriangleOfLife
//
//  Created by Yunus Emre Berdibek on 8.03.2024.
//

import CoreML
import ImageIO
import UIKit
import Vision

final class ViewController: UIViewController {
    lazy var detectionRequest: VNCoreMLRequest = {
        do {
            let model: VNCoreMLModel = try .init(for: TriangleOfLife_1().model)
            let request: VNCoreMLRequest = .init(model: model) { [weak self] request, error in
                self?.processDetections(for: request, error: error)
            }

            request.imageCropAndScaleOption = .scaleFit
            return request
        } catch {
            fatalError()
        }
    }()

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

    private func updateDetections(for image: UIImage) {
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }

        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation!)
            do {
                try handler.perform([self.detectionRequest])
            } catch {
                print("Failed to perform detection.\n\(error.localizedDescription)")
            }
        }
    }

    private func processDetections(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                print("Unable to detect anything.\n\(error!.localizedDescription)")
                return
            }

            let detections = results as! [VNRecognizedObjectObservation]
            self.drawDetectionsOnPreview(detections: detections)
        }
    }
}

extension ViewController {
    func drawDetectionsOnPreview(detections: [VNRecognizedObjectObservation]) {
        guard let image = imageView.image else { return }
        let imageSize = image.size
        let scale: CGFloat = 0

        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        image.draw(at: .zero)

        for detection in detections {
            // Tespitin etiketlerini ve güven değerlerini al

            let (highestConfidence, highestConfidenceLabel) = detection.labels.reduce((0, "")) { result, label in
                label.confidence > result.0 ? (label.confidence, label.identifier) : result
            }

            // Tespitin sınırlayıcı kutusunu hesapla
            let boundingBox = detection.boundingBox
            let rectangle = CGRect(x: boundingBox.minX * image.size.width, y: (1 - boundingBox.minY - boundingBox.height) * image.size.height, width: boundingBox.width * image.size.width, height: boundingBox.height * image.size.height)

            // Çerçeve içine etiketi çiz
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24),
                .foregroundColor: UIColor.secondaryLabel
            ]
            let attributedString = NSAttributedString(string: highestConfidenceLabel + " " + highestConfidence.description, attributes: attributes)
            attributedString.draw(at: CGPoint(x: rectangle.minX, y: rectangle.minY))

            // Çerçeve çiz
            UIColor(red: 0, green: 1, blue: 0, alpha: 0.3).setFill()
            UIRectFillUsingBlendMode(rectangle, CGBlendMode.normal)
        }
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        imageView.image = newImage
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
        updateDetections(for: image)
        dismiss(animated: true)
    }
}
