//
//  StatisticsProgressRingView.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 10.07.2026.
//

import UIKit
import SnapKit

final class StatisticsProgressRingView: UIView {
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let percentLabel = UILabel()
    
    private var progress: Double = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupLayers()
        setupPercentLael()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updatePath()
    }
    
    func render(progress: Double, percentText: String) {
        self.progress = max(0, min(progress, 1))
        percentLabel.text = percentText
        progressLayer.strokeEnd = self.progress
        setNeedsLayout()
    }
    
    private func setupView() {
        backgroundColor = .clear
    }
    
    private func setupLayers() {
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.systemOrange.withAlphaComponent(0.18).cgColor
        trackLayer.lineWidth = 7
        trackLayer.lineCap = .round
        
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.appOrange.cgColor
        progressLayer.lineWidth = 7
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0

        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
    }
    
    private func setupPercentLael() {
        percentLabel.font = UIFont(name: "Montserrat-Bold", size: 22)
        percentLabel.textColor = .label
        percentLabel.textAlignment = .center

        addSubview(percentLabel)

        percentLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func updatePath() {
        let radius = min(bounds.width, bounds.height) / 2 - 8
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 1.5 * .pi,
            clockwise: true
        )
        
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
    }
}
