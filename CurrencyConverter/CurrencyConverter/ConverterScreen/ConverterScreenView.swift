//
//  ConverterScreenView.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 31/12/2023.
//

import UIKit
import SnapKit

final class ConverterScreenView: UIView {
    let scrollView = ScrollView()
    
    let ovalLayeredView = UIView()
    let titleLabel = UILabel()
    let converterView = ConverterView()
    
    let lastUpdateLabel = UILabel()
    let updateTimeLabel = UILabel()
    let lastTimeUpdatedVStack = UIStackView()
    
    //MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .cloudWhite
        setUpScrollView()
        addSubviews()
        addConstraints()
        setUpTitlelabel()
        setUpUpdateLabels()
        setUpLastTimeUpdatedVStack()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        setUpOvalLayeredView()
    }
    
    // MARK: - Subviews' setup
    private func setUpScrollView() {
        scrollView.delaysContentTouches = false
        scrollView.showsVerticalScrollIndicator = false
    }
    
    private func setUpOvalLayeredView() {
        ovalLayeredView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let width = bounds.width / 1.3
        let height = bounds.height / 12
        var outerRect: CGRect = CGRect()
        var middleRect: CGRect = CGRect()
        var innerRect: CGRect = CGRect()
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.compact, .regular), (.regular, .regular):
            outerRect = CGRect(x: -(width * 0.4), y: -(height * 4.5), width: width + (width * 0.9), height: height + (height * 6))
            middleRect = CGRect(x: -(width * 0.3),y: -(height * 3.1), width: width + (width * 0.55), height: height + (height * 4))
            innerRect = CGRect(x: -(width * 0.3), y: -(height * 2.9), width: width + (width * 0.37), height: height + (height * 3.7))
        case (.regular, .compact), (.compact, .compact):
            outerRect = CGRect(x: -(width * 0.18), y: -(height * 10), width: width + (width * 0.6), height: height + (height * 12))
            middleRect = CGRect(x: -(width * 0.13), y: -(height * 6.85), width: width + (width * 0.4), height: height + (height * 8))
            innerRect = CGRect(x: -(width * 0.11), y: -(height * 5.15), width: width + (width * 0.2), height: height + (height * 5.9))
        default: break
        }
        
        let outerLayer = createOvalLayer(in: outerRect, fillColor: UIColor.dodgerBlue)
        let middleLayer = createOvalLayer(in: middleRect, fillColor: UIColor.cornflowerBlue)
        let innerLayer = createOvalLayer(in: innerRect, fillColor: UIColor.steelBlue)
        
        ovalLayeredView.layer.addSublayer(outerLayer)
        outerLayer.addSublayer(middleLayer)
        middleLayer.addSublayer(innerLayer)
    }
    
    private func createOvalLayer(in rect: CGRect, fillColor: UIColor) -> CAShapeLayer {
        let path = UIBezierPath(ovalIn: rect)
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = fillColor.cgColor
        return layer
    }
    
    private func setUpTitlelabel() {
        titleLabel.text = "Currency Converter"
        titleLabel.font = UIFont(name: Fonts.Inter.bold.rawValue , size: 26)
        titleLabel.textColor = .white
    }
    
    private func setUpUpdateLabels() {
        // lastUpdatedLabel
        lastUpdateLabel.text = "Last updated"
        
        // updateTimeLabel
        // TO BE CHANGED
        // ---------------------------------------------
        updateTimeLabel.text = "06 Jan 2024 11:00 PM"
        // ---------------------------------------------
        
        // lastUpdatedLabel and updateTimeLabel
        [lastUpdateLabel, updateTimeLabel].forEach { label in
            label.font = UIFont(name: Fonts.Inter.regular.rawValue , size: 15)
            label.textColor = UIColor.matterhorn
            label.numberOfLines = 1
        }
    }
    
    private func setUpLastTimeUpdatedVStack() {
        lastTimeUpdatedVStack.addArrangedSubview(lastUpdateLabel)
        lastTimeUpdatedVStack.addArrangedSubview(updateTimeLabel)
        
        lastTimeUpdatedVStack.axis = .vertical
        lastTimeUpdatedVStack.distribution = .fillEqually
        lastTimeUpdatedVStack.spacing = 0
    }
        
    // MARK: - Constraints
    private func addSubviews() {
        insertSubview(ovalLayeredView, at: 0)
        addSubview(scrollView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(converterView)
        scrollView.addSubview(lastTimeUpdatedVStack)
    }
    
    private func addConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
        scrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.leading.top.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(lastTimeUpdatedVStack.snp.bottom).offset(8)
        }
        
        scrollView.frameLayoutGuide.snp.makeConstraints { make in
            make.width.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(scrollView)
        }
        
        
        // ovalLayeredView
        ovalLayeredView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(64)
            make.leading.equalToSuperview().offset(16)
        }
        
        // titleLabel
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(32)
        }
        
        // containerView
        converterView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16).priority(999)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(48).priority(999)
            
            make.width.lessThanOrEqualTo(550)
            make.height.lessThanOrEqualTo(400)
        }
        
        // lastTimeUpdatedVStack
        lastTimeUpdatedVStack.snp.makeConstraints { make in
            make.top.equalTo(converterView.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(32)
            
            make.width.equalTo(190)
        }
        
        // lastUpdateLabel
        lastUpdateLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
    }
}
