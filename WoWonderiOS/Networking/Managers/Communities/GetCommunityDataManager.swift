

import Foundation
import Alamofire


class GetCommunityDataManager{
    
    func getData(communityId: String,completionBlock :@escaping (_ Success: GetCommunityDataModel.GetCommunityData_SuccessModel?, _ AuthError: GetCommunityDataModel.GetCommunityData_ErrorModel?, Error?)->()){
        
        let params = [APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,APIClientCustom.Params.community_id:communityId]
        let access_token = "\("?")\("access_token")\("=")\(UserData.getAccess_Token()!)"
        print("This is before the community data is loaded :" + communityId)
        print("The API is "+APIClientCustom.GetCommunityData.getCommunitiesDataApi)
        
        AF.request(APIClientCustom.GetCommunityData.getCommunitiesDataApi + access_token, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            print(response)
            if response.value != nil {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatusCode = res["api_status"] as? Any else {return}
                if apiStatusCode as? Int == 200 {
                    let result = GetCommunityDataModel.GetCommunityData_SuccessModel.init(json: res)
                    completionBlock(result,nil,nil)
                }
                else{
                    guard let data = try? JSONSerialization.data(withJSONObject: response.value, options: []) else {return}
                    guard let result = try? JSONDecoder().decode(GetCommunityDataModel.GetCommunityData_ErrorModel.self, from: data) else {return}
                    completionBlock(nil,result,nil)
                }
            }
            else{
                print(response.error?.localizedDescription)
                completionBlock(nil,nil,response.error)
            }
            print("Finished rendering")
        }
    }
    
    static let sharedInstance = GetCommunityDataManager()
    private init() {}
}
