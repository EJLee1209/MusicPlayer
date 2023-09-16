//
//  ViewController.swift
//  MusicPlayer
//
//  Created by 이은재 on 2023/09/16.
//

/*
 *** 음악 재생 화면 요구 사항 ***
 주어진 노래의 재생 화면이 노출됩니다.
 앨범 커버 이미지, 앨범명, 아티스트명, 곡명이 함께 보여야 합니다.
 재생 버튼을 누르면 음악이 재생됩니다. (1개의 음악 파일을 제공할 예정)
 재생 시 현재 재생되고 있는 구간대의 가사가 실시간으로 표시됩니다.
 정지 버튼을 누르면 재생 중이던 음악이 멈춥니다.
 seekbar를 조작하여 재생 시작 시점을 이동시킬 수 있습니다.
 */

import UIKit
import Combine

class PlayerViewController: UIViewController {
    //MARK: - Properties
    private let albumLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.regular(ofSize: 13)
        label.textColor = ThemeColor.gray
        return label
    }()
    
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
        view.backgroundColor = .black
    }
    
    private func bind() {
        viewModel.songPublisher
            .sink { song in
                print(song)
                
            }.store(in: &cancellables)
        
    }
}

