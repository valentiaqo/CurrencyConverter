//
//  ContainerView.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 05/01/2024.
//

import UIKit
import RxSwift
import RxRelay

final class ConverterWindowView: UIView {
    let bidButton = UIButton()
    let askButton = UIButton()
    
    let tradeButtonsHStack = UIStackView()
    let tradeButtonsContainerView = UIView()
    let tradeButtonsLayer = CALayer()
    var tradeButtonsLayerViewFrameXCoordinate: CGFloat = 0
    
    let currenciesTableView = UITableView(frame: .zero, style: .plain)
    var isInEditingMode = BehaviorRelay(value: false)
    
    let addCurrencyButton = UIButton()
    let doneButton = UIButton(configuration: .plain())
    let shareButton = UIButton()
    
    let longPressGesture = UILongPressGestureRecognizer()
    
    let disposeBag = DisposeBag()
    
    //MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizer(longPressGesture)
        
        setUpView()
        setUpTradeButtons()
        setUpTradeButtonsHStack()
        setUpTradeButtonsContainerView()
        configureButtonsStackSpacing()
        setUpCurrenciesTableView()
        setUpAddCurrencyButton()
        setUpDoneButton()
        setUpShareButton()
        addSubviews()
        addConstraints()
        
        subscribeToIsInEditingMode()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        updateButtonLayer()
    }
    
    override var bounds: CGRect {
        didSet {
            dropShadow()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        configureButtonsStackSpacing()
        updateButtonLayer()
        updateCurrentConstraints()
    }
    
    // MARK: - Subviews' setup
    private func setUpView() {
        backgroundColor = .white
        layer.cornerRadius = 15
    }
    
    private func setUpTradeButtons() {
        // buyButton
        bidButton.setTitle("Bid", for: .normal)
        bidButton.isEnabled = false
        
        // sellButton
        askButton.setTitle("Ask", for: .normal)
        askButton.isEnabled = !bidButton.isEnabled
        
        // buyButton and sellButton
        [bidButton, askButton].forEach { button in
            button.setTitleColor(UIColor.midnightBlue, for: .normal)
            button.setTitleColor(UIColor.white, for: .disabled)
            button.titleLabel?.font = UIFont(name: Fonts.Inter.regular.rawValue, size: 15)
        }
    }
    
    private func setUpTradeButtonsHStack() {
        tradeButtonsHStack.addArrangedSubview(bidButton)
        tradeButtonsHStack.addArrangedSubview(askButton)
        
        tradeButtonsHStack.axis = .horizontal
        tradeButtonsHStack.distribution = .fillEqually
    }
    
    private func setUpTradeButtonsContainerView() {
        // tradeButtonsContainerView
        tradeButtonsContainerView.layer.addSublayer(tradeButtonsLayer)
        
        // tradeButtonsLayerView
        tradeButtonsLayer.backgroundColor = UIColor.dodgerBlue.cgColor
        tradeButtonsLayer.cornerRadius = 10
    }
    
    private func setUpCurrenciesTableView() {
        currenciesTableView.register(SelectedCurrencyCell.self, forCellReuseIdentifier: SelectedCurrencyCell.reuseIdentifier)
        currenciesTableView.separatorStyle = .none
        currenciesTableView.allowsSelection = false
        currenciesTableView.showsVerticalScrollIndicator = false
        currenciesTableView.rowHeight = 50
        currenciesTableView.backgroundColor = .white
    }
    
    private func setUpAddCurrencyButton() {
        addCurrencyButton.setTitle("Add currency", for: .normal)
        addCurrencyButton.setTitleColor(.dodgerBlue, for: .normal)
        
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "plus.circle.fill")
        config.imagePadding = 5
        config.imagePlacement = .leading
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        
        addCurrencyButton.configuration = config
    }
    
    private func setUpDoneButton() {
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.dodgerBlue, for: .normal)
        
        doneButton.isHidden = true
    }
    
    private func setUpShareButton() {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .gray
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let image = UIImage(systemName: "square.and.arrow.up", withConfiguration: imageConfig)
        config.image = image
        
        shareButton.configuration = config
    }
    
    // MARK: - Layer Setup
    func animateLayerMotion(x: CGFloat) {
        var xCoordinate: CGFloat = 0
        UIView.animate(withDuration: 0.25) {
            if x == 0 {
                self.tradeButtonsLayer.frame = CGRect(x: x, y: 0, width: self.calculateLayerWidth(), height: 50)
            } else {
                switch (self.traitCollection.horizontalSizeClass, self.traitCollection.verticalSizeClass) {
                case (.compact, .regular), (.compact, .compact):
                    xCoordinate = x + 32
                case (.regular, .compact):
                    xCoordinate = x + 64
                case (.regular, .regular):
                    xCoordinate = x + 64
                default: break
                }
                self.tradeButtonsLayer.frame = CGRect(x: xCoordinate, y: 0, width: self.calculateLayerWidth(), height: 50)
            }
        }
        
        tradeButtonsLayerViewFrameXCoordinate = xCoordinate
    }
    
    func calculateLayerWidth() -> CGFloat {
        var width: CGFloat = 0
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
            // frame.width - leading+trailing constaraint - stackView) / 2
        case (.compact, .regular):
            width = (frame.width - 32 - 32) / 2
        case (.regular, .compact):
            width = (frame.width - 128 - 64) / 2
        case (.compact, .compact):
            width = (frame.width - 128 - 32) / 2
        case (.regular, .regular):
            width = (frame.width - 192 - 64) / 2
        default: break
        }
        
        return width
    }
    
    private func configureButtonsStackSpacing() {
        var tradeButtonsStackSpacing = tradeButtonsHStack.spacing
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.compact, .regular), (.compact, .compact):
            tradeButtonsStackSpacing = 32
        case (.regular, .compact):
            tradeButtonsStackSpacing = 64
        case (.regular, .regular):
            tradeButtonsStackSpacing = 64
        default: break
        }
        
        tradeButtonsHStack.spacing = tradeButtonsStackSpacing
    }
    
    private func updateButtonLayer() {
        tradeButtonsLayer.frame = CGRect(x: tradeButtonsLayerViewFrameXCoordinate, y: 0, width: calculateLayerWidth(), height: 50)
        if tradeButtonsLayerViewFrameXCoordinate == 0 {
            animateLayerMotion(x: 0)
        } else {
            animateLayerMotion(x: calculateLayerWidth())
        }
    }
    
    func toggleTradeButtonsState() {
        askButton.isEnabled.toggle()
        bidButton.isEnabled.toggle()
    }
    
    func toggleTextFieldsEditability() {
        currenciesTableView.visibleCells.forEach { cell in
            if let isEnabledState = (cell as? SelectedCurrencyCell)?.amountTextField.isEnabled {
                (cell as? SelectedCurrencyCell)?.amountTextField.isEnabled = !isEnabledState
                (cell as? SelectedCurrencyCell)?.colorTextFieldBackground()
            }
        }
    }
    
    private func dropShadow() {
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.25
        layer.shadowPath = CGPath(rect: CGRect(x: 0, y: 10, width: frame.width, height: frame.height - 5), transform: nil)
    }
    
    func swapAddAndTradeButtonsVisability() {
        UIView.animate(withDuration: 0.3) {
            self.doneButton.isHidden.toggle()
            self.addCurrencyButton.isHidden.toggle()
        }
    }
    
    func setCurrenciesTableViewEditingMode(to isEditing: Bool) {
        currenciesTableView.setEditing(isEditing, animated: isEditing)
        setCellsEditingMode(to: isEditing)
    }
    
    func setCellsEditingMode(to isEditing: Bool) {
        currenciesTableView.visibleCells.forEach { cell in
            guard let cell = cell as? SelectedCurrencyCell else { return }
            cell.animateConstraintsWhenEditing(isEditing)
        }
        
    }
    
    // MARK: - Subscriprions
    private func subscribeToIsInEditingMode() {
        isInEditingMode
            .subscribe { isEditing in
                self.setCurrenciesTableViewEditingMode(to: isEditing)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Constraints
    private func addSubviews() {
        addSubview(tradeButtonsContainerView)
        tradeButtonsContainerView.addSubview(tradeButtonsHStack)
        addSubview(currenciesTableView)
        addSubview(addCurrencyButton)
        addSubview(doneButton)
        addSubview(shareButton)
    }
    
    private func updateCurrentConstraints() {
        removeAllConstraints()
        addConstraints()
    }
    
    private func removeAllConstraints() {
        tradeButtonsContainerView.snp.removeConstraints()
    }
    
    private  func addConstraints() {
        tradeButtonsContainerView.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalToSuperview().inset(16)
            
            switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
            case (.compact, .regular):
                make.leading.trailing.equalToSuperview().inset(16)
            case (.regular, .compact), (.compact, .compact):
                make.leading.trailing.equalToSuperview().inset(64)
            case (.regular, .regular):
                make.leading.trailing.equalToSuperview().inset(96)
            default: break
            }
        }
        
        tradeButtonsHStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        currenciesTableView.snp.makeConstraints { make in
            make.top.equalTo(tradeButtonsContainerView.snp.bottom).offset(16)
            make.bottom.equalToSuperview().inset(64)
            make.leading.trailing.equalToSuperview()
        }
        
        addCurrencyButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(currenciesTableView.snp.bottom)
        }
        
        doneButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(currenciesTableView.snp.bottom)
        }
        
        shareButton.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(8)
        }
    }
}
