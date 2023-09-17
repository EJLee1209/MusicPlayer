//
//  ViewController.swift
//  MusicPlayer
//
//  Created by 이은재 on 2023/09/16.
//

/*
 *** 음악 재생 화면 요구 사항 ***
 주어진 노래의 재생 화면이 노출됩니다. (완료)
 앨범 커버 이미지, 앨범명, 아티스트명, 곡명이 함께 보여야 합니다. (완료)
 재생 버튼을 누르면 음악이 재생됩니다. (1개의 음악 파일을 제공할 예정) (완료)
 재생 시 현재 재생되고 있는 구간대의 가사가 실시간으로 표시됩니다. (완료)
 정지 버튼을 누르면 재생 중이던 음악이 멈춥니다. (완료)
 seekbar를 조작하여 재생 시작 시점을 이동시킬 수 있습니다. (완료)
 
 전체 가사 보기 화면
 전체 가사가 띄워진 화면이 있으며, 특정 가사 부분으로 이동할 수 있는 토글 버튼이 존재합니다.
 토글 버튼 on: 특정 가사 터치 시 해당 구간부터 재생
 토글 버튼 off: 특정 가사 터치 시 전체 가사 화면 닫기 (완료)
 전체 가사 화면 닫기 버튼이 있습니다. (완료)
 현재 재생 중인 부분의 가사가 하이라이팅 됩니다.
 */

import UIKit
import Combine
import SnapKit
import SDWebImage

class PlayerViewController: UIViewController {
    //MARK: - Properties
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: effect)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.bold(ofSize: 14)
        label.textColor = .white
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.regular(ofSize: 12)
        label.textColor = .white
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private let albumLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.regular(ofSize: 12)
        label.textColor = .white
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private lazy var vStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, artistLabel, albumLabel])
        sv.axis = .vertical
        sv.spacing = 4
        return sv
    }()

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
        tv.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLyricTapped))
        tv.addGestureRecognizer(tapGesture)
        tv.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        return tv
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = .white
        button.isHidden = true
        button.addTarget(self, action: #selector(handleLyricTapped), for: .touchUpInside)
        return button
    }()
    
    private let playerView: PlayerHelperView = .init()
    
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
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backgroundImageView.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(vStackView)
        vStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.left.equalToSuperview().offset(20)
        }
        
        view.addSubview(albumImageView)
        albumImageView.snp.makeConstraints { make in
            make.top.equalTo(vStackView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(albumImageView.snp.width)
        }
        
        view.addSubview(lyricTableView)
        lyricTableView.snp.makeConstraints { make in
            make.top.equalTo(albumImageView.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(90)
        }
        
        view.addSubview(playerView)
        playerView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.right.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
    }
    
    private func bind() {
        // view binding
        viewModel.songAlbum
            .assign(to: \.text, on: self.albumLabel)
            .store(in: &cancellables)
        
        viewModel.songTitle
            .assign(to: \.text, on: self.titleLabel)
            .store(in: &cancellables)
        
        viewModel.songArtist
            .assign(to: \.text, on: self.artistLabel)
            .store(in: &cancellables)
        
        viewModel.songImageUrl
            .sink { [weak self] url in
                self?.backgroundImageView.sd_setImage(with: url)
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
    
    //MARK: - Actions
    @objc private func handleLyricTapped() {
        viewModel.isLyricsExpanded.toggle()
        closeButton.isHidden = !viewModel.isLyricsExpanded
        
        if viewModel.isLyricsExpanded {
            albumImageView.snp.remakeConstraints { make in
                make.centerY.equalTo(vStackView)
                make.right.equalTo(vStackView.snp.left).offset(-10)
                make.size.equalTo(60)
            }
            
            vStackView.snp.updateConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
                make.left.equalToSuperview().offset(80)
            }
            
            lyricTableView.snp.remakeConstraints { make in
                make.top.equalTo(albumImageView.snp.bottom).offset(30)
                make.left.right.equalToSuperview().inset(20)
                make.bottom.equalTo(playerView.snp.top).offset(-20)
            }
            
            
        } else {
            albumImageView.snp.remakeConstraints { make in
                make.top.equalTo(vStackView.snp.bottom).offset(20)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(albumImageView.snp.width)
            }
            
            vStackView.snp.remakeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
                make.left.equalToSuperview().offset(20)
            }
            
            lyricTableView.snp.remakeConstraints { make in
                make.top.equalTo(albumImageView.snp.bottom).offset(30)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(90)
            }
        }
        
        UIView.animate(withDuration: 0.5, animations: self.view.layoutIfNeeded)
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
        cell.textLabel?.font = viewModel.lyricIndex.value == indexPath.row ? UIFont.boldSystemFont(ofSize: 18) : UIFont.systemFont(ofSize: 16)
        cell.backgroundColor = .clear
        return cell
    }
}
