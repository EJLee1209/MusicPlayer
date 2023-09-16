//
//  PlayerHelperView.swift
//  MusicPlayer
//
//  Created by 이은재 on 2023/09/16.
//

import UIKit
import Combine
import CombineCocoa

final class PlayerHelperView: UIView {
    
    //MARK: - Properties
    private let seekBar: UIProgressView = {
        let view = UIProgressView()
        view.progressTintColor = ThemeColor.primary
        view.trackTintColor = ThemeColor.gray
        view.progress = 0.5
        return view
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        return button
    }()
    
    private lazy var vStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [seekBar,playButton])
        sv.axis = .vertical
        sv.spacing = 30
        sv.alignment = .center
        sv.distribution = .fillProportionally
        return sv
    }()
    
    private var cancellables: Set<AnyCancellable> = .init()
    
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    private func layout() {
        addSubview(vStackView)
        vStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        seekBar.snp.makeConstraints { make in
            make.width.equalTo(vStackView.snp.width)
        }
        
        playButton.snp.makeConstraints { make in
            make.size.equalTo(30)
        }
        
        playButton.imageView?.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    func bind(viewModel: MainViewModel) {
        playButton.tapPublisher
            .sink { _ in
                viewModel.togglePlayState()
            }.store(in: &cancellables)
        
        viewModel.isPlaying
            .sink { [weak self] state in
                if state {
                    self?.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                } else {
                    self?.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                }
            }.store(in: &cancellables)
    }
}

