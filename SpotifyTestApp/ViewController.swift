//
//  ViewController.swift
//  SpotifyTestApp
//
//  Created by Samantha Bennett on 12/11/22.
//

import OSLog
import UIKit

class ViewController: UIViewController {
    typealias CollectionViewType = UICollectionViewDiffableDataSource<Section, Album>

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: ViewController.self))

    enum Section {
        case main
    }

    private var datasource: CollectionViewType?

    private lazy var collectionView: UICollectionView = {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        collectionView.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: AlbumCollectionViewCell.indentifier)
        let datasource = CollectionViewType(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCollectionViewCell.indentifier, for: indexPath)
            guard var cell = cell as? AlbumCollectionViewCell else {
                assertionFailure()
                return cell
            }

            cell.configure(album: itemIdentifier)
            return cell
        }
        self.datasource = datasource
        collectionView.dataSource = datasource
        collectionView.delegate = self

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadTopAlbums()
    }
}

extension ViewController {
    private func setupViews() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}

extension ViewController {
    private func loadTopAlbums() {
        Task {
            do {
                guard let albums = try await NetworkManager.shared.albums() else { return }
                updateCollectionView(albums: albums)
            } catch {
                logger.error("Error getting albums: \(error)")
            }

        }
    }

    @MainActor
    private func updateCollectionView(albums: [Album]) {
        guard var snapshot = datasource?.snapshot() else { return }
        snapshot.deleteAllItems()
        snapshot.appendSections([.main])
        snapshot.appendItems(albums)
        datasource?.apply(snapshot, animatingDifferences: true)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {

        return UIContextMenuConfiguration(actionProvider: { suggestedActions in
            return UIMenu(children: [
                UIAction(title: "Copy") { _ in /* Implement the action. */ },
                UIAction(title: "Delete", attributes: .destructive) { _ in /* Implement the action. */ }
            ])
        })

    }
}
