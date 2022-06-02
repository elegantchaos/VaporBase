//
//  File.swift
//  
//
//  Created by Sam Deane on 02/06/2022.
//

import Foundation

extension String {
    /// Remove HTML (and potentially other things that might be dangerous)
    var sanitized: String? {
        return self.strippingHTML
    }
    
    /// Remove any HTML tags from the string.
    var strippingHTML: String? {
        guard let htmlStringData = self.data(using: String.Encoding.utf8) else {
            return nil
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        let attributedString = try? NSAttributedString(data: htmlStringData, options: options, documentAttributes: nil)
        return attributedString?.string
    }
}
