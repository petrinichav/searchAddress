//
//  SearchAddressModulManager.swift
//  ShipTuya
//
//  Created by Alexey Petrinich on 11/05/2018.
//  Copyright © 2018 tuya. All rights reserved.
//

import Foundation

typealias SearchAddressCallback = ((_ : Address) -> Void)

class SearchAddressModulManager: NavigationViewInterface {
    static var viewControllerInstance: UIViewController? {
        return UIStoryboard(name: TuyaAppConstants.Storyboard.orders, bundle: Bundle.main).instantiateViewController(withIdentifier: TC.VCID.SearchAddressViewController)
    }
    
    static func setup(with object: Any, view: UIViewController) {
        guard let vc = view as? SearchAddressViewController else { return }
        let viewModel = SearchAddressViewModel(object as! SearchAddressCallback)
        vc.viewModel = viewModel
    }
    
    
}
