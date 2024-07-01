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
    
    var editedCellIndexPath: IndexPath?
//    var currentlyEditedCell: SelectedCurrencyCell?
    
    var cellRatePairs: [SelectedCurrencyCell: String] = [:]
    
    let disposeBag = DisposeBag()
    
    // MARK: - Inits
    init(viewModel: ConverterViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        subscribeToTradeButtonsTapped()
        subscribeToDoneButtonTapped()
        subscribeToAddCurrencyButtonTapped()
        subscribeToBidButtonTapped()
        subscribeToAskButtonTapped()
    }
    
    override func viewWillLayoutSubviews() {
        converterScreenView.converterView.layoutIfNeeded()
    }
    
    
    private func appendCellIfNotPresent(_ cell: SelectedCurrencyCell) {
        guard cellRatePairs[cell] == nil else { return }
        cellRatePairs[cell] = String()
    }
    
    private func deleteCellIfPresent(_ cell: SelectedCurrencyCell) {
        guard cellRatePairs[cell] != nil else { return }
        cellRatePairs.removeValue(forKey: cell)
    }
    
    
    private func getCells(from cells: [SelectedCurrencyCell], except cell: SelectedCurrencyCell) -> [SelectedCurrencyCell] {
        return cells.filter { $0 != cell }
    }
    
    func makeConversion(for cell: SelectedCurrencyCell, previousText: String, newText: String) -> String {
        // Initialize a number formatter for formatting currency values
        let numberFormatter = AccountingNumberFormatter()
        var acceptedText = numberFormatter.applyTextFieldTextFormat(for: cell.amountTextField,
                                                                    previousText: previousText,
                                                                    currentText: newText)
        
        if cellRatePairs.values.contains(where: { $0 == String() }) && cellRatePairs.values.contains(where: { $0 != String() }) {
            cellRatePairs.forEach { cell, value in
                cell.amountTextField.text = String()
                cellRatePairs[cell] = String()
            }
            return acceptedText
        }
        
        let cellIndexPath = converterScreenView.converterView.currenciesTableView.indexPath(for: cell)
        
        if editedCellIndexPath != cellIndexPath && cellRatePairs[cell] != String() {
            return self.updateAcceptedTextForDifferentCell(cell: cell, acceptedText: &acceptedText, numberFormatter: numberFormatter)
        } else if editedCellIndexPath == cellIndexPath || (editedCellIndexPath != cellIndexPath && cell.amountTextField.isEditing) {
            return updateAcceptedTextForSameCell(cell: cell, acceptedText: &acceptedText, numberFormatter: numberFormatter)
        } else {
            return acceptedText
        }
    }
    
    private func updateAcceptedTextForDifferentCell(cell: SelectedCurrencyCell, acceptedText: inout String, numberFormatter: AccountingNumberFormatter) -> String {
        let cellIndexPath = converterScreenView.converterView.currenciesTableView.indexPath(for: cell)
        
        self.editedCellIndexPath = cellIndexPath
        acceptedText = self.cellRatePairs[cell].orEmpty
        // Update rate value for the currently edited cell without grouping separators
        self.cellRatePairs[cell] = numberFormatter.textWithourGroupingSeparators(self.cellRatePairs[cell].orEmpty)
        
        // Get a list of cells to update, excluding the current cell
        let cellsToUpdate = self.getCells(from: Array(self.cellRatePairs.keys), except: cell)
        // Iterate through each cell to update its text field format
        cellsToUpdate.forEach { convertedCell in
            self.cellRatePairs.forEach { cellKey, rateValue in
                if convertedCell == cellKey {
                    convertedCell.amountTextField.text = numberFormatter.applyTextFieldTextFormat(for: convertedCell.amountTextField,
                                                                                                  previousText: rateValue,
                                                                                                  currentText: rateValue)
                }
            }
        }
        return acceptedText
    }
    
    private func updateAcceptedTextForSameCell(cell: SelectedCurrencyCell, acceptedText: inout String, numberFormatter: AccountingNumberFormatter) -> String {
        let cellIndexPath = converterScreenView.converterView.currenciesTableView.indexPath(for: cell)
        self.editedCellIndexPath = cellIndexPath
        self.cellRatePairs[cell] = acceptedText
        
        let cellsToUpdate = self.getCells(from: Array(self.cellRatePairs.keys), except: cell)
        cellsToUpdate.forEach { convertedCell in
            // If accepted text is a valid double, get the currency rate and update text field format
            if acceptedText.asDouble() != nil {
                let rate = String(self.viewModel.getCurrencyRate(for: convertedCell, basedOn: cell))
                convertedCell.amountTextField.text = numberFormatter.applyTextFieldTextFormat(for: convertedCell.amountTextField,
                                                                                              previousText: rate,
                                                                                              currentText: rate)
                
                self.cellRatePairs[convertedCell] = numberFormatter.textWithourGroupingSeparators(convertedCell.amountTextField.text.orEmpty)
            } else if acceptedText.isEmpty {
                // If accepted text is empty, clear the text field and rate value for the converted cell
                convertedCell.amountTextField.text = String()
                self.cellRatePairs[convertedCell] = String()
            }
        }
        return acceptedText
    }
    
    
    // MARK: - Subscriprions
    private func subscribeToTradeButtonsTapped() {
        converterScreenView.converterView.bidButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                self?.converterScreenView.converterView.animateLayerMotion(x: 0)
                self?.converterScreenView.converterView.toggleTradeButtonsState()
            })
            .disposed(by: disposeBag)
        
        converterScreenView.converterView.askButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                self?.converterScreenView.converterView.animateLayerMotion(x: self?.converterScreenView.converterView.calculateLayerWidth() ?? 0)
                self?.converterScreenView.converterView.toggleTradeButtonsState()
            })
            .disposed(by: disposeBag)
    }
    
    private func subscribeToDoneButtonTapped() {
        converterScreenView.converterView.doneButton.rx
            .tap
            .subscribe { [weak self] _ in
                self?.converterScreenView.converterView.isInEditingMode.accept(false)
                self?.converterScreenView.converterView.swapAddAndTradeButtonsVisability()
            }
            .disposed(by: disposeBag)
    }
    
    private func subscribeToAmountTextFieldTextIn(_ cell: SelectedCurrencyCell) {
        cell.amountTextField.rx
            .text
            .orEmpty
            .distinctUntilChanged()
            .scan(String(), accumulator: { previousText, newText in
                cell.disposeBag = DisposeBag()
                return self.makeConversion(for: cell, previousText: previousText, newText: newText)
            })
            .bind(to: cell.amountTextField.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func subscribeToLongPressGesture() {
        converterScreenView.converterView.longPressGesture.rx
            .event
            .subscribe(onNext: { [weak self] gesture in
                guard let self else { return }
                
                if !converterScreenView.converterView.addCurrencyButton.isHidden {
                    switch gesture.state {
                    case .began:
                        converterScreenView.converterView.isInEditingMode.accept(true)
                        converterScreenView.converterView.swapAddAndTradeButtonsVisability()
                    default:
                        break
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func subscribeToCurrenciesTableViewItemMoved() {
        converterScreenView.converterView.currenciesTableView.rx
            .itemMoved
            .subscribe { sourceIndexPath, destinationIndexPath in
                self.viewModel.rearrangeCurrencyPosition(sourceIndexPath: sourceIndexPath,
                                                         destinationIndexPath: destinationIndexPath)
            }
            .disposed(by: disposeBag)
    }
    
    private func subscribeToCurrenciesTableViewItemDeleted() {
        converterScreenView.converterView.currenciesTableView.rx
            .itemDeleted
            .subscribe { [weak self] indexPath in
                guard let self = self, let cell = self.converterScreenView.converterView.currenciesTableView.cellForRow(at: indexPath) as? SelectedCurrencyCell else { return }
                self.viewModel.deleteCurrency(at: indexPath)
                self.deleteCellIfPresent(cell)
            }
            .disposed(by: disposeBag)
    }
    
    private func subscribeToAddCurrencyButtonTapped() {
        converterScreenView.converterView.addCurrencyButton.rx
            .tap
            .subscribe { [weak self] _ in
                self?.viewModel.addCurrencyButtonPressed()
            }
            .disposed(by: disposeBag)
    }
    
    private func subscribeToBidButtonTapped() {
        converterScreenView.converterView.bidButton.rx
            .tap
            .subscribe { [weak self] _ in
                guard let editedCellIndexPath = self?.editedCellIndexPath,
                      let editedCell = self?.converterScreenView.converterView.currenciesTableView.cellForRow(at: editedCellIndexPath) as? SelectedCurrencyCell else { return }
                self?.viewModel.selectedTradingOption = .bid
                _ = self?.makeConversion(for: editedCell, previousText: editedCell.amountTextField.text.orEmpty, newText: editedCell.amountTextField.text.orEmpty)
            }
            .disposed(by: disposeBag)
    }
    
    private func subscribeToAskButtonTapped() {
        converterScreenView.converterView.askButton.rx
            .tap
            .subscribe { [weak self] _ in
                guard let editedCellIndexPath = self?.editedCellIndexPath,
                      let editedCell = self?.converterScreenView.converterView.currenciesTableView.cellForRow(at: editedCellIndexPath) as? SelectedCurrencyCell else { return }
                self?.viewModel.selectedTradingOption = .ask
                _ = self?.makeConversion(for: editedCell, previousText: editedCell.amountTextField.text.orEmpty, newText: editedCell.amountTextField.text.orEmpty)
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
            cell.animateConstraintsWhenEditing(converterScreenView.converterView.isInEditingMode.value)
            
            if cell.isNewlyAdded == false {
                cell.isNewlyAdded = true
                appendCellIfNotPresent(cell)
                subscribeToAmountTextFieldTextIn(cell)
            }
            
            cell.amountTextField.text = cellRatePairs[cell]
            
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
            .bind(to: converterScreenView.converterView.currenciesTableView.rx.items(dataSource: tableViewDataSource()))
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
