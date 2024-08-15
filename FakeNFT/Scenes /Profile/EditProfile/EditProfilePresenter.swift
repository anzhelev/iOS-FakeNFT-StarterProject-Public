//
//  EditProfilePresenter.swift
//  FakeNFT
//
//  Created by Andrey Lazarev on 14.08.2024.
//

import UIKit

protocol EditProfilePresenterProtocol {
    func updateAndNotify(text: [String], completion: @escaping () -> Void)
    var editedText: [String] { get set }
    var tableHeaders: [String] { get }
    var profile: Profile { get set }
}

final class EditProfilePresenter: EditProfilePresenterProtocol {
    
    weak var view: EditProfileViewProtocol?
    
    var editedText = [String]()
    
    var tableHeaders = ["Имя", "Описание", "Сайт"]
    
    var profile: Profile
    
    private var profileService: EditProfileServiceProtocol
    
    init(profileService: EditProfileServiceProtocol, profile: Profile) {
        self.profileService = profileService
        self.profile = profile
    }
    
    func updateAndNotify(text: [String], completion: @escaping () -> Void) {
        let updatedProfile = convertStringToProfile(text: text)
        
        let group = DispatchGroup()
        
        group.enter()
        
        updateData(profile: updatedProfile, completion: {
            group.leave()
        })
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    private func updateData(profile: Profile, completion: @escaping () -> Void) {
        profileService.updateProfile(profile: profile) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let profileResult):
                self.profile = Profile(
                    name: profileResult.name,
                    description: profileResult.description,
                    website: profileResult.website
                )
                completion()
                
            case .failure:
                print("Update failed")
                completion()
            }
        }
    }
    
    private func convertStringToProfile(text: [String]) -> Profile {
        Profile(
            name: text[0],
            description: text[1],
            website: text[2]
        )
    }
}
