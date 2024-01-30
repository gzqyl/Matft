import XCTest
//@testable import Matft
import Matft

final class BoolTests: XCTestCase {
    
    func testAllEqual() {
        do{
            let a = MfArray([true, false])
            XCTAssertTrue(a == MfArray([true, false]))
        }
        
        do{
            let a = MfArray([2, 1, -3, 0])
            let b = MfArray([2.0, 1.01, -3.0, 0.0])
            
            XCTAssertFalse(a == b)
            
            let c = MfArray([2.0, 1.0, -3.0, 0.0])
            XCTAssertTrue(a == c)
        }
        
        do{
            let a = Matft.arange(start: 0, to: 8, by: 1, shape: [2,2,2])
            let b = MfArray([[[0,1],
                             [2,3]],
            
                             [[4,5],
                              [6,7]]])
            XCTAssertTrue(a == b)
            XCTAssertFalse(a[0~<,0~<,~<<-1] == Matft.arange(start: 7, to: -1, by: -1, shape: [2,2,2]))
            
        }
    }
    
    //element-wise
    func testEqual(){
        do{
            let a = MfArray([true, false])
            XCTAssertEqual(a === MfArray([true, false]), MfArray([true, true]))
        }
        
        do{
            let a = MfArray([2, 1, -3, 0])
            let b = MfArray([2.0, 1.01, -3.0, 0.0])
            
            XCTAssertEqual(a === b, MfArray([true, false, true, true]))
            XCTAssertEqual(-3 === b, MfArray([false, false, true, false]))
            
            let c = MfArray([2.0, 1.0, -3.0, 0.0])
            XCTAssertEqual(a === c, MfArray([true, true, true, true]))
            XCTAssertEqual(a === 1, MfArray([false, true, false, false]))
        }
        
        do{
            let a = Matft.arange(start: 0, to: 8, by: 1, shape: [2,2,2])
            let b = MfArray([[[0,1],
                             [2,3]],
            
                             [[4,5],
                              [6,7]]])
            XCTAssertEqual(a === b, MfArray([[[true,true],
                                              [true,true]],
            
                                             [[true,true],
                                              [true,true]]]))
            
            XCTAssertEqual(a[0~<,0~<,~<<-1] === Matft.arange(start: 7, to: -1, by: -1, shape: [2,2,2]),
                                    MfArray([[[false,false],
                                              [false,false]],
            
                                             [[false,false],
                                              [false,false]]]))
        }
    }
    
    
    func testLogicalNot(){
        do{
            let a = MfArray([true, false])
            XCTAssertEqual(!a, MfArray([false, true]))
        }
        
        do{
            let a = MfArray([2, 1, -3, 0])
            let b = MfArray([2.0, 1.01, -3.0, 0.0])
            
            XCTAssertEqual(a === b, MfArray([true, false, true, true]))
            XCTAssertEqual(!(a === b), MfArray([false, true, false, false]))
            
            let c = MfArray([2.0, 1.0, -3.0, 0.0])
            XCTAssertEqual(!(a === c), MfArray([false, false, false, false]))
        }
        
        do{
            let a = Matft.arange(start: 0, to: 8, by: 1, shape: [2,2,2])
            let b = MfArray([[[0,1],
                             [2,3]],
            
                             [[4,5],
                              [6,7]]])
            XCTAssertEqual(!(a === b), MfArray([[[false,false],
                                              [false,false]],
            
                                             [[false,false],
                                              [false,false]]]))
            
            XCTAssertEqual(!(a[0~<,0~<,~<<-1] === Matft.arange(start: 7, to: -1, by: -1, shape: [2,2,2])),
                                    MfArray([[[true,true],
                                              [true,true]],
                                    
                                             [[true,true],
                                              [true,true]]]))
        }
    }
    
    func testNotEqual(){
        do{
            let a = MfArray([true, false])
            XCTAssertEqual(a !== a, MfArray([false, false]))
        }
        
        do{
            let a = MfArray([2, 1, -3, 0])
            let b = MfArray([2.0, 1.01, -3.0, 0.0])
            
            XCTAssertEqual(a === b, MfArray([true, false, true, true]))
            XCTAssertEqual(a !== b, MfArray([false, true, false, false]))
            XCTAssertEqual(2 !== b, MfArray([false, true, true, true]))
            
            let c = MfArray([2.0, 1.0, -3.0, 0.0])
            XCTAssertEqual(a !== c, MfArray([false, false, false, false]))
            XCTAssertEqual(a !== 1, MfArray([true, false, true, true]))
        }
        
        do{
            let a = Matft.arange(start: 0, to: 8, by: 1, shape: [2,2,2])
            let b = MfArray([[[0,1],
                             [2,3]],
            
                             [[4,5],
                              [6,7]]])
            XCTAssertEqual(a !== b, MfArray([[[false,false],
                                              [false,false]],
            
                                             [[false,false],
                                              [false,false]]]))
            
            XCTAssertEqual(a[0~<,0~<,~<<-1] !== Matft.arange(start: 7, to: -1, by: -1, shape: [2,2,2]),
                                    MfArray([[[true,true],
                                              [true,true]],
                                    
                                             [[true,true],
                                              [true,true]]]))
        }
    }
    
    func testLess(){
        do{
            let a = MfArray([[24, 15,  8, 65, 82],
                             [56, 17, 61, 44, 68]])
            let b = MfArray([[41, 30, 71, 93,  1],
                             [78, 31, 61, 24, 44]])
            
            XCTAssertEqual(a < b, MfArray([[ true,  true,  true,  true, false],
                                           [ true,  true, false, false, false]]))
        }
        
        do{
            let a = MfArray([[0.74823355, 0.5969193 ],
                             [0.60871936, 0.45788907],
                             [0.14370076, 0.50432377]], mforder: .Column)
            let b = MfArray([[0.31286134, 0.69967412]])
            
            XCTAssertEqual(a < b, MfArray([[false,  true],
                                           [false,  true],
                                           [ true,  true]]))
        }
        
        do{
            let a = MfArray([[[0.51448786, 0.25203844],
                              [0.85263964, 0.90533189]],

                             [[0.9674209 , 0.84241149],
                              [0.29424463, 0.56187957]]])
            let b = MfArray([[[0.35092796, 0.0700771 ],
                              [0.70294935, 0.34088329]],

                             [[0.57415529, 0.08435943],
                              [0.96066889, 0.83724368]]])
            
            XCTAssertEqual(a < b, MfArray([[[false, false],
                                            [false, false]],

                                           [[false, false],
                                            [ true,  true]]]))
            
            XCTAssertEqual(a.transpose(axes: [2,0,1]) < b, MfArray([[[false, false],
                                                                     [false,  true]],

                                                                    [[ true, false],
                                                                     [ true,  true]]]))
        }
    }
    
    func testGreater(){
        do{
            let a = MfArray([[24, 15,  8, 65, 82],
                             [56, 17, 61, 44, 68]])
            let b = MfArray([[41, 30, 71, 93,  1],
                             [78, 31, 61, 24, 44]])
            
            XCTAssertEqual(b > a, MfArray([[ true,  true,  true,  true, false],
                                           [ true,  true, false, false, false]]))
        }
        
        do{
            let a = MfArray([[0.74823355, 0.5969193 ],
                             [0.60871936, 0.45788907],
                             [0.14370076, 0.50432377]], mforder: .Column)
            let b = MfArray([[0.31286134, 0.69967412]])
            
            XCTAssertEqual(b > a, MfArray([[false,  true],
                                           [false,  true],
                                           [ true,  true]]))
        }
        
        do{
            let a = MfArray([[[0.51448786, 0.25203844],
                              [0.85263964, 0.90533189]],

                             [[0.9674209 , 0.84241149],
                              [0.29424463, 0.56187957]]])
            let b = MfArray([[[0.35092796, 0.0700771 ],
                              [0.70294935, 0.34088329]],

                             [[0.57415529, 0.08435943],
                              [0.96066889, 0.83724368]]])
            
            XCTAssertEqual(b > a, MfArray([[[false, false],
                                            [false, false]],

                                           [[false, false],
                                            [ true,  true]]]))
            
            XCTAssertEqual(b > a.transpose(axes: [2,0,1]), MfArray([[[false, false],
                                                                     [false,  true]],

                                                                    [[ true, false],
                                                                     [ true,  true]]]))
        }
        
        do{
            let img = MfArray([[1, 2, 3],
                               [4, 5, 6],
                               [7, 8, 9]], mftype: .UInt8)
            img[img > 3] = MfArray([10], mftype: .UInt8)
            XCTAssertEqual(img, MfArray([[ 1,  2,  3],
                                         [10, 10, 10],
                                         [10, 10, 10]], mftype: .UInt8))
            //print(img)
        }
    }
    
    func testLessEqual(){
        do{
            let a = MfArray([[24, 15,  8, 65, 82],
                             [56, 17, 61, 44, 68]])
            let b = MfArray([[41, 30, 71, 93,  1],
                             [78, 31, 61, 24, 44]])
            
            XCTAssertEqual(a <= b, MfArray([[ true,  true,  true,  true, false],
                                           [ true,  true, true, false, false]]))
        }
        
        do{
            let a = MfArray([[0.74823355, 0.5969193 ],
                             [0.60871936, 0.45788907],
                             [0.14370076, 0.50432377]], mforder: .Column)
            let b = MfArray([[0.60871936, 0.69967412]])
            
            XCTAssertEqual(a <= b, MfArray([[false,  true],
                                           [ true,  true],
                                           [ true,  true]]))
        }
        
        do{
            let a = MfArray([[[0.51448786, 0.25203844],
                              [0.70294935, 0.90533189]],

                             [[0.9674209 , 0.84241149],
                              [0.29424463, 0.56187957]]])
            let b = MfArray([[[0.35092796, 0.0700771 ],
                              [0.70294935, 0.34088329]],

                             [[0.57415529, 0.08435943],
                              [0.96066889, 0.83724368]]])
            
            XCTAssertEqual(a <= b, MfArray([[[false, false],
                                            [ true, false]],

                                           [[false, false],
                                            [ true,  true]]]))
            
            XCTAssertEqual(a.transpose(axes: [2,0,1]) <= b, MfArray([[[false, false],
                                                                     [false,  true]],

                                                                    [[ true, false],
                                                                     [ true,  true]]]))
        }
    }
    
    func testGreaterEqual(){
        do{
            let a = MfArray([[24, 15,  8, 65, 82],
                             [56, 17, 61, 44, 68]])
            let b = MfArray([[41, 30, 71, 93,  1],
                             [78, 31, 61, 24, 44]])
            
            XCTAssertEqual(b >= a, MfArray([[ true,  true,  true,  true, false],
                                           [ true,  true, true, false, false]]))
        }
        
        do{
            let a = MfArray([[0.74823355, 0.5969193 ],
                             [0.60871936, 0.45788907],
                             [0.14370076, 0.50432377]], mforder: .Column)
            let b = MfArray([[0.60871936, 0.69967412]])
            
            XCTAssertEqual(b >= a, MfArray([[false,  true],
                                           [ true,  true],
                                           [ true,  true]]))
        }
        
        do{
            let a = MfArray([[[0.51448786, 0.25203844],
                              [0.70294935, 0.90533189]],

                             [[0.9674209 , 0.84241149],
                              [0.29424463, 0.56187957]]])
            let b = MfArray([[[0.35092796, 0.0700771 ],
                              [0.70294935, 0.34088329]],

                             [[0.57415529, 0.08435943],
                              [0.96066889, 0.83724368]]])
            
            XCTAssertEqual(b >= a, MfArray([[[false, false],
                                            [ true, false]],

                                           [[false, false],
                                            [ true,  true]]]))
            
            XCTAssertEqual(b >= a.transpose(axes: [2,0,1]), MfArray([[[false, false],
                                                                     [false,  true]],

                                                                    [[ true, false],
                                                                     [ true,  true]]]))
        }
    }
}
