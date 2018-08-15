//
//  SearchAddressViewController.swift
//  ShipTuya
//
//  Created by Alexey Petrinich on 11/05/2018.
//  Copyright © 2018 tuya. All rights reserved.
//

import UIKit
import RxSwift
import Async

fileprivate let cellIdentifier = "SearchAddressCell"

class SearchAddressViewController: UIViewController {
    
    @IBOutlet var resultTableView: UITableView!
    
    var viewModel: SearchAddressViewModel!
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        initSearchController()
        binding()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchController.dismiss(animated: false, completion: nil)
        self.hideLoading()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private let bag = DisposeBag()
    
    private func binding() {
        viewModel.showLoading.asObservable().subscribe(onNext: { [weak self] (show) in
            show ? self?.showLoading() : self?.hideLoading()
        }).disposed(by: bag)
        viewModel.showMessage.subscribe(onNext: { [weak self] (msg) in
            self?.showToast(msg)
        }).disposed(by: bag)
        viewModel.dataSource.asObservable().subscribe(onNext: { [weak self] (datasource) in
            self?.searchController.delegate = datasource
            self?.searchController.searchResultsUpdater = datasource
            self?.resultTableView.dataSource = datasource
            self?.resultTableView.delegate = datasource
            self?.resultTableView.reloadData()
        }).disposed(by: bag)
        viewModel.popToPreviousController.asObserver().subscribe(onNext: {[weak self] needToPop in
            guard needToPop else { return }
            self?.searchController.dismiss(animated: true, completion: nil)
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: bag)
    }
    
    private func initSearchController() {
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.tintColor = UIColor.darkGray
        searchController.searchBar.placeholder = "Enter Address"
        
        resultTableView.tableHeaderView = searchController.searchBar
    }

}
