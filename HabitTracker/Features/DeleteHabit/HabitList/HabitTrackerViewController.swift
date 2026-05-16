//
//  ViewController.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 30.04.2026.
//

import UIKit

final class HabitTrackerViewController: UIViewController {

    private let avatarImageView = UIImageView()
    private let greetingLabel = UILabel()
    private let motivationLabel = UILabel()
    private let addHabitButton = UIButton()
    private let headerStackView = UIStackView()
    private let textStackView = UIStackView()
    private let habitsStackView = UIStackView()
    private let viewModel: HabitTrackerViewModel

    init(viewModel: HabitTrackerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupHeader()
        setupHabitsStackView()
        setupConstraints()
        bindViewModel()
        viewModel.loadHabits()
    }
  
    private func setupView() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupHeader() {
        avatarImageView.image = UIImage(systemName: "person.circle")
        avatarImageView.tintColor = .systemGray
        avatarImageView.contentMode = .scaleAspectFit
        
        greetingLabel.text = "Hello!"
        greetingLabel.font = UIFont(name: "Montserrat-SemiBold", size: 24)
        
        motivationLabel.text = "Track your habits to stay motivated."
        motivationLabel.textColor = .secondaryLabel
        motivationLabel.font =  UIFont(name: "Montserrat-Regular", size: 18)
        motivationLabel.numberOfLines = 0
        
        addHabitButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addHabitButton.backgroundColor = .systemOrange
        addHabitButton.tintColor = .white
        addHabitButton.layer.cornerRadius = 8
        addHabitButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        addHabitButton.translatesAutoresizingMaskIntoConstraints = false
        
        textStackView.axis = .vertical
        textStackView.spacing = 6
        textStackView.addArrangedSubview(greetingLabel)
        textStackView.addArrangedSubview(motivationLabel)
        
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        headerStackView.axis = .horizontal
        headerStackView.spacing = 16
        headerStackView.alignment = .center
        headerStackView.addArrangedSubview(avatarImageView)
        headerStackView.addArrangedSubview(textStackView)
        view.addSubview(headerStackView)
        view.addSubview(addHabitButton)
    }
    
    private func setupHabitsStackView() {
        habitsStackView.translatesAutoresizingMaskIntoConstraints = false
        habitsStackView.axis = .vertical
        habitsStackView.spacing = 12
        view.addSubview(habitsStackView)
    }
    
    // подписываем контроллер на обновления
    private func bindViewModel() {
        viewModel.onHabitsChanged = { [weak self] models in
            self?.renderHabits(models)
        }
    }
    
    private func renderHabits(_ models: [HabitCardModel]) {
        habitsStackView.arrangedSubviews.forEach { view in
            view.removeFromSuperview()
        }
        
        models.forEach { model in
            let cardView = HabitCardView()
            
            cardView.configure(
                title: model.title,
                isDoneToday: model.isDoneToday,
                emoji: model.emoji,
                completedDays: model.completedDays,
                totalDays: model.totalDays,
                color: model.colorHex,
                days: model.days,
                streak: model.streak
            )
            
            cardView.onDoneTapped = { [weak self] in
                self?.viewModel.toggleToday(for: model.id)
        }
            habitsStackView.addArrangedSubview(cardView)
     }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 56),
            avatarImageView.heightAnchor.constraint(equalToConstant: 56),
            
            headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            habitsStackView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 32),
            habitsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            addHabitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addHabitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addHabitButton.heightAnchor.constraint(equalToConstant: 56),
            addHabitButton.widthAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    @objc private func didTapAddButton() {
        let addHabitViewController = AddHabitViewController(viewModel: viewModel)
        addHabitViewController.onHabitAdded = { [weak self] in
            self?.viewModel.loadHabits()
        }
        present(addHabitViewController, animated: true)
    }
}

