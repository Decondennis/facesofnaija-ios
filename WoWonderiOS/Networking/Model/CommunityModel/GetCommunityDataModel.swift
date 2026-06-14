
import Foundation

class GetCommunityDataModel{
    
    struct GetCommunityData_SuccessModel{
        let api_status: Int
        let community_data: [String:Any]
    }
    
      struct GetCommunityData_ErrorModel:Codable{
        let apiStatus: String
        let errors: Errors
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case errors
        }
    }
    
    // MARK: - Errors
    struct Errors: Codable {
        let errorID: Int
        let errorText: String
        
        enum CodingKeys: String, CodingKey {
            case errorID = "error_id"
            case errorText = "error_text"
        }
    }
}

extension GetCommunityDataModel.GetCommunityData_SuccessModel{
    init(json : [String:Any]) {
        let api_status = json["api_status"] as? Int
        let data = json["community_data"] as? [String:Any]
        self.api_status = api_status ?? 0
        self.community_data = data ?? ["PostType" : "Profile_Pic"]
    }
}


