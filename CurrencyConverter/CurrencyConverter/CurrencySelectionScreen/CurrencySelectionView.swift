//
//  CurrencySelectionView.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 23/01/2024.
//

import UIKit

final class CurrencySelectionView: UIView {
    let availableCurrenciesTableView = UITableView(frame: .zero, style: .insetGrouped)
    let noResultsView = NoResultsView()
    
    //MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = availableCurrenciesTableView.backgroundColor
        setUpAvailableCurrenciesTableView()
        addSubviews()
        addConstraints()
        noResultsView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Subviews' setup
    private func setUpAvailableCurrenciesTableView() {
        availableCurrenciesTableView.register(AvailableCurrencyCell.self, forCellReuseIdentifier: AvailableCurrencyCell.reuseIdentifier)
        availableCurrenciesTableView.showsVerticalScrollIndicator = false
        availableCurrenciesTableView.rowHeight = 50
        availableCurrenciesTableView.sectionHeaderHeight = 20
    }
    
    // MARK: - Constraints
    private func addSubviews() {
        addSubview(availableCurrenciesTableView)
        addSubview(noResultsView)
    }
    
    private func addConstraints() {
        // availableCurrenciesTableView
        availableCurrenciesTableView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        // noResultsView
        noResultsView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(200)
        }
    }
}
