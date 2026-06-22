//
//  HabitCardCell.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 30.05.2026.
//

import UIKit
import SnapKit

final class HabitCardCell: UITableViewCell {
    static let reuseIdentifier = "HabitCardCell"
    
    private let cardView = HabitCardView()
    
    var onDoneTapped: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onDoneTapped = nil
        cardView.onDoneTapped = nil
    }
    
    func configure(with model: HabitCardModel) {
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
            self?.onDoneTapped?()
        }
    }
    private func setupView(){
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        backgroundView = UIView()
        backgroundView?.backgroundColor = .clear
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .clear
        contentView.addSubview(cardView)
    }
    
    private func setupConstraints(){
        cardView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
    }
}
