//
//  RequestCommunityManager.swift
//  FacesofnaijaiOS
//
//  Created by MacBook Pro on 26/07/2022.
//  Copyright © 2022 clines329. All rights reserved.
//

import Foundation
import Alamofire


class CommunityManager{
    
    func requestCommunity (name:String,country:String,state:String,lga:String, about:String,privacy:Int,completionBlock : @escaping (_ Success: RequestCommunityModel.requestCommunity_SuccessModel?, _ AuthError : RequestCommunityModel.requestCommunity_ErrorModel? , Error?)->()){
        
        let params = [APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key, 
        "community_name" : name, APIClientCustom.Params.country : country, 
        APIClientCustom.Params.state : state, APIClientCustom.Params.lga : lga, 
        APIClientCustom.Params.privacy :privacy,
        APIClientCustom.Params.about :about,
        APIClient.Params.userId :UserData.getUSER_ID() ?? "",
        APIClient.Params.type:"request-community"] as [String : Any]
        let access_token = "&access_token=\(UserData.getAccess_Token() ?? "")"
        AF.request(APIClientCustom.ReqeustCommunity.requestCommunityApi + access_token, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            print(response.value)
            if response.value != nil {
                guard let res = response.value as? [String:Any]  else {return}
                guard let apiCodeString = res["api_status"] as? Any else {return}
                if apiCodeString as? Int == 200 {
                    let result = RequestCommunityModel.requestCommunity_SuccessModel.init(json: res)
                completionBlock(result,nil,nil)
                }
                else  {
        guard let data = try? JSONSerialization.data(withJSONObject: response.value, options: []) else {return}
                    print(data)
                    guard let result = try? JSONDecoder().decode(RequestCommunityModel.requestCommunity_ErrorModel.self, from: data) else {return}
                    print(result)
                completionBlock(nil,result,nil)
                }
            }
            else {
                print(response.error?.localizedDescription)
                completionBlock(nil,nil,response.error)
            }
        }
    }
    
    func getCommunityPost(communityId : String,afterPostId : String, completionBlock : @escaping (_ Success:GetCommunityPostModel.getCommunityPost_SuccessModel?, _ AuthError : GetCommunityPostModel.getCommunityPost_ErrorModel? , Error?)->()){
        let params = [APIClient.Params.serverKey : APIClient.SERVER_KEY.Server_Key,APIClient.Params.type : "get_community_posts", APIClient.Params.limit : 10, APIClient.Params.id : communityId, APIClient.Params.afterPostId : afterPostId] as [String : Any]
        let access_token = "&access_token=\(UserData.getAccess_Token() ?? "")"
        AF.request(APIClientCustom.GetCommunityPost.getCommunityPostApi + access_token, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if response.value != nil {
            guard let res = response.value as? [String:Any] else {return}
            guard let apiStatusCode = res["api_status"]  as? Any else {return}
            let apiCode = apiStatusCode as? Int
            if apiCode == 200 {
            let result = GetCommunityPostModel.getCommunityPost_SuccessModel.init(json: res)
            completionBlock(result,nil,nil)
                }
            else {
        guard let data = try? JSONSerialization.data(withJSONObject:response.value, options: []) else {return}
        guard let result = try? JSONDecoder().decode(GetCommunityPostModel.getCommunityPost_ErrorModel.self, from: data) else {return}
        completionBlock(nil,result,nil)
                }
                
            }
            
            else {
                print(response.error?.localizedDescription)
                completionBlock(nil,nil,response.error)
            }
        }
    }
    
    // MARK: - Fetch Communities by type
    func getCommunities(fetch: String, limit: Int = 20, offset: Int = 0, completionBlock: @escaping (_ Success: [[String:Any]]?, _ error: String?) -> ()) {
        let params: [String:Any] = [
            APIClient.Params.serverKey: APIClient.SERVER_KEY.Server_Key,
            APIClientCustom.Params.fetch: fetch,
            APIClient.Params.userId: UserData.getUSER_ID() ?? "",
            APIClientCustom.Params.limit: limit,
            APIClientCustom.Params.offset: offset
        ]
        let token = UserData.getAccess_Token() ?? ""
        let url = APIClientCustom.GetCommunity.getCommunityApi + "&access_token=\(token)"
        AF.request(url, method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            if let value = response.value as? [String:Any] {
                if let data = value["data"] as? [[String:Any]] {
                    completionBlock(data, nil)
                } else {
                    completionBlock(nil, "No data found")
                }
            } else {
                completionBlock(nil, response.error?.localizedDescription ?? "Network error")
            }
        }
    }
    
    static let sharedInstance = CommunityManager()
    private init() {}
    
}
