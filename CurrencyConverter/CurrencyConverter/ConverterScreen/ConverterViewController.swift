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
    
    let currencyNetworkManager: CurrencyNetworkManagerType = CurrencyNetworkManager()
    
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
        
        //        Task {
        //            await currencyNetworkManager.fetchCurrentCurrenciesRates()
        //        }
    }
    
    override func viewWillLayoutSubviews() {
        converterScreenView.converterView.layoutIfNeeded()
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
            .scan(String(), accumulator: { previousText, newText in
                let numberFormatter = AccountingNumberFormatter()
                let acceptedText = numberFormatter.applyTextFieldTextFormat(for: cell.amountTextField,
                                                                            previousText: previousText,
                                                                            currentText: newText)
                return acceptedText
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
            .subscribe { indexPath in
                self.viewModel.deleteCurrency(at: indexPath)
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
}

// MARK: - UITableViewDataSource
extension ConverterViewController {
    private func tableViewDataSource() -> RxTableViewSectionedAnimatedDataSource<SectionOfCurrency> {
        let dataSource = RxTableViewSectionedAnimatedDataSource<SectionOfCurrency> { [weak self] _, tableView, indexPath, cell in
            let cell = tableView.dequeueReusableCell(withIdentifier: SelectedCurrencyCell.reuseIdentifier, for: indexPath)
            guard let self, let currency = try? viewModel.selectedCurrencies.value()[indexPath.section].items[indexPath.row] else { return UITableViewCell() }
            (cell as? SelectedCurrencyCell)?.viewModel = viewModel.cellViewModel(currency: currency)
            (cell as? SelectedCurrencyCell)?.animateConstraintsWhenEditing(converterScreenView.converterView.isInEditingMode.value)
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
