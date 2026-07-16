//
//  EditProfileViewController.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 16.07.2026.
//

import UIKit
import Combine
import PhotosUI

final class EditProfileViewController: UIViewController {
        //MARK: - Properties
        private let editProfileView = EditProfileView()
        private let viewModel: EditProfileViewModel
        private var cancellables = Set<AnyCancellable>()

        var onProfileSaved: (() -> Void)?

        //MARK: - Initialization
        init(viewModel: EditProfileViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError()
        }

        //MARK: - Lifecycle
        override func loadView() {
            view = editProfileView
        }

        override func viewDidLoad() {
            super.viewDidLoad()

            title = "Edit Profile"

            setupNavigation()
            setupActions()
            bindViewModel()
            viewModel.loadProfile()
        }
}

private extension EditProfileViewController {
    func setupNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(didTapCancel)
        )
    }

    func setupActions() {
        editProfileView.onChangePhotoTapped = { [weak self] in
            self?.presentPhotoPicker()
        }

        editProfileView.onSaveTapped = { [weak self] name in
            self?.viewModel.save(name: name)
            self?.onProfileSaved?()
            self?.dismiss(animated: true)
        }
    }

    func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.editProfileView.configure(with: state)
            }
            .store(in: &cancellables)
    }

    @objc func didTapCancel() {
        dismiss(animated: true)
    }
}

//MARK: - Photo Picker
private extension EditProfileViewController {
    func presentPhotoPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self

        present(picker, animated: true)
    }
}

extension EditProfileViewController: PHPickerViewControllerDelegate {
    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else {
            return
        }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else {
                return
            }

            let preparedImage = image.preparedAvatarImage()
            let data = preparedImage.jpegData(compressionQuality: 0.8)

            DispatchQueue.main.async {
                self?.viewModel.updateSelectedAvatarData(data)
            }
        }
    }
}

private extension UIImage {
    func preparedAvatarImage(size: CGFloat = 512) -> UIImage {
        let normalizedImage = normalized()
        let originalSize = normalizedImage.size
        let sideLength = min(originalSize.width, originalSize.height)

        let cropRect = CGRect(
            x: (originalSize.width - sideLength) / 2,
            y: (originalSize.height - sideLength) / 2,
            width: sideLength,
            height: sideLength
        )

        guard let cgImage = normalizedImage.cgImage?.cropping(to: cropRect) else {
            return normalizedImage
        }

        let croppedImage = UIImage(cgImage: cgImage)

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))

        return renderer.image { _ in
            croppedImage.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
        }
    }

    func normalized() -> UIImage {
        if imageOrientation == .up {
            return self
        }

        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
