//
//  ConverterViewController.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 31/12/2023.
//

import UIKit
import RxSwift
import RxCocoa

final class ConverterViewController: UIViewController {
    let viewModel: ConverterViewModelType
    let converterScreenView = ConverterScreenView()
    
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
        subscribeToTradeButtonsTapped()
        bindSelectedCurrenciesToTableView()
        addRxObservers()
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
    
    private func subscribeToAmountTextFieldTextInCell(_ cell: SelectedCurrencyCell) {
        cell.amountTextField.rx
            .text
            .orEmpty
            .scan(String(), accumulator: { previousText, newText in
                let numberFormatter = AccountingNumberFormatter()
                let acceptedText = numberFormatter.applyTextFieldTextFormat(for: cell.amountTextField,
                                                                            previousText: previousText,
                                                                            currentText: newText)
                //                self.viewModel.balance = acceptedText.asDouble() ?? Double()
                return acceptedText
            })
            .bind(to: cell.amountTextField.rx.text)
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDataSource
extension ConverterViewController {
    private func bindSelectedCurrenciesToTableView() {
        viewModel.selectedCurrencies.bind(to: converterScreenView.converterView.currenciesTableView.rx.items(cellIdentifier: SelectedCurrencyCell.reuseIdentifier, 
                                                                                                             cellType: SelectedCurrencyCell.self)) { [weak self] row, currency, cell in
            cell.viewModel = self?.viewModel.cellViewModel(currency: currency)
            self?.subscribeToAmountTextFieldTextInCell(cell)
        }
        .disposed(by: disposeBag)
    }
}

// MARK: NotificationCenter Subscriptions
extension ConverterViewController {
    private func addRxObservers() {
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { notification in
                self.toggleScrollViewContentOffset(notification: notification)
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { notification in
                self.toggleScrollViewContentOffset(notification: notification)
            })
            .disposed(by: disposeBag)
    }
    
    private func toggleScrollViewContentOffset(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any],
              let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
        else { return }
        
        let contentHeight = converterScreenView.lastTimeUpdatedVStack.frame.origin.y + converterScreenView.lastTimeUpdatedVStack.frame.height
        let scrollViewHeight = converterScreenView.scrollView.frame.height
        let bottomViewsGapHeight = converterScreenView.lastTimeUpdatedVStack.frame.origin.y - converterScreenView.converterView.frame.origin.y - converterScreenView.converterView.frame.height
        let contentBottomInset =  contentHeight + keyboardHeight + bottomViewsGapHeight - scrollViewHeight
        
        if notification.name == UIResponder.keyboardWillShowNotification && contentBottomInset > 0 {
            converterScreenView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: contentBottomInset, right: 0)
            converterScreenView.scrollView.scrollIndicatorInsets = converterScreenView.scrollView.contentInset
            UIView.animate(withDuration: 0.5) {
                self.converterScreenView.scrollView.contentOffset = CGPoint(x: 0, y: contentBottomInset)
            }
        } else if notification.name == UIResponder.keyboardWillHideNotification {
            converterScreenView.scrollView.contentInset = .zero
            UIView.animate(withDuration: 0.5) {
                self.converterScreenView.scrollView.contentOffset = .zero
            }
        }
    }
}
