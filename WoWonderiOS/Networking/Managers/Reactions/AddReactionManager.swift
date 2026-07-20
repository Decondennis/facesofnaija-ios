

import Foundation
import Alamofire

class AddReactionManager {
    
    func addReaction(postId: String, reaction: String, completionBlock: @escaping (_ Success: AddReactions.AddReactions_SuccessModel?, _ AuthError: AddReactions.AddReaction_ErrorModel?, Error?) -> ()) {
        let params: [String:Any] = [
            APIClient.Params.serverKey: APIClient.SERVER_KEY.Server_Key,
            "reaction": reaction,
            APIClient.Params.action: "reaction",
            APIClient.Params.postId: postId
        ]
        let token = UserData.getAccess_Token() ?? ""
        let url = APIClient.AddReactions.addReactionApi + "&access_token=\(token)"
        AF.request(url, method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            if let value = response.value as? [String:Any] {
                let apiStatus = value["api_status"] as? Int ?? 0
                if apiStatus == 200 {
                    if let data = try? JSONSerialization.data(withJSONObject: value, options: []),
                       let result = try? JSONDecoder().decode(AddReactions.AddReactions_SuccessModel.self, from: data) {
                        completionBlock(result, nil, nil)
                    } else {
                        completionBlock(nil, nil, nil)
                    }
                } else {
                    if let data = try? JSONSerialization.data(withJSONObject: value, options: []),
                       let result = try? JSONDecoder().decode(AddReactions.AddReaction_ErrorModel.self, from: data) {
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
    
    static let sharedInstance = AddReactionManager()
    private init() {}
}
