

import Foundation

class SharePostOnTimlineModal{
    
    struct SharePostOnTimeline_SuccessModal{
        var api_status :Int
        var data :[String:Any]
    }
    
    struct SharePostOnTimeline_ErrorModal :Codable{
        let apiStatus: String
        let errors: Errors
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case errors
        }
        
        init(apiStatus: String, errors: Errors) {
            self.apiStatus = apiStatus
            self.errors = errors
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let stringStatus = try? container.decode(String.self, forKey: .apiStatus) {
                self.apiStatus = stringStatus
            } else if let intStatus = try? container.decode(Int.self, forKey: .apiStatus) {
                self.apiStatus = "\(intStatus)"
            } else {
                self.apiStatus = "400"
            }
            self.errors = try container.decode(Errors.self, forKey: .errors)
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
        
        init(errorID: Int, errorText: String) {
            self.errorID = errorID
            self.errorText = errorText
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let intId = try? container.decode(Int.self, forKey: .errorID) {
                self.errorID = intId
            } else if let stringId = try? container.decode(String.self, forKey: .errorID) {
                self.errorID = Int(stringId) ?? 0
            } else {
                self.errorID = 0
            }
            self.errorText = (try? container.decode(String.self, forKey: .errorText)) ?? ""
        }
    }
}
extension SharePostOnTimlineModal.SharePostOnTimeline_SuccessModal{
    init(json :[String:Any]) {
        let apiStatus = (json["api_status"] as? Int) ?? Int((json["api_status"] as? String) ?? "") ?? 0
        let data = json["data"] as? [String:Any]
        self.api_status = apiStatus
        self.data = data ?? ["id" : "1234"]
    }
    
}
