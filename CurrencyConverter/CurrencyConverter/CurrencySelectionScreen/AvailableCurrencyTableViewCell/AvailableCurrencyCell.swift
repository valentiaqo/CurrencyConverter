//
//  AvailableCurrencyCell.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 23/01/2024.
//

import UIKit
import SnapKit
import RxSwift

final class AvailableCurrencyCell: UITableViewCell {
    static let reuseIdentifier = "AvailableCurrencyCell"
    
    let currencyNameLabel = UILabel()
    
    private let disposeBag = DisposeBag()
    
    weak var viewModel: AvailableCurrencyCellViewModelType? {
        didSet {
            subscribeToCurrency()
        }
    }
    
    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpCurrencyNameLabel()
        addConstarints()
        subscribeToCurrency()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Subscriptions
    private func subscribeToCurrency() {
        viewModel?.currency
            .subscribe(onNext: { currency in
                self.currencyNameLabel.text = currency.code + CharacterConstants.whitespace + CharacterConstants.minusSign + CharacterConstants.whitespace + NSLocalizedString(currency.code, comment: "Localizable currency")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Subviews' setup
    
    private func setUpCurrencyNameLabel() {
        currencyNameLabel.font = UIFont(name: Fonts.Inter.regular.rawValue, size: 15)
        currencyNameLabel.textColor = .black
    }
    
    //MARK: - Constraints
    private func addConstarints() {
        addSubview(currencyNameLabel)
        
        currencyNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
    }
}
