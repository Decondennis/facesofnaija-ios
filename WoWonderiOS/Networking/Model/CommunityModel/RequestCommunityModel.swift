//
//  RequestCommunityModel.swift
//  FacesofnaijaiOS
//
//  Created by MacBook Pro on 26/07/2022.
//  Copyright © 2022 clines329. All rights reserved.
//

import Foundation

class RequestCommunityModel{
    
    struct requestCommunity_SuccessModel{
        var api_status : Int
        var community_data : [String:Any]
    }
    
    struct requestCommunity_ErrorModel : Codable{
        let apiStatus: String
        let errors: Errors
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case errors
        }
    }
    
    struct Errors: Codable {
        let errorID: Int
        let errorText: String
        
        enum CodingKeys: String, CodingKey {
            case errorID = "error_id"
            case errorText = "error_text"
        }
    }
    
    
}

extension RequestCommunityModel.requestCommunity_SuccessModel{
    
    init (json:[String:Any]){
        let api_status = json["api_status"] as? Int
        let communitydata =  json["community_data"] as? [String:Any]
        self.api_status = api_status ?? 0
        self.community_data = communitydata ?? ["id" : "12345"]
    }
    
}
