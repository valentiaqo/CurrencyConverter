//
//  NoResultsView.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 23/01/2024.
//

import UIKit

final class NoResultsView: UIView {
    let magnifierImageView = UIImageView()
    let noResultLabel = UILabel()
    let tryAgainLabel = UILabel()
    
    // MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpMagnifierImageView()
        setUpNoResultLabel()
        setUpTryAgainLabel()
        addSubviews()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Subviews' setup
    private func setUpMagnifierImageView() {
        magnifierImageView.image = UIImage(systemName: "magnifyingglass")
        magnifierImageView.tintColor = .gray
    }
    
    private func setUpNoResultLabel() {
        noResultLabel.font = UIFont(name: Fonts.Inter.medium.rawValue, size: 18)
        noResultLabel.textColor = .black
        noResultLabel.numberOfLines = 0
        noResultLabel.textAlignment = .center
        noResultLabel.text = "No results for"
    }
    
    private func setUpTryAgainLabel() {
        tryAgainLabel.font = UIFont(name: Fonts.Inter.medium.rawValue, size: 16)
        tryAgainLabel.textColor = .lightGray
        tryAgainLabel.numberOfLines = 1
        tryAgainLabel.textAlignment = .center
        tryAgainLabel.text = "Try a new search"
    }
    
    // MARK: - Constraints
    private func addSubviews() {
        addSubview(magnifierImageView)
        addSubview(noResultLabel)
        addSubview(tryAgainLabel)
    }
    
    private func addConstraints() {
        magnifierImageView.snp.makeConstraints { make in
            make.height.width.equalTo(48)
            make.centerX.top.equalToSuperview()
        }
        
        noResultLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(magnifierImageView.snp.bottom).offset(16)
        }
        
        tryAgainLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(noResultLabel.snp.bottom)
        }
    }
}
