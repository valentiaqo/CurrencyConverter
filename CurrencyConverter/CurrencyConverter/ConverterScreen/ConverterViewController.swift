//
//  ConverterViewController.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 31/12/2023.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ConverterViewController: UIViewController {
    let viewModel: ConverterViewModelType
    let converterScreenView = ConverterScreenView()
    
    let disposeBag = DisposeBag()
    
    // MARK: - Inits
    init(viewModel: ConverterViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRatesFetchCompleted(_:)), name: .ratesFetchCompleted, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - ViewController's lifecycle
    override func loadView() {
        super.loadView()
        view = converterScreenView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        bindSelectedCurrenciesToTableView()
        subscribeToCurrenciesTableViewItemMoved()
        subscribeToCurrenciesTableViewItemDeleted()
        addKeyboardNotificationRxObservers()
        subscribeToLongPressGesture()
        subscribeToScrollViewWillBeginDragging()
        subscribeToTapGestureRecognizer()
        subscribeToTradeButtonsTapped()
        subscribeToDoneButtonTapped()
        subscribeToAddCurrencyButtonTapped()
        subscribeToBidButtonTapped()
        subscribeToAskButtonTapped()
        updateTimeLabel()
    }
    
    override func viewWillLayoutSubviews() {
        converterScreenView.converterWindowView.layoutIfNeeded()
    }
    
    @objc func handleRatesFetchCompleted(_ notification: Notification) {
        updateTimeLabel()
    }
    
    private func appendCellIfNotPresent(_ cell: SelectedCurrencyCell) {
        guard let cellCurrency = currencyFrom(cell), viewModel.currencyRatePairs[cellCurrency] == nil else { return }
        viewModel.currencyRatePairs[cellCurrency] = String()
    }
    
    private func deleteCellIfPresent(_ cell: SelectedCurrencyCell) {
        guard let cellCurrency = currencyFrom(cell), viewModel.currencyRatePairs[cellCurrency] != nil else { return }
        viewModel.currencyRatePairs.removeValue(forKey: cellCurrency)
    }
    
    private func currencyFrom(_ cell: SelectedCurrencyCell) -> Currency? {
        return Currency.getCurrency(basedOn: cell.currencyCodeLabel.text.orEmpty)
    }
    
    func makeConversion(for cell: SelectedCurrencyCell, previousText: String, newText: String) -> String {
        let numberFormatter = AccountingNumberFormatter()
        var acceptedText = numberFormatter.applyTextFieldTextFormat(for: cell.amountTextField,
                                                                    previousText: previousText,
                                                                    currentText: newText)
        
        guard let cellCurrency = currencyFrom(cell) else { return acceptedText }
        if viewModel.editedCurrency != cellCurrency && viewModel.currencyRatePairs[cellCurrency] != String() {
            viewModel.editedCurrency = cellCurrency
            acceptedText = viewModel.currencyRatePairs[cellCurrency].orEmpty
            viewModel.currencyRatePairs[cellCurrency] = numberFormatter.textWithourGroupingSeparators(viewModel.currencyRatePairs[cellCurrency].orEmpty)
            populateDataInVisibleCells()
        } else if viewModel.editedCurrency == cellCurrency || (viewModel.editedCurrency != cellCurrency && cell.amountTextField.isEditing) {
            viewModel.editedCurrency = cellCurrency
            viewModel.currencyRatePairs[cellCurrency] = acceptedText
            viewModel.convertRates(baseCurrency: cellCurrency, baseValue: cell.amountTextField.text.orEmpty)
            populateDataInVisibleCells()
        }
        
        return acceptedText
    }
    
    private func populateDataInVisibleCells() {
        converterScreenView.converterWindowView.currenciesTableView.visibleCells.forEach { cell in
            guard let cell = (cell as? SelectedCurrencyCell), let editedCurrency = viewModel.editedCurrency else { return }
            
            viewModel.currencyRatePairs.forEach { currency, rate in
                if Currency.getCurrency(basedOn: cell.currencyCodeLabel.text.orEmpty) == currency {
                    cell.amountTextField.text = AccountingNumberFormatter().applyTextFieldTextFormat(for: cell.amountTextField, previousText: rate, currentText: rate)
                    
                    if viewModel.currencyRatePairs[editedCurrency] == String() {
                        cell.amountTextField.text = String()
                        viewModel.currencyRatePairs[currency] = String()
                    
                    }
                }
            }
        }
    }
    
    private func prepareCellIfNewlyAdded(_ cell: SelectedCurrencyCell) {
        if cell.isNewlyAdded == false {
            cell.isNewlyAdded = true
            appendCellIfNotPresent(cell)
            subscribeToAmountTextFieldTextIn(cell)
        }
    }
    
    private func updateTimeLabel() {
        guard let lastFetchTime = viewModel.coreDataManager.retrieveLastFetchTime() else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy hh:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let formattedDate = dateFormatter.string(from: lastFetchTime)
        converterScreenView.updateTimeLabel.text = formattedDate
    }
    
    // MARK: - Subscriprions
    private func subscribeToScrollViewWillBeginDragging() {
        converterScreenView.scrollView.rx
            .willBeginDragging
            .subscribe { [weak self] _ in
                self?.converterScreenView.converterWindowView.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
    
    private func subscribeToTapGestureRecognizer() {
        converterScreenView.tapGestureRecognizer.rx
            .event
            .subscribe { [weak self] _ in
                self?.converterScreenView.converterWindowView.endEditing(true)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func subscribeToTradeButtonsTapped() {
        converterScreenView.converterWindowView.bidButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                self?.converterScreenView.converterWindowView.animateLayerMotion(x: 0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.converterScreenView.converterWindowView.toggleTradeButtonsState()
                }
            })
            .disposed(by: disposeBag)
        
        converterScreenView.converterWindowView.askButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                self?.converterScreenView.converterWindowView.animateLayerMotion(x: self?.converterScreenView.converterWindowView.calculateLayerWidth() ?? 0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.converterScreenView.converterWindowView.toggleTradeButtonsState()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func subscribeToDoneButtonTapped() {
        converterScreenView.converterWindowView.doneButton.rx
            .tap
            .subscribe { [weak self] _ in
                self?.converterScreenView.converterWindowView.isInEditingMode.accept(false)
                self?.converterScreenView.converterWindowView.toggleTextFieldsEditability()
                self?.converterScreenView.converterWindowView.swapAddAndTradeButtonsVisability()
            }
            .disposed(by: disposeBag)
    }
    
    private func subscribeToAmountTextFieldTextIn(_ cell: SelectedCurrencyCell) {
        cell.amountTextField.rx
            .text
            .orEmpty
            .scan(String(), accumulator: { previousText, newText in
                
//                defer {
//                    print(self.viewModel.currencyRatePairs)
//                    print("/")
//                }
                return self.makeConversion(for: cell, previousText: previousText, newText: newText)
            })
            .bind(to: cell.amountTextField.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func subscribeToLongPressGesture() {
        converterScreenView.converterWindowView.longPressGesture.rx
            .event
            .subscribe(onNext: { [weak self] gesture in
                guard let self else { return }
                
                if !converterScreenView.converterWindowView.addCurrencyButton.isHidden {
                    switch gesture.state {
                    case .began:
                        converterScreenView.converterWindowView.isInEditingMode.accept(true)
                        converterScreenView.converterWindowView.endEditing(true)
                        converterScreenView.converterWindowView.toggleTextFieldsEditability()
                        converterScreenView.converterWindowView.swapAddAndTradeButtonsVisability()
                    default:
                        break
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func subscribeToCurrenciesTableViewItemMoved() {
        converterScreenView.converterWindowView.currenciesTableView.rx
            .itemMoved
            .subscribe { sourceIndexPath, destinationIndexPath in
                self.viewModel.rearrangeCurrencyPosition(sourceIndexPath: sourceIndexPath,
                                                         destinationIndexPath: destinationIndexPath)
            }
            .disposed(by: disposeBag)
    }
    
    private func subscribeToCurrenciesTableViewItemDeleted() {
        converterScreenView.converterWindowView.currenciesTableView.rx
            .itemDeleted
            .subscribe { [weak self] indexPath in
                guard let self = self, let cell = self.converterScreenView.converterWindowView.currenciesTableView.cellForRow(at: indexPath) as? SelectedCurrencyCell else { return }
                self.viewModel.deleteCurrency(at: indexPath)
                self.deleteCellIfPresent(cell)
            }
            .disposed(by: disposeBag)
    }
    
    private func subscribeToAddCurrencyButtonTapped() {
        converterScreenView.converterWindowView.addCurrencyButton.rx
            .tap
            .subscribe { [weak self] _ in
                self?.converterScreenView.converterWindowView.endEditing(true)
                self?.viewModel.addCurrencyButtonPressed()
            }
            .disposed(by: disposeBag)
    }
    
    private func subscribeToBidButtonTapped() {
        converterScreenView.converterWindowView.bidButton.rx
            .tap
            .subscribe { [weak self] _ in
                guard let editedCurrency = self?.viewModel.editedCurrency, let rate = self?.viewModel.currencyRatePairs[editedCurrency] else { return }
                self?.viewModel.selectedTradingOption = .bid
                self?.viewModel.convertRates(baseCurrency: editedCurrency, baseValue: rate)
                self?.populateDataInVisibleCells()
            }
            .disposed(by: disposeBag)
    }
    
    private func subscribeToAskButtonTapped() {
        converterScreenView.converterWindowView.askButton.rx
            .tap
            .subscribe { [weak self] _ in
                guard let editedCurrency = self?.viewModel.editedCurrency, let rate = self?.viewModel.currencyRatePairs[editedCurrency] else { return }
                self?.viewModel.selectedTradingOption = .ask
                self?.viewModel.convertRates(baseCurrency: editedCurrency, baseValue: rate)
                self?.populateDataInVisibleCells()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDataSource
extension ConverterViewController {
    private func tableViewDataSource() -> RxTableViewSectionedAnimatedDataSource<SectionOfCurrency> {
        let dataSource = RxTableViewSectionedAnimatedDataSource<SectionOfCurrency> { [weak self] _, tableView, indexPath, cell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectedCurrencyCell.reuseIdentifier, for: indexPath) as? SelectedCurrencyCell,
                  let self, let currency = try? viewModel.selectedCurrencies.value()[indexPath.section].items[indexPath.row]
            else { return UITableViewCell() }
            
            cell.viewModel = viewModel.cellViewModel(currency: currency)
            cell.animateConstraintsWhenEditing(converterScreenView.converterWindowView.isInEditingMode.value)
            prepareCellIfNewlyAdded(cell)
            
            if let cellCurrency = currencyFrom(cell), let rate = viewModel.currencyRatePairs[cellCurrency] {
                cell.amountTextField.text = AccountingNumberFormatter().applyTextFieldTextFormat(for: cell.amountTextField, previousText: rate, currentText: rate)
            }
            
            return cell
        } canEditRowAtIndexPath: { _, _ in
            true
        } canMoveRowAtIndexPath: { _, _ in
            true
        }
        
        return dataSource
    }
    
    private func bindSelectedCurrenciesToTableView() {
        viewModel.selectedCurrencies
            .bind(to: converterScreenView.converterWindowView.currenciesTableView.rx.items(dataSource: tableViewDataSource()))
            .disposed(by: disposeBag)
    }
}

// MARK: - NotificationCenter Subscriptions
extension ConverterViewController {
    private func addKeyboardNotificationRxObservers() {
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { notification in
                self.converterScreenView.toggleScrollViewContentOffset(notification: notification)
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { notification in
                self.converterScreenView.toggleScrollViewContentOffset(notification: notification)
            })
            .disposed(by: disposeBag)
    }
}
