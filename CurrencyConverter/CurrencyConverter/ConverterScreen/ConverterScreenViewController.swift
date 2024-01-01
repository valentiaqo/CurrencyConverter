//
//  ConverterScreenViewController.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 31/12/2023.
//

import UIKit

class ConverterScreenViewController: UIViewController {
    let viewModel: ConverterScreenViewModelType
    let converterScrenView = ConverterScreenView()

    // MARK: - Inits
    init(viewModel: ConverterScreenViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController's lifecycle
    override func loadView() {
        super.loadView()
        view = converterScrenView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
