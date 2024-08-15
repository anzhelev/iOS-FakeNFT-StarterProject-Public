import UIKit

protocol ProfileViewProtocol: AnyObject {
    func viewDidLoad()
    func updateConstraintsForTextView(_ textView: UITextView, _ estimatedSize: CGSize)
    func onProfileLoaded(_ profile: Profile)
    var authorName: UILabel { get set }
    var authorDescription: UITextView { get set }
    var authorLink: UILabel { get set }
}

final class ProfileViewController: UIViewController, ProfileViewProtocol {
    
    private var presenter: ProfilePresenterProtocol
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var authorName: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .headline3
        title.textColor = .textPrimary
        return title
    }()
    
    lazy var authorDescription: UITextView = {
        let text = UITextView()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.textColor = .textPrimary
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7
        let attributedString = NSAttributedString(
            string: "",
            attributes: [
                .font: UIFont.caption2,
                .paragraphStyle: paragraphStyle
            ])
        text.attributedText = attributedString
        text.isEditable = false
        return text
    }()
    
    lazy var authorImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 16
        image.image = UIImage(named: "User Pic")
        return image
    }()
    
    lazy var authorLink: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .caption1
        title.textColor = .primary
        return title
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 54
        tableView.separatorStyle = .none
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var textViewHeightConstraint: NSLayoutConstraint?
    private var containerViewHeightConstraint: NSLayoutConstraint?
    
    init(presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        setupConstraints()
        
        hideUIElements()
        
        presenter.viewDidLoad()
        
    }
    
    func updateUI(with profile: Profile) {
        presenter.updateProfileTexts()
        showUIElements()
    }
    
    func onProfileLoaded(_ profile: Profile) {
        self.updateUI(with: profile)
    }
    
    private func setupUI() {
        let editButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(editButtonTapped))
        editButton.tintColor = .tabBarItemsTintColor
        navigationItem.rightBarButtonItem = editButton
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(containerView)
        containerView.addSubview(authorName)
        containerView.addSubview(authorImage)
        containerView.addSubview(authorDescription)
        containerView.addSubview(authorLink)
        
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        textViewHeightConstraint = authorDescription.heightAnchor.constraint(lessThanOrEqualToConstant: 80)
        textViewHeightConstraint?.isActive = true
        
        containerViewHeightConstraint = containerView.heightAnchor.constraint(lessThanOrEqualToConstant: 200)
        containerViewHeightConstraint?.isActive = true
        
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            authorName.leadingAnchor.constraint(equalTo: authorImage.trailingAnchor, constant: 16),
            authorName.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            authorName.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 21),
            authorName.centerYAnchor.constraint(equalTo: authorName.centerYAnchor),
            
            authorDescription.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            authorDescription.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -18),
            authorDescription.topAnchor.constraint(equalTo: authorImage.bottomAnchor, constant: 20),
            authorDescription.heightAnchor.constraint(lessThanOrEqualToConstant: 80),
            
            authorImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            authorImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            authorImage.heightAnchor.constraint(equalToConstant: 70),
            authorImage.widthAnchor.constraint(equalToConstant: 70),
            
            authorLink.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            authorLink.topAnchor.constraint(equalTo: authorDescription.bottomAnchor, constant: 8),
            
            tableView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 40),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 162)
        ])
        
    }
    
    private func hideUIElements() {
        view.isHidden = true
    }

    private func showUIElements() {
        view.isHidden = false
    }
    
    @objc private func editButtonTapped() {
        let editProfileViewController = EditProfileViewController()
        editProfileViewController.delegate = self
        let editNavController = UINavigationController(rootViewController: editProfileViewController)
        present(editNavController, animated: true)
    }
    
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.tableNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ProfileTableViewCell else {
            return UITableViewCell()
        }
        
        cell.title.text = presenter.tableNames[indexPath.row]
        
        return cell
    }
}

extension ProfileViewController: SendProfileTextProtocol {
    var profileDescription: [String] {
        get {
            guard let profile = presenter.profile else { return [] }
            return profileToArray(profile: profile)
        }
        
        set {
            presenter._profileDescription = newValue
        }
    }
    
    func sendText(_ text: [String]) {
        presenter.updateProfileTexts()
        profileDescription = text
    }
    
    func updateConstraintsForTextView(_ textView: UITextView, _ estimatedSize: CGSize) {
        textViewHeightConstraint?.isActive = false
        containerViewHeightConstraint?.isActive = false
        
        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: estimatedSize.height + 8)
        textViewHeightConstraint?.isActive = true
        
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: estimatedSize.height + 137)
        containerViewHeightConstraint?.isActive = true
        
        self.view.layoutIfNeeded()
    }
    
    func profileToArray(profile: Profile) -> [String] {
        return [profile.name, profile.description, profile.website]
    }
}
