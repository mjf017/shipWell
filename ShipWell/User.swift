//
//  User.swift
//  ShipWell
//
//  Created by Matthew Foster on 19/9/18.
//  Copyright © 2018 MatthewFoster. All rights reserved.
//
import Foundation

class User: NSObject {
    
    private var contactName: String?
    private var primaryEmail: String?
    private var primaryPhone: String?
    
    init(contactName: String, primaryEmail: String, primaryPhone: String) {
        
        self.contactName = contactName
        self.primaryEmail = primaryEmail
        self.primaryPhone = primaryPhone
        
    }
    
    
    func getContactName() -> String {
        
        return contactName ?? "N/A"
    }
    
    func getPrimaryEmail() -> String {
        
        return primaryEmail ?? "N/A"
    }
    
    func getPrimaryPhone() -> String {
        
        return primaryPhone ?? "N/A"
    }
    
}
