//
//  vImage.swift
//  
//
//  Created by Junnosuke Kado on 2022/07/23.
//

import Foundation
import Accelerate

internal typealias vImage_resize_func = (UnsafePointer<vImage_Buffer>, UnsafePointer<vImage_Buffer>, UnsafeMutableRawPointer?, vImage_Flags) -> vImage_Error

internal typealias vImage_affine_func<T> = (UnsafePointer<vImage_Buffer>, UnsafePointer<vImage_Buffer>, UnsafeMutableRawPointer?, UnsafePointer<vImage_AffineTransform>, UnsafePointer<T>?, vImage_Flags) -> vImage_Error

@inlinable
internal func vImageAffineWarp_PlanarF_(_ src: UnsafePointer<vImage_Buffer>, _ dest: UnsafePointer<vImage_Buffer>, _ tempBuffer: UnsafeMutableRawPointer!, _ transform: UnsafePointer<vImage_AffineTransform>, _ backColor: UnsafePointer<Pixel_F>?, _ flags: vImage_Flags) -> vImage_Error{
    return vImageAffineWarp_PlanarF(src, dest, tempBuffer, transform, backColor?.pointee ?? 0, flags)
}

/// Wrapper of vImage 4 channel to 1 channel function
/// - Parameters:
///   - srcptr: A  source pointer
///   - dstptr: A destination pointer
///   - height: height
///   - width: width
///   - pre_bias: pre bias array
///   - coef: coefficient array
///   - post_bias;  post bias value
@inline(__always)
internal func wrap_vImage_c4toc1(_ srcptr: UnsafeMutableRawPointer, _ dstptr: UnsafeMutableRawPointer, _ height: Int, _ width: Int, _ pre_bias: inout [Float], _ coef: inout [Float], _ post_bias: Float){
    let bytenum = MemoryLayout<Float>.size // 4
    var src_buffer = vImage_Buffer(data: srcptr, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: width*4*bytenum)
    var dst_buffer = vImage_Buffer(data: dstptr, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: width*1*bytenum)
    
    if #available(macOS 10.11, *) {
        vImageMatrixMultiply_ARGBFFFFToPlanarF(&src_buffer, &dst_buffer, &coef, &pre_bias, post_bias, vImage_Flags(kvImageNoFlags))
    } else {
        fatalError("Couldn't support os version.")
    }
}

/// Wrapper of vImage resize function
/// - Parameters:
///   - srcptr: A  source pointer
///   - srcHeight: height
///   - srcWidth: width
///   - dstptr: A destination pointer
///   - dstHeight: height
///   - dstWidth: width
///   - channel: channel
///   - vImage_func: pvImage resize function
@inline(__always)
internal func wrap_vImage_resize(_ srcptr: UnsafeMutableRawPointer, _ srcHeight: Int, _ srcWidth: Int, _ dstptr: UnsafeMutableRawPointer, _ dstHeight: Int, _ dstWidth: Int, _ channel: Int, vImage_func: vImage_resize_func){
    let bytenum = MemoryLayout<Float>.size // 4
    var src_buffer = vImage_Buffer(data: srcptr, height: vImagePixelCount(srcHeight), width: vImagePixelCount(srcWidth), rowBytes: srcWidth*channel*bytenum)
    var dst_buffer = vImage_Buffer(data: dstptr, height: vImagePixelCount(dstHeight), width: vImagePixelCount(dstWidth), rowBytes: dstWidth*channel*bytenum)
    
    _ = vImage_func(&src_buffer, &dst_buffer, nil, vImage_Flags(kvImageHighQualityResampling))
}


/// Wrapper of vImage affine transformation function
/// - Parameters:
///   - srcptr: A  source pointer
///   - srcHeight: height
///   - srcWidth: width
///   - dstptr: A destination pointer
///   - dstHeight: height
///   - dstWidth: width
///   - channel: channel
///   - matrix: Transfrom matrix
///   - backColor: The background color value
///   - flags: Flags
@inline(__always)
internal func wrap_vImage_affine<T>(_ srcptr: UnsafeMutableRawPointer, _ srcHeight: Int, _ srcWidth: Int, _ dstptr: UnsafeMutableRawPointer, _ dstHeight: Int, _ dstWidth: Int, _ channel: Int, _ matrix: UnsafePointer<Float>, _ backColor: UnsafePointer<T>?, _ flags: Int, vImage_func: vImage_affine_func<T>){
    let bytenum = MemoryLayout<T>.size // 1(UInt8) or 4(Float)
    var src_buffer = vImage_Buffer(data: srcptr, height: vImagePixelCount(srcHeight), width: vImagePixelCount(srcWidth), rowBytes: srcWidth*channel*bytenum)
    var dst_buffer = vImage_Buffer(data: dstptr, height: vImagePixelCount(dstHeight), width: vImagePixelCount(dstWidth), rowBytes: dstWidth*channel*bytenum)
    
    var transform = vImage_AffineTransform(a: matrix.pointee, b: (matrix + 1).pointee, c: (matrix + 3).pointee, d: (matrix + 4).pointee, tx: (matrix + 2).pointee, ty: (matrix + 5).pointee)
    
    _ = vImage_func(&src_buffer, &dst_buffer, nil, &transform, backColor, vImage_Flags(flags))
}

/// Convert 4 channels into 1 channel
/// - Parameters:
///   - image: An image mfarray
///   - pre_bias: pre bias array
///   - coef: coefficient array
///   - post_bias;  post bias value
///   - background: background array, if it's nill, exclude alpha channel.
/// - Returns: 1-channeled image mfarray
internal func c4toc1_by_vImage(_ image: MfArray, pre_bias: [Float], coef: [Float], post_bias: Float, background: [Float]?) -> MfArray{
    assert(pre_bias.count == 4)
    assert(coef.count == 4)
    var pre_bias = pre_bias
    var coef = coef
    var (image, height, width, channel) = check_and_convert_image_dim(image)
    
    if (channel == 1){
        return image
    }
    precondition(channel == 4, "must be 3d = (h,w,4)")
    
    if let background = background {
        _ = rgba2rgb_image(image, isCopy: false, keepAlpha: false, background: background)
        //image.swapaxes(axis1: -1, axis2: 0)[0~<3] = (image[Matft.all, Matft.all, 0~<3]*alpha + (1 - alpha) * MfArray([1, 1, 1], mftype: image.mftype)).swapaxes(axis1: -1, axis2: 0)
    }
    
    image = check_contiguous(image, .Row)
    
    let newdata = MfData(size: height*width, mftype: image.mftype)
    newdata.withUnsafeMutableStartRawPointer{
        dstptr in
        image.withUnsafeMutableStartRawPointer{
            srcptr in
            wrap_vImage_c4toc1(srcptr, dstptr, height, width, &pre_bias, &coef, post_bias)
        }
    }
    
    let newstructure = MfStructure(shape: [height, width], mforder: .Row)
    
    return MfArray(mfdata: newdata, mfstructure: newstructure)
}



/// Resize image
/// - Parameters:
///   - image: An image mfarray
///   - dstWidth: The dstination width
///   - dstHeight: The destination height
/// - Returns: Resized image mfarray
internal func resize_by_vImage(_ image: MfArray, dstWidth: Int, dstHeight: Int) -> MfArray{
    var (image, srcHeight, srcWidth, channel) = check_and_convert_image_dim(image)
    
    let newdata = MfData(size: dstWidth*dstHeight*channel, mftype: image.mftype)
    let newstructure: MfStructure
    let dstShape = [dstHeight, dstWidth, channel]
    
    if channel == 1{// gray
        image = check_contiguous(image, .Column)
        
        image.withUnsafeMutableStartRawPointer{
            srcptr in
            newdata.withUnsafeMutableStartRawPointer{
                dstptr in
                wrap_vImage_resize(srcptr, srcHeight, srcWidth, dstptr, dstHeight, dstWidth, 1, vImage_func: vImageScale_PlanarF)
            }
        }
        newstructure = MfStructure(shape: dstShape, mforder: .Column)
    }
    else if channel == 4{ // RGBA
        image = check_contiguous(image)
        
        if image.mfstructure.row_contiguous{
            image.withUnsafeMutableStartRawPointer{
                srcptr in
                newdata.withUnsafeMutableStartRawPointer{
                    dstptr in
                    wrap_vImage_resize(srcptr, srcHeight, srcWidth, dstptr, dstHeight, dstWidth, 4, vImage_func: vImageScale_ARGBFFFF)
                }
            }
            
            newstructure = MfStructure(shape: dstShape, mforder: .Row)
        }
        else{ // column contiguous
            image.withUnsafeMutableStartRawPointer{
                srcptr in
                newdata.withUnsafeMutableStartRawPointer{
                    dstptr in
                    for i in 0..<4{
                        wrap_vImage_resize(srcptr + i*srcWidth*srcHeight*4, srcHeight, srcWidth, dstptr + i*dstWidth*dstHeight*4, dstHeight, dstWidth, 1, vImage_func: vImageScale_PlanarF)
                    }
                }
            }
            
            newstructure = MfStructure(shape: dstShape, mforder: .Column)
        }
    }
    else{
        preconditionFailure("Unsupport shape: \(image.shape)")
    }
    
    return MfArray(mfdata: newdata, mfstructure: newstructure)
}


/// Apply affine  transformation
/// - Parameters:
///     - image: An image mfarray
///     - matrix: The transform matrix (shape=(2,3))
///     - width: The destination width
///     - height: The destination height
///     - mode: The pixel extrapolation mode
///     - borderValue: The border value. Count must be 1 or 4
/// - Returns: Affine transformed image mfarray
internal func affine_by_vImage(_ image: MfArray, dstHeight: Int, dstWidth: Int, matrix: MfArray, mode: MfAffineMode, borderValue: [Float]) -> MfArray{
    precondition(matrix.mftype == .Float, "matrix must be Float, but got \(matrix.mftype)")
    precondition(matrix.shape == [2, 3], "matrix's shape must be [2, 3], but got \(matrix.shape)")
    
    let matrix = check_contiguous(matrix, .Row)
    var (image, srcHeight, srcWidth, channel) = check_and_convert_image_dim(image)
    
    let newdata = MfData(size: dstWidth*dstHeight*channel, mftype: image.mftype)
    let newstructure: MfStructure
    let dstShape = [dstHeight, dstWidth, channel]
    
    let flags: Int
    switch mode{
    case .ColorFill:
        flags = kvImageBackgroundColorFill
    case .EdgeExtend:
        flags = kvImageEdgeExtend
    }
    var borderValue = borderValue
    
    if channel == 1{// gray
        image = check_contiguous(image, .Column)
        
        image.withUnsafeMutableStartRawPointer{
            srcptr in
            newdata.withUnsafeMutableStartRawPointer{
                dstptr in
                matrix.withUnsafeMutableStartPointer(datatype: Float.self){
                    matptr in
                    wrap_vImage_affine(srcptr, srcHeight, srcWidth, dstptr, dstHeight, dstWidth, 1, matptr, &borderValue, flags, vImage_func: vImageAffineWarp_PlanarF_)
                }
            }
        }
        newstructure = MfStructure(shape: dstShape, mforder: .Column)
    }
    else if channel == 4{ // RGBA
        image = check_contiguous(image)
        
        if image.mfstructure.row_contiguous{
            image.withUnsafeMutableStartRawPointer{
                srcptr in
                newdata.withUnsafeMutableStartRawPointer{
                    dstptr in
                    matrix.withUnsafeMutableStartPointer(datatype: Float.self){
                        matptr in
                        wrap_vImage_affine(srcptr, srcHeight, srcWidth, dstptr, dstHeight, dstWidth, 4, matptr, &borderValue, flags, vImage_func: vImageAffineWarp_ARGBFFFF)
                    }
                }
            }
            
            newstructure = MfStructure(shape: dstShape, mforder: .Row)
        }
        else{ // column contiguous
            image.withUnsafeMutableStartRawPointer{
                srcptr in
                newdata.withUnsafeMutableStartRawPointer{
                    dstptr in
                    matrix.withUnsafeMutableStartPointer(datatype: Float.self){
                        matptr in
                        for i in 0..<4{
                            wrap_vImage_affine(srcptr + i*srcWidth*srcHeight*4, srcHeight, srcWidth, dstptr + i*dstWidth*dstHeight*4, dstHeight, dstWidth, 1, matptr, &borderValue, flags, vImage_func: vImageAffineWarp_PlanarF_)
                        }
                    }
                }
            }
            
            newstructure = MfStructure(shape: dstShape, mforder: .Column)
        }
    }
    else{
        preconditionFailure("Unsupport shape: \(image.shape)")
    }
    
    return MfArray(mfdata: newdata, mfstructure: newstructure)
}
