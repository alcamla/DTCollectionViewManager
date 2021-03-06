//
//  CollectionViewFactory.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 23.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit
import DTModelStorage

@available(*, deprecated, message: "Error handling system is deprecated and may be removed in future versions of the framework")
/// Errors, that can be thrown by `CollectionViewFactory` if it fails to create a cell or supplementary view because of various reasons.
/// These errors are handled by `DTCollectionViewManager` class.
public enum DTCollectionViewFactoryError : Error, CustomStringConvertible
{
    /// `UICollectionView` requested a cell, however model at indexPath is nil.
    case nilCellModel(IndexPath)
    
    /// `UICollectionView` requested a supplementary of `kind`, however supplementary at `indexPath` is nil.
    case nilSupplementaryModel(kind: String, indexPath: IndexPath)
    
    /// `UICollectionView` requested a cell for `model`, however `DTCollectionViewManager` does not have mapping for it
    case noCellMappings(model: Any)
    
    /// `UICollectionView` requested a supplementary for `model` of `kind`, however `DTCollectionViewManager` does not have mapping for it
    case noSupplementaryViewMapping(kind: String, model: Any)
    
    /// Prints description of error.
    public var description : String {
        switch self {
        case .nilCellModel(let indexPath):
            return "Received nil model for cell at index path: \(indexPath)"
        case .nilSupplementaryModel(let kind, let indexPath):
            return "Received nil model for supplementary view of kind: \(kind) at index path: \(indexPath)"
        case .noCellMappings(let model):
            return "Cell mapping is missing for model: \(model)"
        case .noSupplementaryViewMapping(let kind, let model):
            return "Supplementary mapping of kind: \(kind) is missing for model: \(model)"
        }
    }
}

/// Internal class, that is used to create collection view cells and supplementary views.
final class CollectionViewFactory
{
    fileprivate let collectionView: UICollectionView
    
    var mappings = [ViewModelMapping]()
    
    weak var mappingCustomizableDelegate : ViewModelMappingCustomizing?
    
    init(collectionView: UICollectionView)
    {
        self.collectionView = collectionView
    }
}

// MARK: Registration
extension CollectionViewFactory
{
    func registerCellClass<T:ModelTransfer>(_ cellClass: T.Type, mappingBlock: ((ViewModelMapping) -> Void)?) where T: UICollectionViewCell
    {
        let mapping : ViewModelMapping
        if UINib.nibExists(withNibName: String(describing: T.self), inBundle: Bundle(for: T.self)) {
            mapping = ViewModelMapping(viewType: .cell, viewClass: T.self, xibName: String(describing: T.self), mappingBlock: mappingBlock)
            collectionView.register(UINib(nibName: String(describing: T.self), bundle: Bundle(for: T.self)), forCellWithReuseIdentifier: mapping.reuseIdentifier)
        } else {
            mapping = ViewModelMapping(viewType: .cell, viewClass: T.self, mappingBlock: mappingBlock)
        }
        mappings.append(mapping)
    }
    
    func registerNiblessCellClass<T:ModelTransfer>(_ cellClass: T.Type, mappingBlock: ((ViewModelMapping) -> Void)?) where T:UICollectionViewCell
    {
        let mapping = ViewModelMapping(viewType: .cell, viewClass: T.self, mappingBlock: mappingBlock)
        collectionView.register(cellClass, forCellWithReuseIdentifier: mapping.reuseIdentifier)
        mappings.append(mapping)
    }
    
    func registerNibNamed<T:ModelTransfer>(_ nibName: String, forCellClass cellClass: T.Type, mappingBlock: ((ViewModelMapping) -> Void)?) where T: UICollectionViewCell
    {
        let mapping = ViewModelMapping(viewType: .cell, viewClass: T.self, xibName: nibName, mappingBlock: mappingBlock)
        assert(UINib.nibExists(withNibName: nibName, inBundle: Bundle(for: T.self)))
        collectionView.register(UINib(nibName: nibName, bundle: Bundle(for: T.self)), forCellWithReuseIdentifier: mapping.reuseIdentifier)
        mappings.append(mapping)
    }
    
    func registerNiblessSupplementaryClass<T:ModelTransfer>(_ supplementaryClass: T.Type, forKind kind: String, mappingBlock: ((ViewModelMapping) -> Void)?) where T: UICollectionReusableView
    {
        let mapping = ViewModelMapping(viewType: .supplementaryView(kind: kind), viewClass: T.self, mappingBlock: mappingBlock)
        collectionView.register(supplementaryClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: mapping.reuseIdentifier)
        mappings.append(mapping)
    }
    
    func registerSupplementaryClass<T:ModelTransfer>(_ supplementaryClass: T.Type, forKind kind: String, mappingBlock: ((ViewModelMapping) -> Void)?) where T:UICollectionReusableView
    {
        let mapping : ViewModelMapping
        if UINib.nibExists(withNibName: String(describing: T.self), inBundle: Bundle(for: T.self)) {
            mapping = ViewModelMapping(viewType: .supplementaryView(kind: kind), viewClass: T.self, xibName: String(describing: T.self), mappingBlock: mappingBlock)
            self.collectionView.register(UINib(nibName: String(describing: T.self), bundle: Bundle(for: T.self)), forSupplementaryViewOfKind: kind, withReuseIdentifier: mapping.reuseIdentifier)
        } else {
            mapping = ViewModelMapping(viewType: .supplementaryView(kind: kind), viewClass: T.self, mappingBlock: mappingBlock)
        }
        mappings.append(mapping)
    }
    
    func registerNibNamed<T:ModelTransfer>(_ nibName: String, forSupplementaryClass supplementaryClass: T.Type, forKind kind: String, mappingBlock: ((ViewModelMapping) -> Void)?) where T:UICollectionReusableView
    {
        let mapping = ViewModelMapping(viewType: .supplementaryView(kind: kind), viewClass: T.self, xibName: nibName, mappingBlock: mappingBlock)
        assert(UINib.nibExists(withNibName: nibName, inBundle: Bundle(for: T.self)))
        self.collectionView.register(UINib(nibName: nibName, bundle: Bundle(for: T.self)), forSupplementaryViewOfKind: kind, withReuseIdentifier: mapping.reuseIdentifier)
        mappings.append(mapping)
    }
    
    func unregisterCellClass<T:ModelTransfer>(_ cellClass: T.Type) where T: UICollectionViewCell {
        mappings = mappings.filter({ mapping in
            if mapping.viewClass is T.Type && mapping.viewType == .cell { return false }
            return true
        })
        let nilClass : AnyClass? = nil
        let nilNib : UINib? = nil
        collectionView.register(nilClass, forCellWithReuseIdentifier: String(describing: T.self))
        collectionView.register(nilNib, forCellWithReuseIdentifier: String(describing: T.self))
    }
    
    func unregisterSupplementaryClass<T:ModelTransfer>(_ klass: T.Type, forKind kind: String) where T:UICollectionReusableView {
        mappings = mappings.filter({ mapping in
            if mapping.viewClass is T.Type && mapping.viewType == .supplementaryView(kind: kind) { return false }
            return true
        })
        let nilClass : AnyClass? = nil
        let nilNib : UINib? = nil
        collectionView.register(nilClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: String(describing: self))
        collectionView.register(nilNib, forSupplementaryViewOfKind: kind, withReuseIdentifier: String(describing: self))
    }
}

// MARK: View creation
extension CollectionViewFactory
{
    func viewModelMapping(for viewType: ViewType, model: Any, at indexPath: IndexPath) -> ViewModelMapping?
    {
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else {
            return nil
        }
        let mappingCandidates = mappings.mappingCandidates(for: viewType, withModel: unwrappedModel, at: indexPath)
        
        if let customizedMapping = mappingCustomizableDelegate?.viewModelMapping(fromCandidates: mappingCandidates, forModel: unwrappedModel) {
            return customizedMapping
        } else if let defaultMapping = mappingCandidates.first {
            return defaultMapping
        } else {
            return nil
        }
    }
    
    func cellForModel(_ model: Any, atIndexPath indexPath:IndexPath) throws -> UICollectionViewCell
    {
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else {
            throw DTCollectionViewFactoryError.nilCellModel(indexPath)
        }
        if let mapping = viewModelMapping(for: .cell, model: unwrappedModel, at: indexPath)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mapping.reuseIdentifier, for: indexPath)
            mapping.updateBlock(cell, model)
            return cell
        }
        throw DTCollectionViewFactoryError.noCellMappings(model: model)
    }
    
    func updateCellAt(_ indexPath : IndexPath, with model: Any) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else { return }
        if let mapping = viewModelMapping(for: .cell, model: unwrappedModel, at: indexPath) {
            mapping.updateBlock(cell, unwrappedModel)
        }
    }

    func supplementaryViewOfKind(_ kind: String, forModel model: Any, atIndexPath indexPath: IndexPath) throws -> UICollectionReusableView
    {
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else {
            throw DTCollectionViewFactoryError.nilSupplementaryModel(kind: kind, indexPath: indexPath)
        }
        
        let mappingCandidates = mappings.mappingCandidates(for: .supplementaryView(kind: kind), withModel: unwrappedModel, at: indexPath)
        let mapping : ViewModelMapping?
        
        if let customizedMapping = mappingCustomizableDelegate?.viewModelMapping(fromCandidates: mappingCandidates, forModel: unwrappedModel) {
            mapping = customizedMapping
        } else if let defaultMapping = mappingCandidates.first {
            mapping = defaultMapping
        } else { mapping = nil }
        
        if let mapping = mapping
        {
            let viewClassName = String(describing: mapping.viewClass)
            let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: viewClassName, for: indexPath)
            mapping.updateBlock(reusableView, unwrappedModel)
            return reusableView
        }
        
        throw DTCollectionViewFactoryError.noSupplementaryViewMapping(kind: kind, model: unwrappedModel)
    }
}
