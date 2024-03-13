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
                self?.converterScreenView.converterView.swapAddAndTradeButtonsVisability()
                self?.converterScreenView.converterView.currenciesTableView.setEditing(false, animated: false)
                self?.converterScreenView.converterView.currenciesTableView.visibleCells.forEach { cell in
                    (cell as? SelectedCurrencyCell)?.animateCurrencyCodeConstraintsWithGesture(.ended)
                }
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
                switch gesture.state {
                case .began:
                    self?.converterScreenView.converterView.currenciesTableView.setEditing(true, animated: true)
                    self?.converterScreenView.converterView.currenciesTableView.visibleCells.forEach { cell in
                        (cell as? SelectedCurrencyCell)?.animateCurrencyCodeConstraintsWithGesture(.began)
                    }
                    self?.converterScreenView.converterView.swapAddAndTradeButtonsVisability()
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func subscribeToCurrenciesTableViewItemMoved() {
        converterScreenView.converterView.currenciesTableView.rx.itemMoved.subscribe { sourceIndexPath, destinationIndexPath in
            self.viewModel.rearrangeDraggedCurrencyPosition(sourceIndexPath: sourceIndexPath,
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
    
//    private func toggleScrollViewContentOffset(notification: Notification) {
//        guard let userInfo = notification.userInfo as? [String: Any],
//              let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
//        else { return }
//        
//        let contentHeight = converterScreenView.lastTimeUpdatedVStack.frame.origin.y + converterScreenView.lastTimeUpdatedVStack.frame.height
//        let scrollViewHeight = converterScreenView.scrollView.frame.height
//        let topGapHeight = converterScreenView.converterView.frame.origin.y - converterScreenView.titleLabel.frame.origin.y - converterScreenView.titleLabel.frame.height
//        let bottomGapHeight = converterScreenView.lastTimeUpdatedVStack.frame.origin.y - converterScreenView.converterView.frame.origin.y - converterScreenView.converterView.frame.height
//        let contentBottomOffset =  contentHeight + keyboardHeight + topGapHeight + bottomGapHeight - scrollViewHeight
//        
//        if notification.name == UIResponder.keyboardWillShowNotification && contentBottomOffset > 0 {
//            var contentBottomInset: CGFloat = 0
//            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//                let orientation = windowScene.interfaceOrientation
//                if orientation.isPortrait {
//                    switch contentBottomOffset {
//                    case 0...150:
//                        contentBottomInset = 350
//                    default:
//                        contentBottomInset = 230
//                    }
//                }
//            }
//            
//            converterScreenView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: contentBottomInset, right: 0)
//            converterScreenView.scrollView.scrollIndicatorInsets = converterScreenView.scrollView.contentInset
//            UIView.animate(withDuration: 0.5) {
//                self.converterScreenView.scrollView.contentOffset = CGPoint(x: 0, y: contentBottomOffset)
//            }
//        } else if notification.name == UIResponder.keyboardWillHideNotification {
//            converterScreenView.scrollView.contentInset = .zero
//            UIView.animate(withDuration: 0.5) {
//                self.converterScreenView.scrollView.contentOffset = .zero
//            }
//        }
//    }
}
