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
        subscribeToCurrenciesTableViewItemSelected()
    }
    
    // MARK: - Subscriptions
    private func subscribeToFilteredCurrencies() {
        viewModel.filteredCurrencies
            .subscribe(onNext: { _ in
                self.toggleNoResultsView()
            })
            .disposed(by: disposeBag)
    }
    
    private func subscribeToSearchBarText() {
        searchController.searchBar.rx
            .text
            .orEmpty
            .scan(String()) { previousText, newText in
                let maxNumberOfSymbols = 15
                
                defer {
                    let textToUpdate = newText.isValidWith(regex: RegexPattern.onlyAlphaSymbols) ? newText : previousText
                    self.updateNoResultLabel(withText: textToUpdate)
                    self.updateCurrenciesList(withText: textToUpdate)
                }
                
                if newText.count > maxNumberOfSymbols || !newText.isValidWith(regex: RegexPattern.onlyAlphaSymbols) {
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
    
    private func subscribeToCurrenciesTableViewItemSelected() {
        currencySelectionView.availableCurrenciesTableView.rx
            .itemSelected
            .subscribe { indexPath in
                guard let converterViewController = (self.navigationController?.viewControllers.first as? ConverterViewController),
                      let cell = self.currencySelectionView.availableCurrenciesTableView.cellForRow(at: indexPath) as? AvailableCurrencyCell,
                      let currencyName = cell.currencyNameLabel.text else { return }
                
                var newAvailableCurrencies = self.viewModel.filteredCurrencies.value
                
                if let selectedCurrency = Currency.getCurrency(basedOn: currencyName),
                    var newSelectedCurrencies = try? converterViewController.viewModel.selectedCurrencies.value().first?.items {
                    newSelectedCurrencies.append(selectedCurrency)
                    
                    newAvailableCurrencies.indices.forEach { index in
                        newAvailableCurrencies[index].items.removeAll { $0 == selectedCurrency }
                    }
                    
                    self.viewModel.filteredCurrencies.accept(newAvailableCurrencies)
                    self.viewModel.coreDataManager.addSelectedCurrency(currencyName: currencyName.truncated(to: 3).lowercased())
                    
                    converterViewController.viewModel.refreshSelectedCurrencies()
//                    converterViewController.viewModel.selectedCurrencies.onNext([SectionOfCurrency(items: newSelectedCurrencies)])
                }
                
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Methods
    private func setUpSearchController() {
        navigationItem.searchController = searchController
        searchController.searchBar.placeholder = "Search currency"
        searchController.searchBar.autocorrectionType = .no
    }
    
    private func toggleNoResultsView() {
        guard let filteredCurrenciesIsEmpty = viewModel.filteredCurrencies.value.first?.items.isEmpty else { return }
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
            guard let sectionFirstCharacter = self.viewModel.filteredCurrencies.value[section].items.first?.code.first else { return String() }
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
