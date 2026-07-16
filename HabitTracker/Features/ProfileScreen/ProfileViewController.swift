//
//  ProfileViewController.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 10.07.2026.
//

import UIKit
import Combine

final class ProfileViewController: UIViewController {
    private let profileView = ProfileView()
    private let viewModel: ProfileViewModel
    private var cancellables = Set<AnyCancellable>()

    //MARK: - Initialization
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    //MARK: - Lifecycle
    override func loadView() {
        view = profileView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        setupActions()
        viewModel.loadProfile()
    }
}

private extension ProfileViewController {
    func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.profileView.configure(with: state)
            }
            .store(in: &cancellables)
    }

    func setupActions() {
        profileView.onEditProfileTapped = { [weak self] in
            self?.showEditProfileAlert()
        }
    }

    func showEditProfileAlert() {
        let alertController = UIAlertController(
            title: "Edit profile",
            message: "Enter the name you want to show in the app.",
            preferredStyle: .alert
        )

        alertController.addTextField { [weak self] textField in
            textField.text = self?.viewModel.state.userName
            textField.placeholder = "Name"
            textField.clearButtonMode = .whileEditing
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alertController] _ in
            let name = alertController?.textFields?.first?.text ?? ""
            self?.viewModel.updateUserName(name)
        })

        present(alertController, animated: true)
    }
}
