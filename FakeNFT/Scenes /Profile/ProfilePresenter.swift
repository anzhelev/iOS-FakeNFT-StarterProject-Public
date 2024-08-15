//
//  ProfilePresenter.swift
//  FakeNFT
//
//  Created by Andrey Lazarev on 15.08.2024.
//

import UIKit

protocol ProfilePresenterProtocol {
    func viewDidLoad()
    func updateProfileTexts()
    var _profileDescription: [String] { get set }
    var tableNames: [String] { get }
    var profile: Profile? { get set }
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileViewProtocol?
    
    var _profileDescription = ["Joaquin Phoenix", "Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100+ NFT, и еще больше — на моём сайте. Открыт к коллаборациям.", "Joaquin Phoenix.com"]
    
    let tableNames = ["Мои NFT", "Избранные NFT", "О разработчике"]
    
    var profile: Profile?
    
    private let profileService: ProfileServiceProtocol
    
    init(profileService: ProfileServiceProtocol) {
        self.profileService = profileService
    }
    
    func viewDidLoad() {

        loadData()
    }
    
    func updateProfileTexts() {
        guard let view = view, let profile else { return }
        
        view.authorName.text = profile.name
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7
        let attributedString = NSAttributedString(
            string: profile.description,
            attributes: [
                .font: UIFont.caption2,
                .paragraphStyle: paragraphStyle
            ])
        view.authorDescription.attributedText = attributedString
        adjustTextViewHeight(view.authorDescription)
        
        view.authorLink.text = profile.website
    }
    
    func adjustTextViewHeight(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .greatestFiniteMagnitude)
        var estimatedSize = textView.sizeThatFits(size)
        
        if estimatedSize.width == 0 {
            estimatedSize.height = 0
        }
        
        var frame = textView.frame
        frame.size.height = estimatedSize.height
        textView.frame = frame
        
        view?.updateConstraintsForTextView(textView, estimatedSize)
    }
    
    private func loadData() {
        
        profileService.loadProfile { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .success(let profileResult):
                profile = convertIntoModel(model: profileResult)
                view?.onProfileLoaded(profile!)
            case .failure:
                print(4)
            }
        }
    }
    
    
    private func convertIntoModel(model: ProfileResult) -> Profile {
        Profile(
            name: model.name,
            description: model.description,
            website: model.website
        )
    }
}
