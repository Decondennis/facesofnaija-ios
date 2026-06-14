//
//  GetCommunityPostModel.swift
//  FacesofnaijaiOS
//
//  Created by MacBook Pro on 28/07/2022.
//  Copyright © 2022 clines329. All rights reserved.
//

class GetCommunityPostModel{
    
    struct getCommunityPost_SuccessModel {
        
        var api_status : Int
        var data : [[String:Any]]
    }
    
    struct  getCommunityPost_ErrorModel : Codable {
        
        let apiStatus: String
        let errors: Errors
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case errors
        }
        
        
    }
    
    struct Errors: Codable {
        let errorID, errorText: String
        
        enum CodingKeys: String, CodingKey {
            case errorID = "error_id"
            case errorText = "error_text"
        }
        
        
    }
    
    
}

extension GetCommunityPostModel.getCommunityPost_SuccessModel{
    init (json : [String:Any]){
        
        let api_status = json["api_status"] as? Int
        let data = json["data"] as? [[String:Any]]
        self.api_status = api_status ?? 0
        self.data = data ?? [["PostType" : "Profile_Pic"]]
        
    }
    
}
