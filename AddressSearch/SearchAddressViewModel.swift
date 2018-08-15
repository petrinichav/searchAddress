//
//  SearchAddressViewModel.swift
//  ShipTuya
//
//  Created by Alexey Petrinich on 11/05/2018.
//  Copyright © 2018 tuya. All rights reserved.
//

import Foundation
import RxSwift
import Async

class SearchAddressViewModel: SearchAddressViewModelProtocol {
    private var addresses: [Address] = []
    private var searchInProgress: Bool = false
    private var currentSearchText = ""
    private let bag = DisposeBag()
    private let selectedAddressCallback: SearchAddressCallback!
    
    var showLoading = PublishSubject<Bool>.init()
    var showMessage = PublishSubject<String>()
    var dataSource = Variable<(UISearchControllerDelegate & UISearchResultsUpdating & UITableViewDataSource & UITableViewDelegate)?>.init(nil)
    var onCellSelected = PublishSubject<Address>.init()
    var searchTextChanged = PublishSubject<String>.init()
    var popToPreviousController = PublishSubject<Bool>.init()
    
    init(_ callback: @escaping SearchAddressCallback) {
        self.selectedAddressCallback = callback
        self.binding()
        self.refreshDatasource()
    }
    
    var numberOfAddresses: Int {
        return addresses.count
    }
    
    func address(at index: Int) -> String {
        guard let address = addresses[safe: index] else {
            return ""
        }
        return address.addressLine ?? ""
    }
    
    func search(address: String) {
        guard !searchInProgress else { return }
        searchInProgress = true
        showLoading.onNext(true)
        RestClient.shared.searchAddress(by: address) {[weak self] result, error in
            guard let strong = self else {return}
            strong.showLoading.onNext(false)
            strong.searchInProgress = false
            if strong.currentSearchText != address {
                strong.search(address: strong.currentSearchText)
            }
            guard let result = result else {
                strong.showMessage.onNext(error ?? "Unknown error")
                return
            }
            strong.addresses = result
            strong.refreshDatasource()
        }
    }
    
    private func binding() {
        onCellSelected.subscribe(onNext: {[weak self] address in
            self?.searchTextChanged.dispose()
            Async.main {
                self?.selectedAddressCallback(address)
                self?.popToPreviousController.onNext(true)
            }
        }).disposed(by: bag)
        searchTextChanged.subscribe(onNext: { [weak self] query in
            self?.currentSearchText = query
            self?.search(address: query)
        }).disposed(by: bag)
    }
    
    private func refreshDatasource() {
        (self.dataSource.value as? SearchAddressDatasource)?.itemSelected.dispose()
        (self.dataSource.value as? SearchAddressDatasource)?.searchQueryChanged.dispose()
        
        let dataSource = SearchAddressDatasource.init(self.addresses)
        dataSource.itemSelected.bind(to: self.onCellSelected).disposed(by: bag)
        dataSource.searchQueryChanged.throttle(3, scheduler: ConcurrentMainScheduler.instance).filter({$0.count > 2}).bind(to: self.searchTextChanged).disposed(by: bag)
        
        self.dataSource.value = dataSource
    }
}
