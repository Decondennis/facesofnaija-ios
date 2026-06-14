
import Foundation
import Alamofire



class JoinCommunityManager {
    
    func joinCommunity(communityId : Int,completionBlock : @escaping (_ Success:JoinCommunityModel.JoinCommunity_SuccessModel?, _ AuthError : JoinCommunityModel.JoinCommunity_ErrorModel? , Error?)->()) {
        
    let params = [APIClient.Params.serverKey : APIClient.SERVER_KEY.Server_Key, APIClientCustom.Params.communityId : communityId] as [String : Any]
        let access_token = "\("?")\("access_token")\("=")\(UserData.getAccess_Token()!)"
        
        AF.request(APIClientCustom.JoinCommunity.joinCommunityAPi + access_token, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if response.value != nil {
            guard let res = response.value as? [String:Any] else {return}
            guard let apiStatusCode = res["api_status"]  as? Any else {return}
            let apiCode = apiStatusCode as? Int
                if apiCode == 200 {
                guard let data = try? JSONSerialization.data(withJSONObject: response.value, options: []) else {return}
                guard let result = try? JSONDecoder().decode(JoinCommunityModel.JoinCommunity_SuccessModel.self, from: data) else {return}
                completionBlock(result,nil,nil)
                }
                else {
                    guard let data = try? JSONSerialization.data(withJSONObject: response.value, options: []) else {return}
                    guard let result = try? JSONDecoder().decode(JoinCommunityModel.JoinCommunity_ErrorModel.self, from: data) else {return}
                    completionBlock(nil,result,nil)
                }
                
            }
            else {
                print(response.error?.localizedDescription)
                completionBlock(nil,nil,response.error)
            }
        }
        
    }
    
    static let sharedInstance = JoinCommunityManager()
    private init() {}
    
}
