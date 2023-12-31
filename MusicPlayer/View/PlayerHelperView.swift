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
    private let seekBar: SeekBar = .init()
    
    private let elapsedTimeLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.bold(ofSize: 12)
        label.textColor = ThemeColor.primary
        label.text = "00:00"
        return label
    }()
    
    private let totalTimeLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.bold(ofSize: 12)
        label.textColor = ThemeColor.gray
        label.text = "00:00"
        return label
    }()
    
    private lazy var hStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [elapsedTimeLabel, totalTimeLabel])
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        return sv
    }()
    
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    private lazy var vStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [seekBar,hStackView,playButton])
        sv.axis = .vertical
        sv.spacing = 8
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
            make.height.equalTo(30)
        }
        
        hStackView.snp.makeConstraints { make in
            make.width.equalTo(vStackView.snp.width)
        }
        
        playButton.snp.makeConstraints { make in
            make.size.equalTo(28)
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
        
        viewModel.formatedElapsedTimePublisher
            .assign(to: \.text, on: self.elapsedTimeLabel)
            .store(in: &cancellables)
        
        viewModel.formatedTotalTimePublisher
            .assign(to: \.text, on: self.totalTimeLabel)
            .store(in: &cancellables)
        
        seekBar.bind(viewModel: viewModel)
    }
}

