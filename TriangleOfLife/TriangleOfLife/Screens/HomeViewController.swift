//
//  HomeViewController.swift
//  TriangleOfLife
//
//  Created by Yunus Emre Berdibek on 21.03.2024.
//

import UIKit
import Vision

struct DetectedObject {
    let id: String
    let label: String
    let rectangle: CGRect
}

enum InputStatus {
    case image
    case object
    case deph
}

final class HomeViewController: UIViewController {
    var inputStatus: InputStatus = .image
    var detectedObjects: [DetectedObject] = []

    private lazy var homeView: HomeView = .init()

    lazy var toLRequest: VNCoreMLRequest = {
        let config = MLModelConfiguration()
        config.computeUnits = .all

        guard let toLModel = try? MLModel(contentsOf: BedDetector_1.urlOfModelInThisBundle, configuration: config) else {
            fatalError("Unable to load model.")
        }

        guard let model = try? VNCoreMLModel(for: toLModel) else {
            fatalError("Unable to load model.")
        }

        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results,
                  let detections = results as? [VNRecognizedObjectObservation]
            else {
                fatalError("Unable to detect anything. \(error?.localizedDescription ?? "")")
            }

            DispatchQueue.main.async {
                self?.drawToLDetections(detections: detections)
            }
        }

        request.imageCropAndScaleOption = .scaleFill
        return request
    }()

    lazy var fcrnRequest: VNCoreMLRequest = {
        let config = MLModelConfiguration()
        config.computeUnits = .all

        guard let toLModel = try? MLModel(contentsOf: FCRN.urlOfModelInThisBundle, configuration: config) else {
            fatalError("Unable to load model.")
        }

        guard let model = try? VNCoreMLModel(for: toLModel) else {
            fatalError("Unable to load model.")
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            guard error == nil,
                  let results = request.results as? [VNCoreMLFeatureValueObservation],
                  let heatmap = results.first?.featureValue.multiArrayValue
            else {
                fatalError("Unable to detect anything. \(error?.localizedDescription ?? "")")
            }

            let start = CFAbsoluteTimeGetCurrent()
            let (convertedHeadmap, convertedHeadmapInt) = self.convertTo2DArray(from: heatmap)
            let diff = CFAbsoluteTimeGetCurrent() - start
            print("Convertion to 2D Took \(diff) seconds")

            DispatchQueue.main.async { [weak self] in
//                self?.homeView.configure(with: convertedHeadmap)
                self?.drawFCRNDetections(heatmap: convertedHeadmap)
                let start = CFAbsoluteTimeGetCurrent()
                let average = Float32(convertedHeadmapInt.joined().reduce(0, +)) / Float32(20480)
                let diff = CFAbsoluteTimeGetCurrent() - start
                print("Average Took \(diff) seconds")

                print(average)
                if average > 0.35 {
                    self?.haptic()
                }
            }
        }

        request.imageCropAndScaleOption = .scaleFill
        return request
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }

    private func prepareUI() {
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(clearInput))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextInput)),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showImagePickerOptions)),
        ]
        prepareHomeView()
    }

    private func prepareHomeView() {
        homeView.translatesAutoresizingMaskIntoConstraints = false
        homeView.backgroundColor = .systemBackground
        view.addSubview(homeView)

        NSLayoutConstraint.activate([
            homeView.topAnchor.constraint(
                equalTo: view.topAnchor),
            homeView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            homeView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
            homeView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor),
        ])
    }
}

extension HomeViewController {
    private func haptic() {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
    }

    private func addImagePicker(sourceType: UIImagePickerController.SourceType) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        return picker
    }

    @objc private func showImagePickerOptions() {
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

    @objc private func clearInput() {
        inputStatus = .image
        detectedObjects.removeAll()
        homeView.objectImageView.image = nil
        homeView.toLResponseImageView.image = nil
        homeView.fcrnResponseImageView.image = nil
    }

    @objc private func nextInput() {
        switch inputStatus {
        case .image:
            break
        case .object:
            guard let image = homeView.objectImageView.image else { return }
            updateToLDetections(for: image)
            inputStatus = .deph
        case .deph:
            guard let image = homeView.objectImageView.image,
                  let cgImage = image.cgImage else { return }
            updateFCRNDetections(cgImage: cgImage)
            inputStatus = .image
        }
    }
}

// Hesaplama işlemi sırayla olmalı.
extension HomeViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage
        else {
            return
        }

        homeView.objectImageView.image = image
        inputStatus = .object
        dismiss(animated: true)
    }
}

extension HomeViewController {
    func updateToLDetections(for image: UIImage) {
        let orientation = CGImagePropertyOrientation(
            rawValue: UInt32(image.imageOrientation.rawValue))

        guard let ciImage = CIImage(image: image) else {
            fatalError("Unable to create \(CIImage.self) from \(image).")
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation!)
            do {
                try handler.perform([self.toLRequest])
            } catch {
                print("Failed to perform detection.\n\(error.localizedDescription)")
            }
        }
    }

    func drawToLDetections(detections: [VNRecognizedObjectObservation]) {
        guard let image = homeView.objectImageView.image else { return }

        let imageSize = image.size
        let scale: CGFloat = 0

        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        image.draw(at: .zero)

        for detection in detections {
            let (highestConfidence, highestConfidenceLabel) = detection.labels.reduce((0, "")) { result, label in
                label.confidence > result.0 ? (label.confidence, label.identifier) : result
            }

            // Tespitin sınırlayıcı kutusunu hesapla
            let boundingBox = detection.boundingBox
            let imageWidth = image.size.width * 0.95
            let imageHeight = image.size.height * 1.0

            let rectangle = CGRect(x: boundingBox.minX * imageWidth, y: (1 - boundingBox.minY - boundingBox.height) * imageHeight, width: boundingBox.width * imageWidth, height: boundingBox.height * imageHeight)

//            // Çerçeve içine etiketi çiz
//            let attributes: [NSAttributedString.Key: Any] = [
//                .font: UIFont.systemFont(ofSize: 100),
//                .foregroundColor: UIColor.black,
//            ]

//            let attributedString = NSAttributedString(string: highestConfidenceLabel + " " + highestConfidence.description, attributes: attributes)
//            attributedString.draw(at: CGPoint(x: rectangle.minX, y: rectangle.minY))

            detectedObjects.append(
                .init(id: detection.uuid.uuidString,
                      label: "\(highestConfidenceLabel)" + highestConfidence.description,
                      rectangle: rectangle))

            UIColor(red: 0, green: 1, blue: 0, alpha: 0.2).setFill()
            UIRectFillUsingBlendMode(rectangle, CGBlendMode.normal)
        }

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        homeView.toLResponseImageView.image = newImage
    }

    // MARK: - DRAW FCRN BIT BY BIT

    private func drawFCRNDetections(heatmap: [[Double]]?) {
        guard let heatmap = heatmap, let image = homeView.objectImageView.image else {
            return
        }

        // Resim boyutunu ve çizim bağlamını oluşturun
        let size = image.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard UIGraphicsGetCurrentContext() != nil else {
            return
        }

        // heatmap değerlerine göre resmi çizin
        let heatmap_w = heatmap.count
        let heatmap_h = heatmap.first?.count ?? 0
        let w = size.width / CGFloat(heatmap_w)
        let h = size.height / CGFloat(heatmap_h)

        var detectedObjectColorsSum: [CGFloat] = []

        for object in detectedObjects {
            var objectColorValue: CGFloat = .zero

            for j in 0..<heatmap_h {
                for i in 0..<heatmap_w {
                    let value = heatmap[i][j]
                    var alpha: CGFloat = .init(value)

                    if alpha > 1 {
                        alpha = 1
                    } else if alpha < 0 {
                        alpha = 0
                    }

                    let rect: CGRect = .init(x: CGFloat(i) * w, y: CGFloat(j) * h, width: w, height: h)

                    if rect.intersects(object.rectangle) {
                        let color: UIColor = .init(white: 1 - alpha, alpha: 1)
                        let bpath: UIBezierPath = .init(rect: rect)

                        objectColorValue += 1 - alpha

                        color.set()
                        bpath.fill()
                    }
                }
            }
            print(object.label)
            detectedObjectColorsSum.append(objectColorValue)
        }

        dump(detectedObjectColorsSum)
        // Çizim bağlamını bir UIImage'a dönüştürün
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        homeView.fcrnResponseImageView.image = newImage
    }

    func updateFCRNDetections(cgImage: CGImage) {
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global().async {
            do {
                try handler.perform([self.fcrnRequest])
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    UINavigationController(rootViewController: HomeViewController())
}
