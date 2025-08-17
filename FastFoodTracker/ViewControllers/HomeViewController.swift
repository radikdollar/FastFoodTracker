//
//  MainViewController.swift
//  EatTime
//
//  Created by Radion Vahromeev on 8/11/25.
//

import UIKit
import CoreData
import ImageIO

class HomeViewController: UIViewController {
    
    //MARK: - UI
    
    private lazy var mainLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.text = "Fast Food Tracker"
        $0.font = .systemFont(ofSize: 30, weight: .bold)
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    private lazy var secondLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "This application helps to track the eating of fast food to control a healthy lifestyle"
        return $0
    }(UILabel())
    
    private lazy var thirdLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "After eating, press the button and select the food that you ate, after which the date and time of taking this food will be displayed in the Eat Time tab"
        $0.textColor = .secondaryLabel
        return $0
    }(UILabel())
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        if let gifUrl = Bundle.main.url(forResource: "gif", withExtension: "gif"),
           let gifData = try? Data(contentsOf: gifUrl),
           let source = CGImageSourceCreateWithData(gifData as CFData, nil) {

            var images = [UIImage]()
            let count = CGImageSourceGetCount(source)

            for i in 0..<count {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    images.append(UIImage(cgImage: cgImage))
                }
            }
            imageView.animationImages = images
            imageView.animationDuration = 16.0
            imageView.startAnimating()
            
        }
        return imageView
    }()
    
    private lazy var button: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("Tap me", for: .normal)
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 10
        $0.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return $0
    }(UIButton())
    
    //MARK: - Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    //MARK: - Funcs and Methods
    
    private func setupUI() {
        
        view.backgroundColor = .white
        
        view.addSubview(mainLabel)
        view.addSubview(imageView)
        view.addSubview(secondLabel)
        view.addSubview(thirdLabel)
        view.addSubview(button)
        
        
        NSLayoutConstraint.activate([
            mainLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            imageView.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 40),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 250),
            imageView.heightAnchor.constraint(equalToConstant: 250),
            
            secondLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 40),
            secondLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            secondLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            thirdLabel.topAnchor.constraint(equalTo: secondLabel.bottomAnchor, constant: 20),
            thirdLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            thirdLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),

            button.heightAnchor.constraint(equalToConstant: 60)
            
            
        ])
    }
    
    
    @objc private func buttonAction() {
        let newEatTime: () = CoreDataManager.shared.addEatTime(date: Date())
        
        showToast(message: "Meal time was added")
        
        NotificationCenter.default.post(name: .newEatTimeAdded, object: newEatTime)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.tabBarController?.selectedIndex = 1
        }
    }

    
}

//MARK: - Extensions

private extension UIViewController {
    func showToast(message: String, duration: TimeInterval = 1.5) {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }

        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.font = .systemFont(ofSize: 20, weight: .medium)
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textAlignment = .center
        toastLabel.layer.cornerRadius = 20
        toastLabel.layer.masksToBounds = true

        let width = window.frame.width - 40
        toastLabel.frame = CGRect(x: 20, y: window.frame.height - 120, width: width, height: 35)
        toastLabel.alpha = 0

        window.addSubview(toastLabel)

        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}

extension Notification.Name {
    static let newEatTimeAdded = Notification.Name("newEatTimeAdded")
}
