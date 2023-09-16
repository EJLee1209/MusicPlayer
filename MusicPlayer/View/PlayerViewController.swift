//
//  ViewController.swift
//  MusicPlayer
//
//  Created by 이은재 on 2023/09/16.
//

import UIKit
import Combine

class PlayerViewController: UIViewController {
    
    //MARK: - Properties
    private var cancellables: Set<AnyCancellable> = .init()
    private let viewModel: MainViewModel

    
    //MARK: - init
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
        bind()
    }
    
    //MARK: - Helpers
    private func layout() {
        view.backgroundColor = .systemBlue
    }
    
    private func bind() {
        viewModel.songPublisher
            .sink { song in
                print(song)
            }.store(in: &cancellables)
        
    }
}

