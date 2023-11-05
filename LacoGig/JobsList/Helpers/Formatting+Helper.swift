//
//  Formatting+Helper.swift
//  LacoGig
//
//  Created by Данил Терлецкий on 05.11.2023.
//

import Foundation

public func roundedPrice(from priceString: String) -> String {
    let components = priceString.components(separatedBy: ".")

    if components.count > 1 {
        if let cents = components.last, cents != "0" {
            return priceString
        } else {
            guard let withoutCents = components.first else { return priceString }
            return withoutCents
        }
    }
    return priceString
}
