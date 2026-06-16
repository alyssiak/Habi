//
//  HabitDetailsViewController.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 16.06.2026.
//

import UIKit
import SnapKit

final class HabitDetailsViewController: UIViewController {
    private let habitTitle = UILabel()
    private let habit: HabitCardModel

    init(habit: HabitCardModel) {
        self.habit = habit
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupHeader()
        setupConstrainsts()
    }
    
    func setupView() {
        view.backgroundColor = .systemBackground
    }

    func setupHeader() {
        habitTitle.text = habit.title
        habitTitle.textColor = .label
        habitTitle.font = UIFont(name: "Montserrat-SemiBold", size: 24)
        habitTitle.numberOfLines = 0
        
        view.addSubview(habitTitle)
    }
    
    func setupConstrainsts() {
        habitTitle.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
