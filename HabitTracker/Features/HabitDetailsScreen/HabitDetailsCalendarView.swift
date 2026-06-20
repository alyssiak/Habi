//
//  HabitDetailsCalendarView.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 17.06.2026.
//

import UIKit
import SnapKit

final class HabitDetailsCalendarView: UIView {
    private let headerStackView = UIStackView()
    private let previousMonthButton = UIButton()
    private let nextMonthButton = UIButton()
    private let monthLabel = UILabel()
    private let yearLabel = UILabel()

    private let collectionView: UICollectionView
    private var days: [HabitDetailsCalendarDayCellModel] = []
    
    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: frame)

        setupView()
        setupHeader()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(month: String, year: String, days: [HabitDetailsCalendarDayCellModel]) {
        monthLabel.text = month
        yearLabel.text = year
        self.days = days
        collectionView.reloadData()
    }
}

private extension HabitDetailsCalendarView {
    //MARK: - Setup views
    func setupView() {
        backgroundColor = .appGray
        layer.borderWidth = 1
        layer.cornerRadius = 8
        layer.borderColor = UIColor.systemGray5.cgColor
        
        collectionView.register(HabitDetailsCalendarDayCell.self, forCellWithReuseIdentifier: HabitDetailsCalendarDayCell.reuseIdentifier)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
    }

    func setupHeader() {
        previousMonthButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        nextMonthButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)

        monthLabel.font = UIFont(name: "Montserrat-SemiBold", size: 18)
        monthLabel.textColor = .label

        yearLabel.font = UIFont(name: "Montserrat-Medium", size: 14)
        yearLabel.textColor = .secondaryLabel
        yearLabel.textAlignment = .center

        headerStackView.axis = .horizontal
        headerStackView.alignment = .center
        headerStackView.spacing = 16

        headerStackView.addArrangedSubview(previousMonthButton)
        headerStackView.addArrangedSubview(monthLabel)
        headerStackView.addArrangedSubview(nextMonthButton)

        addSubview(headerStackView)
        addSubview(yearLabel)
    }

    func setupConstraints() {
        headerStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
        }

        yearLabel.snp.makeConstraints { make in
            make.top.equalTo(headerStackView.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(yearLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
}

extension HabitDetailsCalendarView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HabitDetailsCalendarDayCell.reuseIdentifier, for: indexPath) as? HabitDetailsCalendarDayCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: days[indexPath.item])
        return cell
    }
}

extension HabitDetailsCalendarView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 8
        let columns: CGFloat = 7
        let totalSpacing = spacing * (columns - 1)
        let avaliableWidth = collectionView.bounds.width - totalSpacing
        let cellWidth = floor(avaliableWidth / columns)
        
        return CGSize(width: cellWidth, height: 28)
    }
}
