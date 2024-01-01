//
//  ConverterScreenView.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 31/12/2023.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ConverterScreenView: UIView {
    let ovalLayeredView = UIView()
    
    let disposeBag = DisposeBag()
    
    //MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        subscribeToOrientationDidChangeNotification()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Delegate
    
    // MARK: Subview setup
    func setUpOvalLayeredView() {
        ovalLayeredView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        var outerRect: CGRect = CGRect()
        var middleRect: CGRect = CGRect()
        var innerRect: CGRect = CGRect()
        
        if UIDevice.current.orientation.isPortrait {
            width = min(bounds.width, bounds.height) / 1.3
            height = max(bounds.width, bounds.height) / 12
            
            outerRect = CGRect(x: -(width * 0.4), y: -(height * 4.5), width: width + (width * 0.9), height: height + (height * 6))
            middleRect = CGRect(x: -(width * 0.3),y: -(height * 3.1), width: width + (width * 0.55), height: height + (height * 4))
            innerRect = CGRect(x: -(width * 0.3), y: -(height * 2.9), width: width + (width * 0.37), height: height + (height * 3.7))
        } else {
            width = max(bounds.width, bounds.height) / 1.3
            height = min(bounds.width, bounds.height) / 12
            
            outerRect = CGRect(x: -(width * 0.18), y: -(height * 10), width: width + (width * 0.6), height: height + (height * 12))
            middleRect = CGRect(x: -(width * 0.13), y: -(height * 6.85), width: width + (width * 0.4), height: height + (height * 7.5))
            innerRect = CGRect(x: -(width * 0.11), y: -(height * 5.15), width: width + (width * 0.2), height: height + (height * 5.5))
        }
        
        let outerLayer = createOvalLayer(in: outerRect, fillColor: UIColor.dodgerBlue)
        let middleLayer = createOvalLayer(in: middleRect, fillColor: UIColor.cornflowerBlue)
        let innerLayer = createOvalLayer(in: innerRect, fillColor: UIColor.steelBlue)
        
        ovalLayeredView.layer.addSublayer(outerLayer)
        outerLayer.addSublayer(middleLayer)
        middleLayer.addSublayer(innerLayer)
    }
    
    func createOvalLayer(in rect: CGRect, fillColor: UIColor) -> CAShapeLayer {
        let path = UIBezierPath(ovalIn: rect)
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = fillColor.cgColor
        return layer
    }
    
    private func subscribeToOrientationDidChangeNotification() {
        NotificationCenter.default.rx
            .notification(UIDevice.orientationDidChangeNotification)
            .subscribe(onNext: { _ in
                self.setUpOvalLayeredView()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Constraints
    
    private func addConstraints() {
        addSubview(ovalLayeredView)
        ovalLayeredView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(64)
            make.leading.equalToSuperview().offset(16)
        }
    }
}
