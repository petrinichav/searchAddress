//
//  SearchAddressModel.swift
//  ShipTuya
//
//  Created by Alexey Petrinich on 13/05/2018.
//  Copyright © 2018 tuya. All rights reserved.
//

import Foundation
import RxSwift

protocol SearchAddressViewModelProtocol {
    var showLoading: PublishSubject<Bool> {get}
    var showMessage: PublishSubject<String> {get}
    var onCellSelected: PublishSubject<Address> {get}
    var searchTextChanged: PublishSubject<String> {get}
    var popToPreviousController: PublishSubject<Bool> {get}
    
    var dataSource: Variable<(UITableViewDataSource & UITableViewDelegate & UISearchControllerDelegate & UISearchResultsUpdating)?> {get}
}
