import UIKit

class ErrorViewController: UIViewController {
    
    private let message: String // Store the error message
    var reloadAction: (() -> Void)? // Closure to hold the refresh function reference
    
    // Initialize with a message
    init(message: String) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarAppearance()
        setupUI()
    }
    private func setupNavigationBarAppearance() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            
            appearance.backgroundColor = UIColor(red: 0.25, green: 0.38, blue: 0.58, alpha: 1.0)
            
            appearance.titleTextAttributes = [
                      .foregroundColor: UIColor.white,
                      .font: UIFont.systemFont(ofSize: 20, weight: .bold)
                  ]
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.isTranslucent = false
        } else {
            navigationController?.navigationBar.barTintColor = UIColor(red: 0.25, green: 0.38, blue: 0.58, alpha: 1.0)
            navigationController?.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 20, weight: .bold)
            ]
            navigationController?.navigationBar.isTranslucent = false
        }
        
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .yellow
    }
    
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.25, green: 0.38, blue: 0.58, alpha: 1.0)

        // Cloud Icon
        let cloudImageView = UIImageView(image: UIImage(systemName: "cloud.fill"))
        cloudImageView.tintColor = .systemGray
        cloudImageView.contentMode = .scaleAspectFit
        
        // Warning Triangle
        let warningImageView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
        warningImageView.tintColor = .systemYellow
        warningImageView.contentMode = .scaleAspectFit

        // ZStack to Combine Icons
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(cloudImageView)
        iconContainer.addSubview(warningImageView)
        
        // Error Message Label
        let errorLabel = UILabel()
        errorLabel.text = message  // Display the passed message
        errorLabel.textAlignment = .center
        errorLabel.textColor = .white
        errorLabel.numberOfLines = 0
        errorLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        // Reload Button
        let reloadButton = UIButton(type: .system)
        reloadButton.setTitle("Reload", for: .normal)
        reloadButton.backgroundColor = .systemYellow
        reloadButton.setTitleColor(.black, for: .normal)
        reloadButton.layer.cornerRadius = 10
        reloadButton.addTarget(self, action: #selector(reloadTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [iconContainer, errorLabel, reloadButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
         
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 120),
            iconContainer.heightAnchor.constraint(equalToConstant: 120),
            reloadButton.widthAnchor.constraint(equalToConstant: 120),
            reloadButton.heightAnchor.constraint(equalToConstant: 44),
            errorLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
        
        // Constraints for Cloud Image
        cloudImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cloudImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            cloudImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            cloudImageView.widthAnchor.constraint(equalToConstant: 100),
            cloudImageView.heightAnchor.constraint(equalToConstant: 100),
        ])
        
        // Constraints for Warning Triangle
        warningImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            warningImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            warningImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor, constant: 25),
            warningImageView.widthAnchor.constraint(equalToConstant: 40),
            warningImageView.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    @objc private func reloadTapped() {
        navigationController?.popViewController(animated: true)
        reloadAction?()  // Call the refresh function
    }
}
