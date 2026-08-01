//
//  HabitDetailsCalendarDayCell.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 18.06.2026.
//
import UIKit
import SnapKit

struct HabitDetailsCalendarDayCellModel {
    let date: Date?
    let dayNumber: Int?
    let state: HabitCalendarDayState?
}

final class HabitDetailsCalendarDayCell: UICollectionViewCell {
    // Индентификатор нужен для переиспользования ячейки
    static let reuseIdentifier = "HabitDetailsCalendarDayCell"
    
    private let dayLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupLabel()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // Так как коллекция переиспользует ячейки,то мы сбрасываем старое состояние перед новым configure
    override func prepareForReuse() {
        super.prepareForReuse()
        
        dayLabel.text = nil
        dayLabel.isHidden = false
        contentView.backgroundColor = .appBackground
    }
    
    // Публичный метод ячейки для каждого дня
    func configure(with model: HabitDetailsCalendarDayCellModel) {
        guard let dayNumber = model.dayNumber,
                let state = model.state else {
            dayLabel.isHidden = true
            contentView.backgroundColor = .clear
            return
        }
        
        dayLabel.text = String(dayNumber)
        
        switch state {
            case .completed: contentView.backgroundColor = .appOrange
            case .missed: contentView.backgroundColor = .lastDaysGray
            case .future: contentView.backgroundColor = .nextDaysGray
        }
    }
}

private extension HabitDetailsCalendarDayCell {
    func setupView() {
        contentView.layer.cornerRadius = 4
        contentView.clipsToBounds = true
    }
    
    func setupLabel() {
        dayLabel.font = UIFont(name: "Montserrat-SemiBold", size: 11)
        dayLabel.textColor = .label
        dayLabel.textAlignment = .center
        
        contentView.addSubview(dayLabel)
    }
    
    func setupConstraints() {
        dayLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
