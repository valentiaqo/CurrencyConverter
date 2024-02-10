//
//  CurrencySelectionViewController.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 23/01/2024.
//

import UIKit
import RxSwift
import RxDataSources

final class CurrencySelectionViewController: UIViewController {
    let viewModel: CurrencySelectionViewModel
    let currencySelectionView = CurrencySelectionView()
    
    let searchController = UISearchController()
    let disposeBag = DisposeBag()
    
    // MARK: - Inits
    init(viewModel: CurrencySelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController's lifecycle
    override func loadView() {
        super.loadView()
        view = currencySelectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Available currencies"
        setUpSearchController()
        bindAvailableCurrenciesToTableView()
        subscribeToFilteredCurrencies()
        subscribeToScrollViewWillBeginDragging()
        subscribeToSearchBarText()
    }
    
    // MARK: Subscriptions
    private func subscribeToFilteredCurrencies() {
        viewModel.filteredCurrencies
            .subscribe(onNext: { _ in
                self.toggleNoResultsView()
            })
            .disposed(by: disposeBag)
    }
    
    private func subscribeToSearchBarText() {
        searchController.searchBar.rx.text.orEmpty.scan(String()) { previousText, newText in
            let maxNumberOfSymbols = 15
            let regex = NSRegularExpression("^[a-zA-Z]{0,\(maxNumberOfSymbols)}$")
            
            defer {
                let textToUpdate = regex.matches(newText) ? newText : previousText
                self.updateNoResultLabel(withText: textToUpdate)
                self.updateCurrenciesList(withText: textToUpdate)
            }
            
            if newText.count > maxNumberOfSymbols || !regex.matches(newText) {
                self.searchController.searchBar.text = newText.truncated(to: maxNumberOfSymbols)
                return previousText
            }
            
            return newText
        }
        .bind(to: searchController.searchBar.rx.text)
        .disposed(by: disposeBag)
    }
    
    private func subscribeToScrollViewWillBeginDragging() {
        currencySelectionView.availableCurrenciesTableView.rx
            .willBeginDragging
            .subscribe { _ in
                self.searchController.searchBar.resignFirstResponder()
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: Methods
    private func setUpSearchController() {
        navigationItem.searchController = searchController
        searchController.searchBar.placeholder = "Search currency"
        searchController.searchBar.autocorrectionType = .no
    }
    
    private func toggleNoResultsView() {
        let filteredCurrenciesIsEmpty = viewModel.filteredCurrencies.value.isEmpty
        currencySelectionView.noResultsView.isHidden = !filteredCurrenciesIsEmpty
    }
    
    private func updateNoResultLabel(withText searchText: String) {
        currencySelectionView.noResultsView.noResultLabel.text = "No results for"
        currencySelectionView.noResultsView.noResultLabel.text = (currencySelectionView.noResultsView.noResultLabel.text ?? String()) +
        " \"\(searchText.truncated(to: 15))\""
    }
    
    private func updateCurrenciesList(withText text: String?) {
        guard let text = text else { return }
        if text.isEmpty {
            viewModel.filteredCurrencies.accept(viewModel.availableCurrencies)
        } else {
            viewModel.updateFilteredCurrenciesWithSearchText(text)
        }
    }
}

// MARK: - UITableViewDataSource
extension CurrencySelectionViewController {
    private func tableViewDataSource() -> RxTableViewSectionedReloadDataSource<SectionOfCurrency> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfCurrency> { _, tableView, indexPath, currency in
            let cell = tableView.dequeueReusableCell(withIdentifier: AvailableCurrencyCell.reuseIdentifier, for: indexPath)
            (cell as? AvailableCurrencyCell)?.viewModel = self.viewModel.cellViewModel(currency: currency)
            return cell
        } titleForHeaderInSection: { _, section in
            guard let sectionFirstCharacter = self.viewModel.filteredCurrencies.value[section].items.first?.fullName.first else { return String() }
            let sectionName = String(sectionFirstCharacter)
            return sectionName
        }
        
        return dataSource
    }
    
    private func bindAvailableCurrenciesToTableView() {
        viewModel.filteredCurrencies
            .bind(to: currencySelectionView.availableCurrenciesTableView.rx.items(dataSource: tableViewDataSource()))
            .disposed(by: disposeBag)
    }
}
