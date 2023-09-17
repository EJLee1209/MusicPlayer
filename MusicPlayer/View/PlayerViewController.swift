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
import SnapKit
import SDWebImage

class PlayerViewController: UIViewController {
    //MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.bold(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .center
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.regular(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .center
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()

    private let spacer1: UIView = .init()
    
    private let albumImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.addCornerRadius(8)
        return iv
    }()
    
    private lazy var lyricTableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight = 30
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "lyricCell")
        tv.showsVerticalScrollIndicator = false
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.allowsSelection = false
        return tv
    }()
    
    private let spacer2: UIView = .init()
    
    private let playerView: PlayerHelperView = .init()
    
    private lazy var vStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, artistLabel, spacer1, albumImageView, spacer1, lyricTableView, spacer2, playerView])
        sv.axis = .vertical
        sv.spacing = 2
        sv.alignment = .center
        return sv
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
        
        setupNav()
        layout()
        bind()
    }
    
    //MARK: - Helpers
    private func setupNav() {
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    private func layout() {
        view.backgroundColor = .black
        view.addSubview(vStackView)
        vStackView.snp.makeConstraints { make in
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-50)
        }
        
        spacer1.snp.makeConstraints { make in
            make.size.equalTo(20)
        }
        
        albumImageView.snp.makeConstraints { make in
            make.size.equalTo(view.frame.width * 0.7)
        }
        
        lyricTableView.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width)
            make.height.equalTo(90)
        }
        
        playerView.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width * 0.8)
        }
        
    }
    
    private func bind() {
        // view binding
        viewModel.songAlbum
            .assign(to: \.title, on: navigationItem)
            .store(in: &cancellables)
        
        viewModel.songTitle
            .assign(to: \.text, on: self.titleLabel)
            .store(in: &cancellables)
        
        viewModel.songArtist
            .assign(to: \.text, on: self.artistLabel)
            .store(in: &cancellables)
        
        viewModel.songImageUrl
            .sink { [weak self] url in
                
                self?.albumImageView.sd_setImage(with: url)
            }.store(in: &cancellables)
        
        viewModel.lyricsSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.lyricTableView.reloadData()
            }.store(in: &cancellables)
        
        viewModel.lyricIndex
            .dropFirst()
            .sink { [weak self] idx in
                self?.highlightLyric(for: idx)
            }.store(in: &cancellables)
        
        // 노래 api 요청
        viewModel.requestMusic()
        
        playerView.bind(viewModel: self.viewModel)
        
    }
    
    private func highlightLyric(for row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        
        lyricTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        lyricTableView.reloadData()
    }
}

extension PlayerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.lyricsSubject.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lyricCell", for: indexPath)
        cell.textLabel?.text = viewModel.lyricsSubject.value[indexPath.row].1
        cell.textLabel?.textColor = viewModel.lyricIndex.value == indexPath.row ? .white : ThemeColor.gray
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = .clear
        return cell
    }
}
