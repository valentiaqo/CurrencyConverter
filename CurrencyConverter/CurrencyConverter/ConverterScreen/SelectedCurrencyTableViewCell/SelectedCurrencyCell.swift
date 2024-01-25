//
//  SelectedCurrencyCell.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 15/01/2024.
//

import UIKit
import RxSwift
import SnapKit

final class SelectedCurrencyCell: UITableViewCell {
    static let reuseIdentifier = "SelectedCurrencyCell"
    
    let currencyCodeLabel = UILabel()
    let rightChevronImageView = UIImageView()
    let currencyCodeStackView = UIStackView()
    
    let valueTextField = UITextField()
    
    private let disposeBag = DisposeBag()
    
    weak var viewModel: SelectedCurrencyCellViewModelType? {
        didSet {
            subscribeToCurrency()
        }
    }
    
    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.isUserInteractionEnabled = false
        setUpSubviews()
        setUpCurrencyCodeStackView()
        addSubviews()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Subscriptions
    private func subscribeToCurrency() {
        viewModel?.currency
            .subscribe(onNext: { currency in
                self.currencyCodeLabel.text = currency.code
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Subviews' setup
    private func setUpSubviews() {
        // nameLabela
        currencyCodeLabel.textColor = .midnightBlue
        currencyCodeLabel.font = UIFont(name: Fonts.Inter.regular.rawValue, size: 15)
        
        // rightChevronImageView
        rightChevronImageView.image = UIImage(systemName: "chevron.right")
        rightChevronImageView.tintColor = .midnightBlue
        
        // valueTextField
        valueTextField.borderStyle = .roundedRect
        valueTextField.layer.cornerRadius = 10
        valueTextField.backgroundColor = .cloudWhite
    }
    
    private func setUpCurrencyCodeStackView() {
        currencyCodeStackView.addArrangedSubview(currencyCodeLabel)
        currencyCodeStackView.addArrangedSubview(rightChevronImageView)
        
        currencyCodeStackView.axis = .horizontal
        currencyCodeStackView.distribution = .fillProportionally
        currencyCodeStackView.spacing = 0
    }
    
    private func addSubviews() {
        addSubview(currencyCodeStackView)
        addSubview(valueTextField)
    }
    
    private func addConstraints() {
        // currencyCodeStackView
        currencyCodeStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(32)
        }
        
        // currencyCodeLabel
        currencyCodeLabel.snp.makeConstraints { make in
            make.width.equalTo(40)
        }
        
        // rightChevronImageView
        rightChevronImageView.snp.makeConstraints { make in
            make.width.equalTo(15)
        }
        
        // valueTextField
        valueTextField.snp.makeConstraints { make in
            make.leading.equalTo(currencyCodeStackView.snp.trailing).offset(64)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.trailing.equalToSuperview().inset(32)
        }
    }
}
