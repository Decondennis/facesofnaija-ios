
import Foundation
import Alamofire

class JoinCommunityManager {
    
    func joinCommunity(communityId : Int, completionBlock : @escaping (_ Success: JoinCommunityModel.JoinCommunity_SuccessModel?, _ AuthError : JoinCommunityModel.JoinCommunity_ErrorModel?, Error?) -> ()) {
        
        let params: [String:Any] = [
            APIClient.Params.serverKey: APIClient.SERVER_KEY.Server_Key,
            "community_id": communityId
        ]
        let token = UserData.getAccess_Token() ?? ""
        let url = APIClientCustom.JoinCommunity.joinCommunityAPi + "&access_token=\(token)"
        
        AF.request(url, method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            if let value = response.value as? [String:Any] {
                let apiStatus = value["api_status"] as? Int ?? 0
                if apiStatus == 200 {
                    let result = JoinCommunityModel.JoinCommunity_SuccessModel(
                        api_status: value["api_status"] as? Int ?? 200,
                        join_status: value["join_status"] as? String ?? ""
                    )
                    completionBlock(result, nil, nil)
                } else {
                    if let data = try? JSONSerialization.data(withJSONObject: value, options: []),
                       let result = try? JSONDecoder().decode(JoinCommunityModel.JoinCommunity_ErrorModel.self, from: data) {
                        completionBlock(nil, result, nil)
                    } else {
                        completionBlock(nil, nil, nil)
                    }
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    static let sharedInstance = JoinCommunityManager()
    private init() {}
}
