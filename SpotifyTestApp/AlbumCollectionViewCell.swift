//
//  AlbumCollectionViewCell.swift
//  SpotifyTestApp
//
//  Created by Samantha Bennett on 12/11/22.
//

import Foundation
import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {

    public static var indentifier = String(describing: AlbumCollectionViewCell.self)
    private var album: Album?

    private lazy var title: UILabel = {
        let label = UILabel()

        label.font = UIFont.preferredFont(forTextStyle: .title3)

        return label
    }()

    private lazy var subtitle: UILabel = {
        let label = UILabel()

        label.font = UIFont.preferredFont(forTextStyle: .caption1)

        return label
    }()


    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [title, subtitle])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var artworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AlbumCollectionViewCell {
    private func createSubviews() {

        enum Constants {
            static let margin: CGFloat = 8
            static let imageHeight: CGFloat = 50
        }

        contentView.addSubview(stackView)
        contentView.addSubview(artworkImageView)

        NSLayoutConstraint.activate([
            artworkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.margin),
            artworkImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: Constants.margin),
            artworkImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -Constants.margin),
            artworkImageView.heightAnchor.constraint(equalToConstant: Constants.imageHeight),
            artworkImageView.widthAnchor.constraint(equalTo: artworkImageView.heightAnchor),
            artworkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.margin),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: Constants.margin),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -Constants.margin),
            stackView.leadingAnchor.constraint(equalTo: artworkImageView.trailingAnchor, constant: Constants.margin),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 100)
    }
}

extension AlbumCollectionViewCell {
    public func configure(album: Album) {
        self.album = album
        title.text = album.name
        subtitle.text = album.artists.first?.name

        Task { [weak self] in
            guard let spotifyImage = album.images.first else { return }
            let image = await spotifyImage.image
            guard album == self?.album else {
                return
            }
            self?.artworkImageView.image = image
        }
    }
}
