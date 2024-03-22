//
//  HomeView.swift
//  TriangleOfLife
//
//  Created by Yunus Emre Berdibek on 22.03.2024.
//

import CoreML
import UIKit
import Vision

/*
 Yukarıda calc object, calc deph diye  buton eklenebilir.
 */

final class HomeView: UIView {
    let scrollView: UIScrollView = .init()
    let containerView: UIView = .init()
    let stackView: UIStackView = .init()

    let objectImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let toLResponseImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let fcrnResponseImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let fcrnResponseView: DrawingView = {
        let view = DrawingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleToFill
        view.backgroundColor = .lightGray
        view.autoresizesSubviews = true
        view.clearsContextBeforeDrawing = true
        view.isOpaque = true
        view.isHidden = true
        view.alpha = 0
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareScrollView()
//        prepareStackView()
        prepareImages()
//        prepareFCRNView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    private func prepareScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.bouncesVertically = true
        scrollView.bouncesHorizontally = false
        scrollView.backgroundColor = .systemBackground
        addSubview(scrollView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(
                equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(
                equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(
                equalTo: bottomAnchor),
            scrollView.widthAnchor.constraint(equalTo: widthAnchor),

            containerView.topAnchor.constraint(
                equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(
                equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(
                equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(
                equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(
                equalTo: scrollView.widthAnchor)
        ])
    }

//    private func prepareStackView() {
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.axis = .vertical
//        stackView.spacing = 8
//        stackView.backgroundColor = .systemBackground
//        containerView.addSubview(stackView)
//        stackView.addArrangedSubview(objectImageView)
//        stackView.addArrangedSubview(toLResponseImageView)
//
//        NSLayoutConstraint.activate([
//            stackView.topAnchor.constraint(
//                equalTo: containerView.topAnchor),
//            stackView.leadingAnchor.constraint(
//                equalTo: containerView.leadingAnchor),
//            stackView.trailingAnchor.constraint(
//                equalTo: containerView.trailingAnchor),
//            stackView.widthAnchor.constraint(
//                equalTo: containerView.widthAnchor),
//            stackView.heightAnchor.constraint(
//                equalTo: containerView.heightAnchor, multiplier: 0.66)
//        ])
//    }

    private func prepareImages() {
        containerView.addSubview(objectImageView)
        containerView.addSubview(toLResponseImageView)
        containerView.addSubview(fcrnResponseImageView)

        NSLayoutConstraint.activate([
            objectImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            objectImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            objectImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            objectImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1),
            objectImageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.3),

            toLResponseImageView.topAnchor.constraint(equalTo: objectImageView.bottomAnchor, constant: 16),
            toLResponseImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            toLResponseImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            toLResponseImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1),
            toLResponseImageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.3),
            
            fcrnResponseImageView.topAnchor.constraint(equalTo: toLResponseImageView.bottomAnchor, constant: 16),
            fcrnResponseImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            fcrnResponseImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            fcrnResponseImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1),
            fcrnResponseImageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.3),
        ])
    }

//    private func prepareFCRNView() {
//        // İlk olarak isHidden. Daha sonradan isHidden = false
//        containerView.addSubview(fcrnResponseView)
//
//        NSLayoutConstraint.activate([
//            fcrnResponseView.topAnchor.constraint(
//                equalTo: toLResponseImageView.bottomAnchor,
//                constant: 16),
//            fcrnResponseView.leadingAnchor.constraint(
//                equalTo: containerView.leadingAnchor),
//            fcrnResponseView.trailingAnchor.constraint(
//                equalTo: containerView.trailingAnchor),
//            fcrnResponseView.widthAnchor.constraint(
//                equalTo: containerView.widthAnchor),
//            fcrnResponseView.heightAnchor.constraint(
//                equalTo: containerView.heightAnchor, multiplier: 0.3)
//        ])
//    }
}

extension HomeView {
//    public func configure(with heatmap: [[Double]]?) {
//        UIView.animate(withDuration: 0.2) {
//            self.fcrnResponseView.isHidden = false
//            self.fcrnResponseView.alpha = 1
//            self.fcrnResponseView.heatmap = heatmap
//        }
//    }
}
