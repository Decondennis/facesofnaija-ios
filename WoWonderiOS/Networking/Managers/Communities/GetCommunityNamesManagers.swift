//
//  GetCommunityNames.swift
//  FacesofnaijaiOS
//
//  Created by MacBook Pro on 13/07/2022.
//  Copyright © 2022 clines329. All rights reserved.
//

import Foundation
import Alamofire


class GetCommunityNamesManagers{
    
    func get_Community_Names(completionBlock : @escaping (_ Success:GetCommunityNamesModel.getCommunityNames_SuccessModel?, _ AuthError : GetCommunityNamesModel.getCommunityNames_ErrorModel? , Error?)->()){

        let body = [APIClient.Params.serverKey : APIClient.SERVER_KEY.Server_Key, APIClient.Params.userId:UserData.getUSER_ID() ?? ""] as [String : Any]
        let access_token = "\("?")\("access_token")\("=")\(UserData.getAccess_Token()!)"
        
        print("URL",APIClientCustom.Get_Community_Names.Get_Community_Names + access_token)
        AF.request(APIClientCustom.Get_Community_Names.Get_Community_Names + access_token, method: .post, parameters: body, encoding: URLEncoding.default, headers:
            nil).responseJSON { (response) in
            if response.value != nil {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatusCode = res["api_status"]  as? Any else {return}
                let apiCode = apiStatusCode as? Int
                if apiCode == 200 {
                let result = GetCommunityNamesModel.getCommunityNames_SuccessModel(json: res)
                    print(result)
                    
                    completionBlock(result,nil,nil)
                }
                else {
                    guard let alldata = try? JSONSerialization.data(withJSONObject: response.value, options: []) else {return}
                    guard let result = try? JSONDecoder().decode(GetCommunityNamesModel.getCommunityNames_ErrorModel.self, from: alldata) else {return}
                    completionBlock(nil,result,nil)
                    
                }
            }
            else {
                print(response.error?.localizedDescription)
                completionBlock(nil,nil,response.error)
            }
        }
    }
    
    static var sharedInstance = GetCommunityNamesManagers()
    private init () {}
    
}
