import XCTest
//@testable import Matft
import Matft

final class ReduceTests: XCTestCase {
    
    func testReduce() {
        do{
            let arr = [Matft.arange(start: 0, to: 3, by: 1), Matft.arange(start: 2, to: -1, by: -1), Matft.nums(1, shape: [3,])].ufuncReduce(Matft.stats.minimum)
            XCTAssertEqual(arr, MfArray([0, 1, 0]))
        }
        
    }
    
    func testReduceAxis(){
        do{
            let a = Matft.arange(start: 0, to: 8, by: 1, shape: [2,2,2])
            
            XCTAssertEqual(a.ufuncReduce(Matft.add), MfArray([[ 4,  6],
                                                              [ 8, 10]]))
            
            XCTAssertEqual(a.ufuncReduce(Matft.add, axis: 1), MfArray([[ 2,  4],
                                                                       [10, 12]]))
            
            XCTAssertEqual(a.ufuncReduce(Matft.add, axis: 2), MfArray([[ 1,  5],
                                                                       [ 9, 13]]))
            
            XCTAssertEqual(a.ufuncReduce(Matft.add, axis: nil), MfArray([28]))
        }
        
        do{
            let a = MfArray([[11.0, 8.0],
                             [3.0, 12.0]])
            
            XCTAssertEqual(a.ufuncReduce(Matft.stats.minimum, initial: MfArray([4])), MfArray([3.0, 4.0]))
            XCTAssertEqual(a.ufuncReduce(Matft.stats.minimum, axis: nil), MfArray([3.0]))
        }
    }
    
    func testAccumulate(){
        do{
            let a = MfArray([2, 3, 5])
            
            XCTAssertEqual(a.ufuncAccumulate(Matft.add), MfArray([2, 5, 10]))
            
            XCTAssertEqual(a.ufuncAccumulate(Matft.mul), MfArray([2, 6, 30]))
        }
        
        do{
            let I = Matft.eye(dim: 2)
            
            XCTAssertEqual(I.ufuncAccumulate(Matft.add, axis: 0), MfArray([[1,  0],
                                                                           [1,  1]]))
            
            XCTAssertEqual(I.ufuncAccumulate(Matft.add, axis: 1), MfArray([[1,  1],
                                                                           [0,  1]]))
        }
        
        do{
            let a = MfArray([1, 3, 2, 5, 4])
            
            XCTAssertEqual(a.ufuncAccumulate(Matft.stats.maximum), MfArray([1, 3, 3, 5, 5]))
            
            let b = MfArray([11,12,13,20,19,18,17,18,23,21])
            
            XCTAssertEqual(b.ufuncAccumulate(Matft.stats.maximum), MfArray([11, 12, 13, 20, 20, 20, 20, 20, 23, 23]))
        }
    }
}
