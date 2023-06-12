//
//  UIImage.swift
//  Util
//
//  Created by V on 2022/11/14.
//

import UIKit

public extension UIImage {
    ///均值哈希(8x8灰度值照片)
    var aHashValue: NSString {
        guard let imageRef = self.zoom(size: CGSize(width: 8, height: 8), scale: 1)?.gray?.cgImage else {
            fatalError("图片数据获取失败")
        }
        let aHashString = NSMutableString()
        let pixelData = imageRef.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        var sum: Int = 0
        for i in 0..<64 {
            sum = sum + Int(data[i])
        }
        let avr = sum / 64 //平均灰度值
        for i in 0..<64 {
            if Int(data[i]) >= avr {
                aHashString.append("1")
            } else {
                aHashString.append("0")
            }
        }
        return aHashString
    }
    
    ///感知哈希(32x32灰度值照片)
    var pHashValue: NSString {
        guard let imageRef = self.zoom(size: CGSize(width: 32, height: 32), scale: 1)?.gray?.cgImage else {
            fatalError("图片数据获取失败")
        }
        let aHashString = NSMutableString()
        let pixelData = imageRef.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        var matrix = [[UInt8]](repeating: [UInt8](repeating: 0, count: 32), count: 32)
        for i in 0..<32 {
            for j in 0..<32 {
                matrix[i][j] = data[i*32+j]
            }
        }
        //二维DCT
        return aHashString
    }
    
    //离散余弦变换
    private func dctMatrix(matrix: [[UInt8]])  {
        let N = 32
        var c = [Double](repeating: 1, count: 32)
        var CO1 = [[Double]](repeating: [Double](repeating: 0, count: 32), count: 32)
        var CO2 = [[Double]](repeating: [Double](repeating: 0, count: 32), count: 32)
        var CV = [[Double]](repeating: [Double](repeating: 0, count: 32), count: 32)
        c[0] = 1.0 / sqrt(2.0)
        for i in 0..<N {
            for j in 0..<N {
                CO1[i][j] = cos((2*Double(i)+1)/(2*Double(N))*Double(j)*Double.pi)
                CO2[i][j] = CO1[i][j]
                
//                CO2[i][j] = cos(((2 * i + 1.0) / (2.0 * (double)N)) * j * M_PI);
//                CV[i][j] = (c[i] * c[j]) / sqrt(2.0 * N);
            }
        }
//        for (int u = 0; u < N; u++) {
//            for (int v = 0; v < N; v++) {
//                double sum = 0.0;
//                UNROLL_DCT_I(u, v)
//                sum *= CV[u][v];
//                result[u][v] = sum;
//            }
//        }
    }
    
    ///差值哈希（9x8灰度值照片）
    var dHashValue: NSString {
        guard let imageRef = self.zoom(size: CGSize(width: 9, height: 8), scale: 1)?.gray?.cgImage else {
            fatalError("图片数据获取失败")
        }
        let dHashString = NSMutableString()
        let pixelData = imageRef.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        for i in 0..<8 {
            for j in 0..<8 {
                if data[i*9 + j] > data[i*9 + j + 1] {
                    dHashString.append("1")
                } else {
                    dHashString.append("0")
                }
            }
        }
        return dHashString
    }
    
    //汉明距离：对两个字符串进行异或运算，并统计结果为1的个数(大于10(距离相似阈值)不相似，小于5非常相似)
    static func similarCompare(lhs: NSString, rhs: NSString) -> Bool {
        var diff: NSInteger = 0
        let s1 = lhs.utf8String!
        let s2 = rhs.utf8String!
        for i in 0..<lhs.length {
            if s1[i] != s2[i] {
                diff += 1
            }
        }
        if diff > 10 {
            return false
        }
        return true
    }
}
