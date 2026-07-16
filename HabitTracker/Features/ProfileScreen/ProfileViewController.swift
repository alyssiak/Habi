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
    private let makeEditProfileViewController: () -> UIViewController
    private var cancellables = Set<AnyCancellable>()

    //MARK: - Initialization
    init(
        viewModel: ProfileViewModel,
        makeEditProfileViewController: @escaping () -> UIViewController
    ) {
        self.viewModel = viewModel
        self.makeEditProfileViewController = makeEditProfileViewController
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
            self?.openEditProfile()
        }
    }

    func openEditProfile() {
        let editProfileViewController = makeEditProfileViewController()
        let navigationController = UINavigationController(rootViewController: editProfileViewController)

        present(navigationController, animated: true)
    }
}
