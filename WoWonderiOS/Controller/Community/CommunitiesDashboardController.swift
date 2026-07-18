import UIKit
import SDWebImage

class CommunitiesDashboardController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let sections: [(title: String, subtitle: String, fetchKey: String)] = [
        ("Joined Communities", "Communities you have joined", "joined_communities"),
        ("All Communities", "Browse all communities", "random_communities"),
        ("Suggested Communities", "Recommended for you", "random_communities"),
        ("Requested Communities", "Your join requests", "requested_communities")
    ]
    var sectionData: [[[String:Any]]] = [[], [], [], []]
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Communities"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: " Back", style: .plain, target: self, action: #selector(goBack))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Request", style: .plain, target: self, action: #selector(openRequestForm))
        tableView.register(CommunityDashboardSectionCell.self, forCellReuseIdentifier: "SectionCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        loadAllSections()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    @objc func goBack() { navigationController?.popViewController(animated: true) }
    @objc func openRequestForm() {
        let sb = UIStoryboard(name: "Communities", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "CommunityRequestVC") as? CommunityRequestController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    func loadAllSections() {
        loadingIndicator.startAnimating()
        let group = DispatchGroup()
        for (i, s) in sections.enumerated() {
            group.enter()
            CommunityManager.sharedInstance.getCommunities(fetch: s.fetchKey, limit: 10, offset: 0) { success, _ in
                if let d = success { self.sectionData[i] = d }
                group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.loadingIndicator.stopAnimating()
            self?.tableView.reloadData()
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int { return 5 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SectionCell", for: indexPath) as! CommunityDashboardSectionCell
            cell.configure(with: sectionData[indexPath.section])
            cell.onSelect = { [weak self] c in self?.openCommunityDetail(c) }
            return cell
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "More community features coming soon..."
        cell.textLabel?.textColor = .gray
        cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 13)
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = .clear
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section >= 4 { return nil }
        let h = UIView()
        let t = UILabel()
        t.text = sections[section].title
        t.font = UIFont.boldSystemFont(ofSize: 20)
        t.translatesAutoresizingMaskIntoConstraints = false
        h.addSubview(t)
        let b = UIButton(type: .system)
        b.setTitle("See All", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.tag = section
        b.addTarget(self, action: #selector(seeAllTapped(_:)), for: .touchUpInside)
        h.addSubview(b)
        NSLayoutConstraint.activate([
            t.leadingAnchor.constraint(equalTo: h.leadingAnchor, constant: 16),
            t.centerYAnchor.constraint(equalTo: h.centerYAnchor),
            b.trailingAnchor.constraint(equalTo: h.trailingAnchor, constant: -16),
            b.centerYAnchor.constraint(equalTo: h.centerYAnchor)
        ])
        return h
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return section < 4 ? 44 : 0 }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return indexPath.section < 4 ? 200 : 60 }
    
    @objc func seeAllTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Communities", bundle: nil)
        switch sender.tag {
        case 0:
            if let vc = sb.instantiateViewController(withIdentifier: "MyCommunitiesVC") as? CommunityListController {
                navigationController?.pushViewController(vc, animated: true)
            }
        default:
            let vc = sb.instantiateViewController(withIdentifier: "ShowAllSuggestedCommunityVC")
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    func openCommunityDetail(_ community: [String:Any]) {
        let sb = UIStoryboard(name: "Communities", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "CommunityVC") as? CommunityController {
            vc.communityData = community
            vc.communityId = (community["community_id"] as? String) ?? (community["id"] as? String ?? "")
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

class CommunityDashboardSectionCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var communities: [[String:Any]] = []
    var onSelect: (([String:Any]) -> Void)?
    private let cv: UICollectionView = {
        let l = UICollectionViewFlowLayout()
        l.scrollDirection = .horizontal
        l.minimumLineSpacing = 12
        l.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let c = UICollectionView(frame: .zero, collectionViewLayout: l)
        c.showsHorizontalScrollIndicator = false
        c.backgroundColor = .clear
        c.translatesAutoresizingMaskIntoConstraints = false
        return c
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(cv)
        NSLayoutConstraint.activate([
            cv.topAnchor.constraint(equalTo: contentView.topAnchor),
            cv.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cv.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cv.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        cv.delegate = self
        cv.dataSource = self
        cv.register(CommunityCardCell.self, forCellWithReuseIdentifier: "CardCell")
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func configure(with data: [[String:Any]]) { communities = data; cv.reloadData() }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return max(communities.count, 1) }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CommunityCardCell
        if !communities.isEmpty { cell.configure(with: communities[indexPath.item]) }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !communities.isEmpty { onSelect?(communities[indexPath.item]) }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 180)
    }
}

class CommunityCardCell: UICollectionViewCell {
    private let coverIV: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(white: 0.9, alpha: 1)
        iv.layer.cornerRadius = 12
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private let avatarIV: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private let nameL: UILabel = {
        let l = UILabel()
        l.font = UIFont.boldSystemFont(ofSize: 13)
        l.textAlignment = .center
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let memberL: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 11)
        l.textColor = .gray
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor(white: 0.85, alpha: 1).cgColor
        contentView.addSubview(coverIV)
        contentView.addSubview(avatarIV)
        contentView.addSubview(nameL)
        contentView.addSubview(memberL)
        NSLayoutConstraint.activate([
            coverIV.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverIV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverIV.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverIV.heightAnchor.constraint(equalToConstant: 80),
            avatarIV.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarIV.topAnchor.constraint(equalTo: coverIV.bottomAnchor, constant: -20),
            avatarIV.widthAnchor.constraint(equalToConstant: 40),
            avatarIV.heightAnchor.constraint(equalToConstant: 40),
            nameL.topAnchor.constraint(equalTo: avatarIV.bottomAnchor, constant: 6),
            nameL.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            nameL.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            memberL.topAnchor.constraint(equalTo: nameL.bottomAnchor, constant: 2),
            memberL.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            memberL.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func configure(with data: [String:Any]) {
        let name = (data["name"] as? String) ?? (data["community_name"] as? String ?? "Community")
        nameL.text = name
        let cover = (data["cover"] as? String) ?? ""
        if let url = URL(string: cover) { coverIV.sd_setImage(with: url, placeholderImage: UIImage(named: "d-cover")) }
        let avatar = (data["avatar"] as? String) ?? (data["community_avatar"] as? String ?? "")
        if let url = URL(string: avatar) { avatarIV.sd_setImage(with: url, placeholderImage: UIImage(named: "no-avatar")) }
        let count = (data["members_count"] as? String) ?? "0"
        memberL.text = count + " members"
    }
}
