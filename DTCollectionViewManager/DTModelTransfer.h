//
//  DTModelTransfer.h
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 1/24/13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
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

/**
 `DTModelTransfer` protocol is used to pass `model` data to your cell or supplementary view. Every UICollectionViewCell or UICollectionReusableView subclass you have should implement this protocol.
 */

@protocol DTModelTransfer

/**
 This method will be called, when controller needs to display model on current cell or supplementary view.
 
 @param model Model object to display on current cell
 
 */
-(void)updateWithModel:(id)model;

@optional

/**
 This method can be used to retrieve cell model from the cell
 */
-(id)model;

@end