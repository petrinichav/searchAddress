//
//  SearchAddressDatasource.swift
//  ShipTuya
//
//  Created by Alexey Petrinich on 14/05/2018.
//  Copyright © 2018 tuya. All rights reserved.
//

import Foundation
import RxSwift
import Async

class SearchAddressDatasource: NSObject {
    let itemSelected = PublishSubject<Address>()
    let searchQueryChanged = PublishSubject<String>()
    
    private var addresses: [Address] = []
    private let timeToInputFinish: Double = 1
    private var currentQuery = ""
    private var inputContinues: Bool = false {
        willSet {
            guard newValue else {
                return
            }
            Async.main(after: timeToInputFinish, {
                self.inputContinues = false
            })
        }
    }
    
    init(_ addresses: [Address]) {
        self.addresses = addresses
        super.init()
    }
}

fileprivate let cellIdentifier = "SearchAddressCell"

extension SearchAddressDatasource: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        cell = cell == .none ? UITableViewCell(style: .default, reuseIdentifier: cellIdentifier) : cell
        cell?.textLabel?.text = addresses[safe: indexPath.row]?.displayName
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let address = addresses[safe: indexPath.row] else {
            return
        }
        itemSelected.onNext(address)
    }
}

extension SearchAddressDatasource: UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        inputContinues = true
        currentQuery = text
        self.searchQueryChanged.onNext(self.currentQuery)
    }
}
