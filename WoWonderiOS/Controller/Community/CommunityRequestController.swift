import UIKit
import Toast_Swift
import ZKProgressHUD

class CommunityRequestController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var privacy = 0
    var isHome = 0
    let status = Reach().connectionStatus()
    private let categories = ["General", "Education", "Business", "Technology", "Entertainment", "Sports", "Health", "Music", "Art", "Other"]
    private var selectedCategory = "General"
    
    func setCommunityName(_ name: String) { nameField.text = name }
    func setDescription(_ desc: String) { descField.text = desc }
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.backgroundColor = .systemBackground
        return sv
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.layoutMargins = UIEdgeInsets(top: 20, left: 24, bottom: 40, right: 24)
        sv.isLayoutMarginsRelativeArrangement = true
        return sv
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Request Community"
        l.font = UIFont.boldSystemFont(ofSize: 24)
        l.textAlignment = .center
        return l
    }()
    
    private let nameField: UITextField = {
        let f = UITextField()
        f.placeholder = "Community Name *"
        f.borderStyle = .roundedRect
        f.font = UIFont.systemFont(ofSize: 16)
        return f
    }()
    
    private let titleField: UITextField = {
        let f = UITextField()
        f.placeholder = "Community Title *"
        f.borderStyle = .roundedRect
        f.font = UIFont.systemFont(ofSize: 16)
        return f
    }()
    
    private let descField: UITextField = {
        let f = UITextField()
        f.placeholder = "About / Description *"
        f.borderStyle = .roundedRect
        f.font = UIFont.systemFont(ofSize: 16)
        return f
    }()
    
    private let categoryField: UITextField = {
        let f = UITextField()
        f.placeholder = "Category *"
        f.borderStyle = .roundedRect
        f.font = UIFont.systemFont(ofSize: 16)
        return f
    }()
    
    private let reasonField: UITextField = {
        let f = UITextField()
        f.placeholder = "Reason for request *"
        f.borderStyle = .roundedRect
        f.font = UIFont.systemFont(ofSize: 16)
        return f
    }()
    
    private let pickerView = UIPickerView()
    
    private let privacyLabel: UILabel = {
        let l = UILabel()
        l.text = "Privacy *"
        l.font = UIFont.boldSystemFont(ofSize: 16)
        return l
    }()
    
    private let privacyStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let publicBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Public", for: .normal)
        b.backgroundColor = .white
        b.setTitleColor(.darkGray, for: .normal)
        b.layer.cornerRadius = 10
        b.layer.borderWidth = 1.5
        b.layer.borderColor = UIColor.lightGray.cgColor
        b.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return b
    }()
    
    private let privateBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Private", for: .normal)
        b.backgroundColor = .white
        b.setTitleColor(.darkGray, for: .normal)
        b.layer.cornerRadius = 10
        b.layer.borderWidth = 1.5
        b.layer.borderColor = UIColor.lightGray.cgColor
        b.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return b
    }()
    
    private let submitBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Send", for: .normal)
        b.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 22
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        b.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = ""
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: " Back", style: .plain, target: self, action: #selector(goBack))
        navigationController?.navigationBar.isHidden = false
        
        pickerView.delegate = self
        pickerView.dataSource = self
        categoryField.inputView = pickerView
        categoryField.text = selectedCategory
        
        setupViews()
        setupActions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        privacyStack.addArrangedSubview(publicBtn)
        privacyStack.addArrangedSubview(privateBtn)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.setCustomSpacing(24, after: titleLabel)
        stackView.addArrangedSubview(nameField)
        stackView.addArrangedSubview(titleField)
        stackView.addArrangedSubview(descField)
        stackView.addArrangedSubview(categoryField)
        stackView.addArrangedSubview(reasonField)
        stackView.setCustomSpacing(8, after: reasonField)
        stackView.addArrangedSubview(privacyLabel)
        stackView.addArrangedSubview(privacyStack)
        stackView.setCustomSpacing(32, after: privacyStack)
        stackView.addArrangedSubview(submitBtn)
    }
    
    private func setupActions() {
        publicBtn.addTarget(self, action: #selector(didTapPublic), for: .touchUpInside)
        privateBtn.addTarget(self, action: #selector(didTapPrivate), for: .touchUpInside)
        submitBtn.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
    }
    
    @objc private func didTapPublic() {
        privacy = 1
        publicBtn.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
        publicBtn.setTitleColor(.white, for: .normal)
        privateBtn.backgroundColor = .white
        privateBtn.setTitleColor(.darkGray, for: .normal)
    }
    
    @objc private func didTapPrivate() {
        privacy = 2
        privateBtn.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
        privateBtn.setTitleColor(.white, for: .normal)
        publicBtn.backgroundColor = .white
        publicBtn.setTitleColor(.darkGray, for: .normal)
    }
    
    @objc private func didTapSend() {
        guard let name = nameField.text, !name.isEmpty else {
            view.makeToast("Enter Community Name")
            return
        }
        guard let title = titleField.text, !title.isEmpty else {
            view.makeToast("Enter Community Title")
            return
        }
        guard let desc = descField.text, !desc.isEmpty else {
            view.makeToast("Enter Description")
            return
        }
        guard let reason = reasonField.text, !reason.isEmpty else {
            view.makeToast("Enter Reason for Request")
            return
        }
        guard privacy != 0 else {
            view.makeToast("Select Privacy")
            return
        }
        sendRequest(name: name, title: title, desc: desc, category: selectedCategory, reason: reason)
    }
    
    private func sendRequest(name: String, title: String, desc: String, category: String, reason: String) {
        switch status {
        case .unknown, .offline:
            showAlert(title: "", message: "Internet Connection Failed")
        case .online(.wwan), .online(.wiFi):
            ZKProgressHUD.show()
            CommunityManager.sharedInstance.requestCommunity(name: name, communityTitle: title, about: desc, category: category, reason: reason, privacy: privacy) { success, authError, error in
                ZKProgressHUD.dismiss()
                if success != nil {
                    self.view.makeToast("Community Request Submitted")
                    self.navigationController?.popViewController(animated: true)
                } else if authError != nil {
                    self.view.makeToast(authError?.errors.errorText ?? "Error")
                } else {
                    print(error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    // MARK: - Picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return categories.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { return categories[row] }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
        categoryField.text = selectedCategory
    }
}
