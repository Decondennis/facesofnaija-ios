
import UIKit
import Kingfisher

class ReactionCells: UICollectionViewCell {
    
    @IBOutlet weak var tableView: UITableView!
    
    var reactions = [[String:Any]]()
    
    override func awakeFromNib() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .white
        self.tableView.tableFooterView = UIView()
    }
    
}
extension ReactionCells : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.reactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Postreactioncell") as? PostReactionCell else {
            return UITableViewCell()
        }
        guard indexPath.row < self.reactions.count else { return cell }
        let index = self.reactions[indexPath.row]
        let name = (index["username"] as? String) ?? (index["name"] as? String) ?? ""
        cell.profileName?.text = name
        if let lastSeen = index["lastseen_time_text"] as? String, !lastSeen.isEmpty {
            cell.lastSeen?.text = "Last seen \(lastSeen)"
        } else {
            cell.lastSeen?.text = ""
        }
        if let proImage = index["avatar"] as? String, let url = URL(string: proImage) {
            cell.profileImage?.kf.setImage(with: url)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    

    
    
}
