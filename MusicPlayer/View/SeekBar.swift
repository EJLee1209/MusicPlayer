//
//  SeekBar.swift
//  MusicPlayer
//
//  Created by 이은재 on 2023/09/16.
//

import UIKit
import Combine
import CombineCocoa

final class SeekBar: UIView {
    
    //MARK: - Properties
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.isHidden = true
        return label
    }()
    
    private let trackView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeColor.gray
        return view
    }()
    
    private let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeColor.primary
        return view
    }()
    
    var progressUnit: CGFloat = 0.0
    private var isSliding: Bool = false
    
    private var progressSubject: CurrentValueSubject<CGFloat, Never> = .init(0.0)
    
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
        addSubview(trackView)
        trackView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(10)
        }
        trackView.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(0)
        }
        
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(trackView.snp.top).offset(-4)
            make.centerX.equalTo(trackView)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        timeLabel.isHidden = false
        isSliding = true
        
        trackView.snp.updateConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
        
        UIView.animate(withDuration: 0.3, animations: self.layoutIfNeeded)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isSliding = false
        timeLabel.isHidden = true
        
        trackView.snp.updateConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(10)
        }
        
        UIView.animate(withDuration: 0.3, animations: self.layoutIfNeeded)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if let touch = touches.first {
            let currentLocation = touch.location(in: self)
            
            if currentLocation.x >= 0 && currentLocation.x <= trackView.frame.maxX {
                progressView.snp.updateConstraints { make in
                    make.left.top.bottom.equalToSuperview()
                    make.width.equalTo(currentLocation.x)
                }
                progressSubject.send(currentLocation.x / progressUnit)
            }
            
        }
    }
    
    func bind(viewModel: MainViewModel) {
        viewModel.totalTimePublisher
            .dropFirst()
            .sink { [weak self] totalTime in
                self?.progressUnit = (self?.trackView.frame.width ?? 0.0) / CGFloat(totalTime)
            }.store(in: &cancellables)
        
        viewModel.elapsedTimePublisher
            .sink { [weak self] time in
                self?.elapsedTime(time: time)
            }.store(in: &cancellables)
        
        progressSubject.sink { progress in
            viewModel.progress.send(progress)
        }.store(in: &cancellables)
        
        viewModel.progressPublisher
            .assign(to: \.text, on: self.timeLabel)
            .store(in: &cancellables)
        
    }
    
    private func elapsedTime(time: Float) {
        if isSliding { return }
        
        progressView.snp.updateConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(progressUnit * CGFloat(time))
        }
    }
}
