//
//  Friend.swift
//  FriendsCollection
//
//  Created by 김태훈 on 2020/09/18.
//

import Foundation

 
struct Friend: Codable{
    struct Address: Codable {
        let country: String
        let city: String
    }

    let name: String
    let age: Int
    let addressInfo: Address
    
        
    enum CodingKeys: String, CodingKey{
        case name, age
        case addressInfo = "address_info"
    }
    
    var nameAndAge: String{
        return self.name + "(\(self.age))"
    }
    
    var fullAddress: String{
        return self.addressInfo.city + ", " + self.addressInfo.country
    }
}
 
